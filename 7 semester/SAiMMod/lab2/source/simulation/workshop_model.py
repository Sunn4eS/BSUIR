"""Событийно-ориентированная модель участка авторемонтной станции.

Модель использует только SimPy: время продвигается от события к событию,
никакого постоянного шага ``dt`` нет.

Основные правила:

* кузовной участок -- ``simpy.PreemptiveResource`` на 3 места;
* Модель 1 имеет более высокий приоритет и может вытеснить Модель 2;
* вытесненная Модель 2 сохраняет остаток кузовного ремонта и возвращается
  в очередь;
* покраска -- общий FIFO-ресурс на 1 место;
* после ``sim_time`` новые заявки не создаются, но все уже принятые автомобили
  дообслуживаются до полного завершения.
"""

from __future__ import annotations

import random
from dataclasses import dataclass, field
from enum import IntEnum
from typing import Final

import simpy
from simpy.resources.resource import Preempted

from config.model_config import WorkshopConfig
from simulation.monitors import SimulationResults, WorkshopMonitor
from simulation.tracer import Tracer

# Значения меньше этого порога считаются нулём. Нужен для устойчивости
# сравнений остатков времени после вычитания чисел с плавающей точкой.
TIME_EPSILON: Final[float] = 1e-9


class ModelType(IntEnum):
    """Тип автомобиля. Значение совпадает с номером модели из задания."""

    MODEL_1 = 1
    MODEL_2 = 2


@dataclass(slots=True)
class Car:
    """Состояние одного автомобиля в модели."""

    car_id: str
    model: ModelType
    entry_time: float
    body_duration: float
    paint_duration: float
    body_remaining: float = field(init=False)
    body_service_total: float = 0.0
    exit_time: float | None = None

    def __post_init__(self) -> None:
        if self.body_duration < 0.0:
            raise ValueError("Время кузовного ремонта не может быть отрицательным.")
        if self.paint_duration < 0.0:
            raise ValueError("Время покраски не может быть отрицательным.")
        self.body_remaining = self.body_duration

    @property
    def is_model_1(self) -> bool:
        """``True`` для приоритетной Модели 1."""

        return self.model is ModelType.MODEL_1

    @property
    def priority(self) -> int:
        """Приоритет SimPy: меньшее число означает более высокий приоритет."""

        return 0 if self.is_model_1 else 1

    @property
    def total_time_in_system(self) -> float:
        """Время от входа до выхода; до завершения возвращает 0."""

        if self.exit_time is None:
            return 0.0
        return self.exit_time - self.entry_time


class WorkshopModel:
    """Один прогон имитационной модели.

    Типичное использование::

        model = WorkshopModel(WorkshopConfig(seed=1))
        results = model.run()

    Для детерминированных сценариев можно заранее добавить автомобили через
    :meth:`add_car` и вызвать ``run(start_arrivals=False)``.
    """

    def __init__(
        self,
        config: WorkshopConfig,
        rng: random.Random | None = None,
    ) -> None:
        self.config = config
        self.env = simpy.Environment()

        # Единственный генератор ПСЧ. Если rng не передан, создаётся ровно один
        # random.Random(seed); глобальный random в модели не используется.
        self.rng = rng if rng is not None else random.Random(config.seed)

        self.tracer = Tracer(self.env, enabled=config.trace)
        self.monitor = WorkshopMonitor(self.env)

        # Кузов: приоритетный ресурс с вытеснением.
        self.body_shop = simpy.PreemptiveResource(
            self.env, capacity=config.num_body_places
        )
        # Покраска: обычный FIFO-ресурс. simpy.Resource не поддерживает
        # приоритеты, поэтому заявки обслуживаются в порядке поступления.
        self.paint_shop = simpy.Resource(
            self.env, capacity=config.num_paint_booths
        )

        # Счётчики для механизма дообслуживания.
        self.active_cars: int = 0
        self.arrivals_running: int = 0

        # Событие "все принятые автомобили покинули систему".
        self._drained = self.env.event()
        self._stop_requested = self.env.event()

        self._arrival_processes: list[simpy.Process] = []
        self._car_processes: list[simpy.Process] = []
        self._process_to_car: dict[simpy.Process, Car] = {}
        self._cars: list[Car] = []
        self._car_counters: dict[ModelType, int] = {
            ModelType.MODEL_1: 0,
            ModelType.MODEL_2: 0,
        }

        self._started = False
        self._finished = False
        self._results: SimulationResults | None = None
        self._censored_recorded = False

    @property
    def results(self) -> SimulationResults | None:
        """Результаты последнего прогона или ``None`` до его завершения."""

        return self._results

    # ------------------------------------------------------------------
    # Генерация случайных величин
    # ------------------------------------------------------------------
    def _sample_body_duration(self) -> float:
        """Выборка времени кузовного ремонта из N(mu, sigma).

        Нормальное распределение теоретически может дать отрицательное
        значение; физически отрицательного ремонта не бывает, поэтому
        результат ограничивается нулём.
        """

        sample = self.rng.normalvariate(
            self.config.body_repair_mu,
            self.config.body_repair_sigma,
        )
        return max(0.0, sample)

    def _sample_paint_duration(self, body_duration: float) -> float:
        """Выборка времени покраски.

        Математическое ожидание строго пропорционально фактическому времени
        кузовного ремонта: ``mu_paint = paint_ratio * body_duration``.
        """

        paint_mu = self.config.paint_ratio * body_duration
        sample = self.rng.normalvariate(paint_mu, self.config.paint_sigma)
        return max(0.0, sample)

    # ------------------------------------------------------------------
    # Создание автомобилей
    # ------------------------------------------------------------------
    def _next_car_id(self, model: ModelType) -> str:
        """Формирует идентификатор вида ``M1_3`` или ``M2_1``."""

        self._car_counters[model] += 1
        return f"M{int(model)}_{self._car_counters[model]}"

    def add_car(
        self,
        model: ModelType,
        entry_time: float | None = None,
        body_duration: float | None = None,
        paint_duration: float | None = None,
    ) -> Car:
        """Добавляет автомобиль в модель.

        Обычно вызывается из генератора приходов. Явные ``body_duration`` и
        ``paint_duration`` нужны для детерминированных тестов и ручных
        сценариев; если они не заданы, используются случайные выборки.
        """

        if self._finished:
            raise RuntimeError("Нельзя добавлять автомобили после завершения прогона.")

        if entry_time is None:
            entry_time = self.env.now
        if entry_time < self.env.now - TIME_EPSILON:
            raise ValueError("entry_time не может быть в прошлом.")

        if body_duration is None:
            body_duration = self._sample_body_duration()
        if paint_duration is None:
            paint_duration = self._sample_paint_duration(body_duration)

        car = Car(
            car_id=self._next_car_id(model),
            model=model,
            entry_time=float(entry_time),
            body_duration=float(body_duration),
            paint_duration=float(paint_duration),
        )

        # active_cars увеличивается уже при планировании: автомобиль, который
        # въедет позже, всё равно считается находящимся в модели.
        self.active_cars += 1
        self._cars.append(car)

        process = self.env.process(self._car_lifecycle(car))
        self._process_to_car[process] = car
        self._car_processes.append(process)
        return car

    # ------------------------------------------------------------------
    # Входящие потоки
    # ------------------------------------------------------------------
    def _arrival_generator(self, model: ModelType, mean_interval: float) -> simpy.events.Generator:
        """Генерирует пуассоновский поток одного типа автомобилей.

        Следующий интервал планируется внутри обработчика текущего прихода.
        Генератор останавливается ровно в момент ``sim_time``: заявки на
        границе окна приёма не создаются.
        """

        try:
            while True:
                now = self.env.now
                if now >= self.config.sim_time - TIME_EPSILON:
                    break

                interval = self.rng.expovariate(1.0 / mean_interval)
                interval = max(interval, TIME_EPSILON)
                next_time = now + interval

                if next_time >= self.config.sim_time - TIME_EPSILON:
                    # Досрочно "домотать" время до конца окна приёма, чтобы
                    # счётчик активных процессов не задерживал прогон.
                    wait = self.config.sim_time - now
                    if wait > TIME_EPSILON:
                        yield self.env.timeout(wait)
                    break

                yield self.env.timeout(interval)
                self.add_car(model, entry_time=self.env.now)
        finally:
            self.arrivals_running -= 1
            self._maybe_finish()

    # ------------------------------------------------------------------
    # Жизненный цикл автомобиля
    # ------------------------------------------------------------------
    def _car_lifecycle(self, car: Car) -> simpy.events.Generator:
        """Полный цикл: приход -> кузов -> покраска -> уход."""

        process = self.env.active_process
        if process is not None:
            # Регистрируем процесс, чтобы по cause.by при вытеснении найти
            # автомобиль-вытеснитель.
            self._process_to_car[process] = car

        body_start_time: float | None = None
        paint_start_time: float | None = None
        body_finish_time: float | None = None
        paint_finish_time: float | None = None
        interrupted = False

        try:
            wait = car.entry_time - self.env.now
            if wait > TIME_EPSILON:
                yield self.env.timeout(wait)

            # Фактический момент входа может отличаться от планового на
            # бесконечно малую величину из-за порядка событий.
            car.entry_time = float(self.env.now)
            self.monitor.record_arrival(int(car.model), car.entry_time)
            self.tracer.log(
                car.car_id,
                "ПРИБЫТИЕ",
                f"Очередь кузова: {len(self.body_shop.queue)}, "
                f"занято: {len(self.body_shop.users)}",
            )

            body_start_time = self.env.now
            yield from self._body_stage(car)
            body_finish_time = self.env.now
            paint_start_time = self.env.now
            yield from self._paint_stage(car)
            paint_finish_time = self.env.now
        except simpy.Interrupt:
            # При жёсткой остановке может потребоваться прерывание
            interrupted = True
            if process is not None:
                self._process_to_car.pop(process, None)
            self.active_cars -= 1
            self.monitor.record_censored(int(car.model))
            self.monitor.record_car_record(
                {
                    "car_id": car.car_id,
                    "model": int(car.model),
                    "entry_time": float(car.entry_time),
                    "body_duration_planned": float(car.body_duration),
                    "paint_duration_planned": float(car.paint_duration),
                    "body_remaining_at_stop": float(car.body_remaining),
                    "body_start_time": float(body_start_time) if body_start_time is not None else None,
                    "body_finish_time": float(body_finish_time) if body_finish_time is not None else None,
                    "paint_start_time": float(paint_start_time) if paint_start_time is not None else None,
                    "paint_finish_time": float(paint_finish_time) if paint_finish_time is not None else None,
                    "exit_time": None,
                    "time_in_system": None,
                    "status": "censored",
                    "preemptions": self.monitor.preemption_events[-1]["time"] if False else None,
                }
            )
            self._sync_metrics()
            self._maybe_finish()
            return
        except BaseException:
            # При ошибке не оставляем "вечный" счётчик активных автомобилей.
            self.active_cars -= 1
            if process is not None:
                self._process_to_car.pop(process, None)
            self._maybe_finish()
            raise

        if interrupted:
            return

        car.exit_time = float(self.env.now)
        total_time = car.total_time_in_system
        self.monitor.record_car_finished(
            int(car.model), total_time, exit_time=car.exit_time
        )
        self.monitor.record_car_record(
            {
                "car_id": car.car_id,
                "model": int(car.model),
                "entry_time": float(car.entry_time),
                "body_duration_planned": float(car.body_duration),
                "paint_duration_planned": float(car.paint_duration),
                "body_remaining_at_stop": 0.0,
                "body_start_time": float(body_start_time) if body_start_time is not None else None,
                "body_finish_time": float(body_finish_time) if body_finish_time is not None else None,
                "paint_start_time": float(paint_start_time) if paint_start_time is not None else None,
                "paint_finish_time": float(paint_finish_time) if paint_finish_time is not None else None,
                "exit_time": float(car.exit_time),
                "time_in_system": float(total_time),
                "status": "finished",
                "preemptions": None,
            }
        )

        self.active_cars -= 1
        if process is not None:
            self._process_to_car.pop(process, None)

        self.tracer.log(
            car.car_id,
            "УХОД",
            f"В системе: {total_time:.2f} мин",
        )
        self._sync_metrics()
        self._maybe_finish()

    def _body_stage(self, car: Car) -> simpy.events.Generator:
        """Кузовной ремонт с обработкой вытеснения.

        Цикл нужен потому, что после прерывания автомобиль должен снова
        запросить место, сохранив ``body_remaining``.
        """

        while car.body_remaining > TIME_EPSILON:
            request = self.body_shop.request(
                priority=car.priority,
                # Только Модель 1 имеет право вытеснять. Для Модели 2
                # preempt=False, иначе SimPy мог бы вытеснять "равных".
                preempt=car.is_model_1,
            )
            self._sync_metrics()

            if not request.triggered:
                self.tracer.log(
                    car.car_id,
                    "ОЖИДАНИЕ КУЗОВНОГО РЕМОНТА",
                    f"Осталось: {car.body_remaining:.2f} мин",
                )

            segment_start: float | None = None

            try:
                # Контекстный менеджер гарантирует release при любом выходе,
                # включая исключение SimPy.Interrupt.
                with request:
                    yield request
                    segment_start = float(self.env.now)
                    self._sync_metrics()
                    self.tracer.log(
                        car.car_id,
                        "НАЧАЛО КУЗОВНОГО РЕМОНТА",
                        f"Осталось: {car.body_remaining:.2f} мин",
                    )

                    yield self.env.timeout(car.body_remaining)

                    # Успешное завершение: весь остаток отработан.
                    spent = self.env.now - segment_start
                    car.body_service_total += spent
                    car.body_remaining = 0.0

            except simpy.Interrupt as exc:
                cause = exc.cause
                if not isinstance(cause, Preempted):
                    # Чужие прерывания не должны молча теряться.
                    raise

                if segment_start is None:
                    # Прерывание пришло, пока автомобиль стоял в очереди.
                    # В корректной модели этого не происходит для Модели 2,
                    # но обработаем сценарий без потери состояния.
                    spent = 0.0
                else:
                    spent = max(0.0, self.env.now - segment_start)

                car.body_service_total += spent
                car.body_remaining = max(0.0, car.body_remaining - spent)

                preemptor = self._process_to_car.get(cause.by)
                preemptor_id = preemptor.car_id if preemptor is not None else "неизвестен"

                if car.body_remaining > TIME_EPSILON:
                    self.monitor.record_preemption(car.body_remaining)
                    self.monitor.record_preemption_event(
                        time=self.env.now,
                        preempted_car_id=car.car_id,
                        preempted_model=int(car.model),
                        preemptor_car_id=preemptor_id,
                        preemptor_model=int(preemptor.model) if preemptor is not None else 0,
                        remaining_time=car.body_remaining,
                    )
                    self.tracer.log(
                        preemptor_id,
                        "ВЫТЕСНЕНИЕ",
                        f"Прерван: {car.car_id} "
                        f"(Осталось: {car.body_remaining:.2f} мин)",
                    )
                    self.tracer.log(
                        car.car_id,
                        "ПРЕРЫВАНИЕ",
                        f"Остаток ремонта сохранён: {car.body_remaining:.2f} мин",
                    )
                else:
                    # Ремонт фактически завершился в тот же момент времени.
                    # Повторный цикл не нужен, прерывание не учитываем как
                    # потерю работы.
                    self.tracer.log(
                        car.car_id,
                        "ПРЕРЫВАНИЕ",
                        "Ремонт уже завершён, повтор не требуется",
                    )
            finally:
                # После release/прерывания обновляем очередь и занятость.
                self._sync_metrics()

        self.tracer.log(
            car.car_id,
            "КУЗОВНОЙ РЕМОНТ ЗАВЕРШЁН",
            f"Фактически: {car.body_service_total:.2f} мин",
        )

    def _paint_stage(self, car: Car) -> simpy.events.Generator:
        """Покраска в общей FIFO-очереди."""

        request = self.paint_shop.request()
        self._sync_metrics()

        if not request.triggered:
            self.tracer.log(
                car.car_id,
                "ОЖИДАНИЕ ПОКРАСКИ",
                f"Очередь покраски: {len(self.paint_shop.queue)}",
            )

        with request:
            yield request
            self._sync_metrics()
            self.tracer.log(
                car.car_id,
                "НАЧАЛО ПОКРАСКИ",
                f"Плановое время: {car.paint_duration:.2f} мин",
            )
            yield self.env.timeout(car.paint_duration)

        self._sync_metrics()
        self.tracer.log(car.car_id, "ПОКРАСКА ЗАВЕРШЕНА")

    # ------------------------------------------------------------------
    # Служебные методы
    # ------------------------------------------------------------------
    def _sync_metrics(self) -> None:
        """Синхронизирует непрерывные метрики с состоянием ресурсов SimPy.

        ``queue`` содержит только ожидающие заявки, ``users`` -- только уже
        занимающие место. Вызов выполняется после каждого изменения состояния.
        """

        self.monitor.update_body_queue(len(self.body_shop.queue))
        self.monitor.update_body_busy(len(self.body_shop.users))
        self.monitor.update_paint_busy(len(self.paint_shop.users))

    def _maybe_finish(self) -> None:
        """Завершает прогон, когда приём закрыт и все автомобили обслужены."""

        if (
            self.arrivals_running == 0
            and self.active_cars == 0
            and not self._drained.triggered
        ):
            self._drained.succeed()

    # ------------------------------------------------------------------
    # Запуск
    # ------------------------------------------------------------------
    def _stop_generator(self) -> simpy.events.Generator:
        """Генератор для жёсткой остановки по sim_time."""

        yield self.env.timeout(self.config.sim_time)
        self._stop_requested.succeed()
        # Прерываем все активные процессы автомобилей
        for process in list(self._car_processes):
            if process.is_alive:
                process.interrupt()

    def run(self, start_arrivals: bool = True) -> SimulationResults:
        """Запускает модель.

        :param start_arrivals: если ``False``, случайные генераторы приходов не
            создаются.
        """

        if self._started:
            raise RuntimeError("Один экземпляр WorkshopModel можно запустить только один раз.")
        self._started = True

        self._sync_metrics()

        if start_arrivals:
            self.arrivals_running = 2
            self._arrival_processes.append(
                self.env.process(
                    self._arrival_generator(ModelType.MODEL_1, self.config.mean_arrival_m1)
                )
            )
            self._arrival_processes.append(
                self.env.process(
                    self._arrival_generator(ModelType.MODEL_2, self.config.mean_arrival_m2)
                )
            )
        else:
            self.arrivals_running = 0

        if self.config.drain:
            self._maybe_finish()
            self.env.run(until=self._drained)
            final_time = self.env.now
            self._finished = True

            if self.active_cars != 0:
                raise RuntimeError(
                    f"Прогон завершился, но активных автомобилей осталось: {self.active_cars}"
                )

            arrived_count = self.monitor.arrival_count
            served_count = self.monitor.count_serviced_m1 + self.monitor.count_serviced_m2
            if arrived_count != served_count:
                raise RuntimeError(
                    "Нарушен баланс автомобилей: "
                    f"прибыло {arrived_count}, обслужено {served_count}."
                )

            self._results = self.monitor.compile_results(final_time=final_time, drain_enabled=True)
            return self._results
        else:
            # Жёсткая остановка по sim_time
            self.env.process(self._stop_generator())
            self.env.run(until=self._stop_requested)
            final_time = self.config.sim_time
            self._finished = True

            # Считаем незавершённые как цензурированные
            if not self._censored_recorded:
                for car in self._cars:
                    if car.exit_time is None:
                        self.monitor.record_censored(int(car.model))
                self._censored_recorded = True

            arrived_count = self.monitor.arrival_count
            served_count = self.monitor.count_serviced_m1 + self.monitor.count_serviced_m2
            # При жёсткой остановке часть может быть не обслужена - это нормально
            if served_count > arrived_count:
                raise RuntimeError("Обслужено больше, чем прибыло.")

            self._results = self.monitor.compile_results(final_time=final_time, drain_enabled=False)
            return self._results
