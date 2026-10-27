"""
sto_model.py - Имитационная модель СТО на базе библиотеки SimPy.
"""

import random
import simpy
from typing import Any
from core.base import ISimulationModel, SimulationArtifacts


class AutoRepairShopModel(ISimulationModel):
    """
    Модель авторемонтного участка:
    - 3 поста кузовного ремонта с приоритетным вытеснением (Модель 1 > Модель 2).
    - 1 покрасочная камера с очередью FIFO.
    """

    def __init__(self, config: dict[str, Any], logger):
        self.cfg = config
        self.logger = logger

        # Инициализация независимых RNG-потоков для воспроизводимости
        base_seed = self.cfg["simulation"]["seed"]
        self.rng_arr_1 = random.Random(base_seed + 101)
        self.rng_arr_2 = random.Random(base_seed + 102)
        self.rng_body = random.Random(base_seed + 103)
        self.rng_paint = random.Random(base_seed + 104)

        # Окружение и ресурсы
        self.env: simpy.Environment = None
        self.body_shop: simpy.PreemptiveResource = None
        self.paint_shop: simpy.Resource = None

        # Управление завершением
        self.accepting_arrivals: bool = True
        self.active_cars_count: int = 0

        # Контейнеры откликов
        self.timeseries_log: list[dict[str, Any]] = []
        self.cars_log: list[dict[str, Any]] = []

        # Аддитивные счетчики
        self.finished_model_1: int = 0
        self.finished_model_2: int = 0
        self.preemptions_model_2: int = 0

    def _sample_truncated_normal(
        self, rng: random.Random, mean: float, std: float, min_val: float = 0.1
    ) -> float:
        """Нормальное распределение с нижней границей отсечения (T > 0)."""
        val = rng.gauss(mean, std)
        return max(min_val, val)

    def _record_continuous_state(self) -> None:
        """Срез непрерывных откликов во времени."""
        self.timeseries_log.append({
            "timestamp": round(self.env.now, 4),
            "body_queue_length": len(self.body_shop.queue),
            "body_busy_places": self.body_shop.count,
            "paint_queue_length": len(self.paint_shop.queue),
            "paint_busy_places": self.paint_shop.count,
        })

    def _arrival_process(self, model_type: int) -> simpy.events.Process:
        """
        Поток приходов. Следующий приход планируется внутри текущего шага
        в полном соответствии с требованиями ТЗ.
        """
        rng = self.rng_arr_1 if model_type == 1 else self.rng_arr_2
        rate_key = f"model_{model_type}_mean_interval"
        mean_interval = self.cfg["arrival_rates"][rate_key]
        car_seq = 0

        while True:
            # Расчет межприходного времени (экспоненциальный закон)
            interval = rng.expovariate(1.0 / mean_interval)
            yield self.env.timeout(interval)

            if not self.accepting_arrivals:
                # Остановка генерации при включенном режиме дообслуживания
                break

            car_seq += 1
            car_id = f"Car_M{model_type}_{car_seq}"
            self.env.process(self._car_lifecycle(car_id, model_type))

    def _car_lifecycle(self, car_id: str, model_type: int) -> simpy.events.Process:
        """Жизненный цикл автомобиля на СТО."""
        self.active_cars_count += 1
        arrival_time = self.env.now
        self.logger.info(f"[{arrival_time:8.2f}] ВХОД: {car_id} прибыл на СТО.")

        # --- 1. ЭТАП КУЗОВНОГО РЕМОНТА ---
        # Модель 1: наивысший приоритет (0), preempt=True
        # Модель 2: низкий приоритет (1), preempt=False
        priority = 0 if model_type == 1 else 1
        can_preempt = (model_type == 1)

        cfg_body = self.cfg["service_times"]["body_repair"]
        work_remaining = self._sample_truncated_normal(
            self.rng_body, cfg_body["mean"], cfg_body["std"]
        )
        total_nominal_body_time = work_remaining

        body_wait_total = 0.0
        car_preemptions = 0

        while work_remaining > 0:
            queue_start = self.env.now
            self._record_continuous_state()

            with self.body_shop.request(priority=priority, preempt=can_preempt) as req:
                yield req
                body_wait_total += (self.env.now - queue_start)
                self._record_continuous_state()
                self.logger.info(
                    f"[{self.env.now:8.2f}] КУЗОВ: {car_id} занял пост. "
                    f"Осталось времени работы: {work_remaining:.2f}"
                )

                service_start = self.env.now
                try:
                    yield self.env.timeout(work_remaining)
                    # Успешное окончание кузовного ремонта
                    work_remaining = 0.0
                    self.logger.info(f"[{self.env.now:8.2f}] КУЗОВ: {car_id} завершил ремонт.")
                except simpy.Interrupt:
                    # Прерывание Модели 2 прибывшей Моделью 1
                    worked_duration = self.env.now - service_start
                    work_remaining -= worked_duration
                    car_preemptions += 1
                    self.preemptions_model_2 += 1
                    self.logger.warning(
                        f"[{self.env.now:8.2f}] ВЫТЕСНЕНИЕ! {car_id} прерван Моделью 1. "
                        f"Недоделано: {work_remaining:.2f}. Возврат в очередь."
                    )
            self._record_continuous_state()

        # --- 2. ЭТАП ПОКРАСКИ (Очередь FIFO) ---
        paint_queue_start = self.env.now
        self.logger.info(f"[{self.env.now:8.2f}] ПОКРАСКА: {car_id} встал в общую очередь.")
        self._record_continuous_state()

        with self.paint_shop.request() as paint_req:
            yield paint_req
            paint_wait_time = self.env.now - paint_queue_start
            self._record_continuous_state()
            self.logger.info(f"[{self.env.now:8.2f}] ПОКРАСКА: {car_id} заехал в камеру.")

            # Среднее пропорционально фактическому времени кузовного ремонта
            cfg_paint = self.cfg["service_times"]["paint"]
            paint_mean = total_nominal_body_time * cfg_paint["mean_ratio"]
            paint_duration = self._sample_truncated_normal(
                self.rng_paint, paint_mean, cfg_paint["std"]
            )

            yield self.env.timeout(paint_duration)
            self.logger.info(f"[{self.env.now:8.2f}] ПОКРАСКА: {car_id} завершена.")

        self._record_continuous_state()

        # --- 3. ВЫХОД И ФИКСАЦИЯ ДИСКРЕТНЫХ ОТКЛИКОВ ---
        exit_time = self.env.now
        total_time_in_sys = exit_time - arrival_time
        self.logger.info(
            f"[{exit_time:8.2f}] ВЫХОД: {car_id} покинул СТО. "
            f"Времени в системе: {total_time_in_sys:.2f}"
        )

        if model_type == 1:
            self.finished_model_1 += 1
        else:
            self.finished_model_2 += 1

        self.cars_log.append({
            "car_id": car_id,
            "model_type": model_type,
            "arrival_time": round(arrival_time, 4),
            "exit_time": round(exit_time, 4),
            "time_in_system": round(total_time_in_sys, 4),
            "body_wait_time": round(body_wait_total, 4),
            "body_work_time": round(total_nominal_body_time, 4),
            "paint_wait_time": round(paint_wait_time, 4),
            "paint_work_time": round(paint_duration, 4),
            "preemptions": car_preemptions,
        })

        self.active_cars_count -= 1

    def _cutoff_manager(self, horizon: float) -> simpy.events.Process:
        """Процесс прекращения доступа на СТО по достижении горизонта."""
        yield self.env.timeout(horizon)
        self.accepting_arrivals = False
        self.logger.info(
            f"\n{'='*70}\n[{self.env.now:8.2f}] ДОСТИГНУТ ГОРИЗОНТ СИМУЛЯЦИИ! "
            f"Вход закрыт, начинается дообслуживание...\n{'='*70}"
        )

    def build_and_run(self) -> SimulationArtifacts:
        """Конфигурирование графа процессов SimPy и запуск."""
        self.env = simpy.Environment()

        # Создание ресурсов
        self.body_shop = simpy.PreemptiveResource(
            self.env, capacity=self.cfg["resources"]["body_workstations"]
        )
        self.paint_shop = simpy.Resource(
            self.env, capacity=self.cfg["resources"]["paint_chambers"]
        )

        # Начальное состояние системы (t = 0)
        self._record_continuous_state()

        # Запуск параллельных генераторов приходов
        self.env.process(self._arrival_process(model_type=1))
        self.env.process(self._arrival_process(model_type=2))

        sim_time = float(self.cfg["simulation"]["sim_time"])
        drain_mode = bool(self.cfg["simulation"]["drain_mode"])

        if drain_mode:
            # Режим с дообслуживанием:
            # 1. Запускаем таймер прекращения приема
            self.env.process(self._cutoff_manager(sim_time))
            # 2. Выполняем симуляцию до полного опустошения очередей и освобождения постов
            self.env.run()
        else:
            # Режим строгого окончания: жесткий обрыв симуляции точно в sim_time
            self.env.run(until=sim_time)

        # Финальный срез непрерывных откликов
        self._record_continuous_state()

        final_duration = round(self.env.now, 4)
        summary = {
            "run_duration": final_duration,
            "finished_model_1": self.finished_model_1,
            "finished_model_2": self.finished_model_2,
            "total_serviced": self.finished_model_1 + self.finished_model_2,
            "preemptions_model_2": self.preemptions_model_2,
            "drain_mode_applied": drain_mode,
        }

        from core.responses_builder import ResponsesBuilder

        responses = []
        responses.extend(
            ResponsesBuilder.from_timeseries(
                self.timeseries_log,
                [
                    ("body_queue_length", "timestamp", "body_queue_length"),
                    ("body_busy_places", "timestamp", "body_busy_places"),
                    ("paint_queue_length", "timestamp", "paint_queue_length"),
                    ("paint_busy_places", "timestamp", "paint_busy_places"),
                ],
            )
        )
        responses.extend(
            ResponsesBuilder.from_cars_discrete_fixed(
                self.cars_log,
                x_col="exit_time",
                y_col="time_in_system",
                filter_col="model_type",
                specs=[
                    ("time_in_system_all", None),
                    ("time_in_system_model1", 1),
                    ("time_in_system_model2", 2),
                ],
            )
        )

        return SimulationArtifacts(
            summary=summary,
            timeseries=self.timeseries_log,
            cars=self.cars_log,
            responses=responses,
        )