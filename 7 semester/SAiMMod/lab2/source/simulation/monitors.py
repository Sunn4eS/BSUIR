"""Сборщики откликов имитационной модели.

Модуль содержит три сущности:

* :class:`ContinuousVariableTracker` -- хранит историю ступенчатой функции и
  вычисляет её интегральное среднее по времени;
* :class:`SimulationResults` -- неизменяемый по смыслу контейнер всех откликов
  одного прогона и сырых рядов для графиков;
* :class:`WorkshopMonitor` -- фасад, через который модель сообщает о событиях.
"""

from __future__ import annotations

import math
import statistics
from dataclasses import dataclass, field
from typing import Any, Final

import simpy

# Имена восьми скалярных откликов, перечисленных в задании.
# Порядок используется в таблицах экспериментов и на графиках.
SCALAR_RESPONSE_NAMES: Final[tuple[str, ...]] = (
    "avg_body_queue_length",
    "avg_busy_body_places",
    "avg_busy_paint_booths",
    "avg_car_system_time",
    "serviced_model_1",
    "serviced_model_2",
    "preemptions_model_2",
    "total_run_time",
)


class ContinuousVariableTracker:
    """Отслеживает непрерывный во времени процесс ``X(t)``.

    Значение считается кусочно-постоянным: между двумя изменениями оно
    сохраняется. Поэтому интеграл по времени вычисляется как сумма площадей
    прямоугольников. История хранится в виде пар ``(момент времени, значение)``.
    """

    def __init__(self, env: simpy.Environment, initial_value: float = 0.0) -> None:
        if not math.isfinite(initial_value):
            raise ValueError("initial_value должно быть конечным числом.")

        self.env = env
        self.current_value = float(initial_value)
        # Первая точка обязательно соответствует началу прогона t=0.
        self.history: list[tuple[float, float]] = [(0.0, self.current_value)]

    def set_value(self, new_value: float, at: float | None = None) -> None:
        """Фиксирует новое значение в момент времени ``at`` (по умолчанию env.now).

        Повторная установка того же значения не создаёт лишнюю точку истории.
        Время не может идти назад -- это защищает интеграл от некорректных
        вызовов.
        """

        if not math.isfinite(new_value):
            raise ValueError("Значение непрерывной переменной должно быть конечным.")
        if at is None:
            at = self.env.now
        if at < 0.0:
            raise ValueError("Время не может быть отрицательным.")
        if at < self.history[-1][0]:
            raise ValueError("История непрерывной переменной должна быть неубывающей.")

        if new_value == self.current_value:
            return

        self.current_value = float(new_value)
        self.history.append((float(at), float(new_value)))

    def get_area(self, final_time: float) -> float:
        """Возвращает площадь под ступенчатой функцией на отрезке ``[0, final_time]``."""

        if final_time <= 0.0:
            return 0.0

        total_area = 0.0
        for index, (t_start, value) in enumerate(self.history):
            if t_start >= final_time:
                break

            # Конец текущего интервала -- следующее изменение или final_time.
            if index + 1 < len(self.history):
                t_end = min(self.history[index + 1][0], final_time)
            else:
                t_end = final_time

            if t_end > t_start:
                total_area += value * (t_end - t_start)

        return total_area

    def get_time_weighted_average(self, final_time: float) -> float:
        """Вычисляет ``(1 / T_final) * integral_0^T_final X(t) dt``.

        Важно: если последнее изменение произошло раньше ``final_time``, площадь
        от последнего события до конца прогона всё равно добавляется.
        """

        if final_time <= 0.0:
            return 0.0
        return self.get_area(final_time) / final_time


@dataclass
class SimulationResults:
    """Результаты одного прогона.

    Поля сгруппированы так же, как отклики в задании: непрерывные, дискретный,
    аддитивные и финальный. Дополнительно сохраняются сырые временные ряды,
    необходимые для ступенчатых графиков и проверки инвариантов.
    """

    # --- Непрерывные отклики (интегральные средние) ---
    avg_body_queue_length: float
    avg_busy_body_places: float
    avg_busy_paint_booths: float

    # --- Дискретный отклик: время пребывания автомобилей в системе ---
    car_system_times: list[float] = field(default_factory=list)
    avg_car_system_time: float = 0.0

    # --- Аддитивные отклики ---
    serviced_model_1: int = 0
    serviced_model_2: int = 0
    preemptions_model_2: int = 0

    # --- Финальный отклик: длина прогона с дообслуживанием ---
    total_run_time: float = 0.0

    # --- Сырые ряды для графиков ---
    raw_body_queue: list[tuple[float, float]] = field(default_factory=list)
    raw_body_busy: list[tuple[float, float]] = field(default_factory=list)
    raw_paint_busy: list[tuple[float, float]] = field(default_factory=list)

    # --- Дополнительные данные для верификации и анализа ---
    entry_times: list[float] = field(default_factory=list)
    exit_times: list[float] = field(default_factory=list)
    preemption_times: list[float] = field(default_factory=list)
    preemption_remaining_times: list[float] = field(default_factory=list)
    car_records: list[dict[str, Any]] = field(default_factory=list)
    preemption_events: list[dict[str, Any]] = field(default_factory=list)
    drain_enabled: bool = True
    censored_cars: int = 0
    censored_model_1: int = 0
    censored_model_2: int = 0
    body_queue_history: list[tuple[float, float]] = field(default_factory=list)
    body_busy_history: list[tuple[float, float]] = field(default_factory=list)
    paint_busy_history: list[tuple[float, float]] = field(default_factory=list)

    def to_flat_dict(self) -> dict[str, float | int]:
        """Возвращает скалярные отклики в виде словаря для pandas/pytest."""

        flat: dict[str, float | int] = {
            name: getattr(self, name) for name in SCALAR_RESPONSE_NAMES
        }
        flat["arrived_count"] = len(self.entry_times)
        flat["std_car_system_time"] = (
            statistics.stdev(self.car_system_times)
            if len(self.car_system_times) > 1
            else 0.0
        )
        flat["censored_cars"] = int(self.censored_cars)
        flat["censored_model_1"] = int(self.censored_model_1)
        flat["censored_model_2"] = int(self.censored_model_2)
        flat["drain_enabled"] = 1 if self.drain_enabled else 0
        return flat


class WorkshopMonitor:
    """Фасад для регистрации событий и сборки результатов прогона."""

    def __init__(self, env: simpy.Environment) -> None:
        self.env = env

        # Непрерывные процессы. Начальное состояние по заданию -- всё пусто.
        self.body_queue_tracker = ContinuousVariableTracker(env, initial_value=0.0)
        self.body_busy_tracker = ContinuousVariableTracker(env, initial_value=0.0)
        self.paint_busy_tracker = ContinuousVariableTracker(env, initial_value=0.0)

        # Дискретные и аддитивные отклики.
        self.system_times: list[float] = []
        self.entry_times: list[float] = []
        self.exit_times: list[float] = []
        self.preemption_times: list[float] = []
        self.preemption_remaining_times: list[float] = []
        self.arrival_count: int = 0
        self.count_serviced_m1: int = 0
        self.count_serviced_m2: int = 0
        self.count_preemptions_m2: int = 0
        self.car_records: list[dict[str, Any]] = []
        self.preemption_events: list[dict[str, Any]] = []
        self.censored_cars: int = 0
        self.censored_model_1: int = 0
        self.censored_model_2: int = 0

    # --- Обновление непрерывных процессов ---------------------------------
    def update_body_queue(self, length: int) -> None:
        """Обновляет длину очереди на кузовной ремонт."""

        self.body_queue_tracker.set_value(float(length))

    def update_body_busy(self, busy_count: int) -> None:
        """Обновляет число занятых кузовных мест."""

        self.body_busy_tracker.set_value(float(busy_count))

    def update_paint_busy(self, busy_count: int) -> None:
        """Обновляет число занятых покрасочных камер."""

        self.paint_busy_tracker.set_value(float(busy_count))

    # --- Регистрация событий ----------------------------------------------
    def record_arrival(self, model_type: int, entry_time: float | None = None) -> None:
        """Регистрирует приход автомобиля в систему."""

        if model_type not in (1, 2):
            raise ValueError(f"Неизвестный тип автомобиля: {model_type}")
        if entry_time is None:
            entry_time = self.env.now
        self.arrival_count += 1
        self.entry_times.append(float(entry_time))

    def record_car_finished(
        self,
        model_type: int,
        total_time_in_system: float,
        exit_time: float | None = None,
    ) -> None:
        """Регистрирует завершение полного цикла автомобиля.

        :param model_type: 1 для Модели 1, 2 для Модели 2.
        :param total_time_in_system: время от входа до выхода.
        :param exit_time: момент выхода; по умолчанию текущее время модели.
        """

        if model_type not in (1, 2):
            raise ValueError(f"Неизвестный тип автомобиля: {model_type}")
        if total_time_in_system < 0.0:
            raise ValueError("Время в системе не может быть отрицательным.")

        if exit_time is None:
            exit_time = self.env.now
        self.system_times.append(float(total_time_in_system))
        self.exit_times.append(float(exit_time))

        if model_type == 1:
            self.count_serviced_m1 += 1
        else:
            self.count_serviced_m2 += 1

    def record_preemption(self, remaining_time: float = 0.0) -> None:
        """Регистрирует прерывание обслуживания Модели 2.

        :param remaining_time: сколько времени ремонта осталось на момент
            прерывания. Значение сохраняется для проверок и анализа.
        """

        if not math.isfinite(remaining_time) or remaining_time < 0.0:
            raise ValueError("remaining_time должно быть конечным числом >= 0.")

        self.count_preemptions_m2 += 1
        self.preemption_times.append(self.env.now)
        self.preemption_remaining_times.append(float(remaining_time))

    def record_preemption_event(
        self,
        time: float,
        preempted_car_id: str,
        preempted_model: int,
        preemptor_car_id: str,
        preemptor_model: int,
        remaining_time: float,
    ) -> None:
        """Регистрирует детальную информацию о вытеснении."""

        if not math.isfinite(remaining_time) or remaining_time < 0.0:
            raise ValueError("remaining_time должно быть конечным числом >= 0.")

        self.preemption_events.append(
            {
                "time": float(time),
                "preempted_car_id": preempted_car_id,
                "preempted_model": int(preempted_model),
                "preemptor_car_id": preemptor_car_id,
                "preemptor_model": int(preemptor_model),
                "remaining_time": float(remaining_time),
            }
        )

    def record_car_record(self, record: dict[str, Any]) -> None:
        """Сохраняет запись об автомобиле для экспорта."""

        self.car_records.append(record)

    def record_censored(self, model_type: int) -> None:
        """Регистрирует цензурированный (незавершённый) автомобиль."""

        if model_type not in (1, 2):
            raise ValueError(f"Неизвестный тип автомобиля: {model_type}")

        self.censored_cars += 1
        if model_type == 1:
            self.censored_model_1 += 1
        else:
            self.censored_model_2 += 1

    # --- Финализация -------------------------------------------------------
    def compile_results(
        self,
        final_time: float | None = None,
        drain_enabled: bool = True,
    ) -> SimulationResults:
        """Собирает все отклики после завершения прогона."""

        if final_time is None:
            final_time = self.env.now

        avg_q_body = self.body_queue_tracker.get_time_weighted_average(final_time)
        avg_b_body = self.body_busy_tracker.get_time_weighted_average(final_time)
        avg_b_paint = self.paint_busy_tracker.get_time_weighted_average(final_time)

        avg_sys_time = (
            statistics.fmean(self.system_times) if self.system_times else 0.0
        )

        return SimulationResults(
            avg_body_queue_length=avg_q_body,
            avg_busy_body_places=avg_b_body,
            avg_busy_paint_booths=avg_b_paint,
            car_system_times=list(self.system_times),
            avg_car_system_time=avg_sys_time,
            serviced_model_1=self.count_serviced_m1,
            serviced_model_2=self.count_serviced_m2,
            preemptions_model_2=self.count_preemptions_m2,
            total_run_time=float(final_time),
            raw_body_queue=list(self.body_queue_tracker.history),
            raw_body_busy=list(self.body_busy_tracker.history),
            raw_paint_busy=list(self.paint_busy_tracker.history),
            entry_times=list(self.entry_times),
            exit_times=list(self.exit_times),
            preemption_times=list(self.preemption_times),
            preemption_remaining_times=list(self.preemption_remaining_times),
            car_records=list(self.car_records),
            preemption_events=list(self.preemption_events),
            drain_enabled=bool(drain_enabled),
            censored_cars=self.censored_cars,
            censored_model_1=self.censored_model_1,
            censored_model_2=self.censored_model_2,
            body_queue_history=list(self.body_queue_tracker.history),
            body_busy_history=list(self.body_busy_tracker.history),
            paint_busy_history=list(self.paint_busy_tracker.history),
        )
