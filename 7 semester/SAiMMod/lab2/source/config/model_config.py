"""Конфигурация имитационной модели участка СТО.

Все параметры собраны в одном неизменяемом dataclass. Это позволяет:
* явно видеть входные данные модели;
* валидировать их в одном месте;
* создавать независимые копии конфигурации для репликаций и параметрических
  экспериментов через :meth:`WorkshopConfig.clone_with`.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, replace
from typing import Any


@dataclass(frozen=True)
class WorkshopConfig:
    """Параметры одного прогона модели.

    Времена измеряются в минутах. Все распределения обслуживания задаются
    нормальным законом, а интервалы прихода -- экспоненциальным.
    """

    # --- Управляемые параметры оборудования ---
    num_body_places: int = 3  # Количество рабочих мест кузовного ремонта
    num_paint_booths: int = 1  # Количество покрасочных камер

    # --- Параметры входящих потоков ---
    mean_arrival_m1: float = 4.8  # Средний интервал прихода автомобилей Модели 1
    mean_arrival_m2: float = 8.0  # Средний интервал прихода автомобилей Модели 2

    # --- Параметры кузовного ремонта ---
    body_repair_mu: float = 20.0  # Математическое ожидание времени ремонта
    body_repair_sigma: float = 12.0  # Среднеквадратическое отклонение

    # --- Параметры покраски ---
    # Математическое ожидание покраски = paint_ratio * фактическое время кузова.
    paint_ratio: float = 0.5
    paint_sigma: float = 2.0  # Среднеквадратическое отклонение времени покраски

    # --- Параметры эксперимента ---
    sim_time: float = 480.0  # Время моделирования / окно приёма заявок
    seed: int = 42  # Зерно единственного генератора ПСЧ
    trace: bool = False  # Подробная трассировка событий в консоль
    drain: bool = True  # True: дообслужить текущих, новые не брать; False: жёсткая остановка по sim_time

    def __post_init__(self) -> None:
        """Проверяет корректность всех входных параметров.

        Ошибки обнаруживаются сразу при создании конфигурации, а не в середине
        имитационного прогона.
        """

        if not isinstance(self.num_body_places, int) or self.num_body_places <= 0:
            raise ValueError("num_body_places должно быть целым числом > 0.")
        if not isinstance(self.num_paint_booths, int) or self.num_paint_booths <= 0:
            raise ValueError("num_paint_booths должно быть целым числом > 0.")

        positive_parameters = {
            "mean_arrival_m1": self.mean_arrival_m1,
            "mean_arrival_m2": self.mean_arrival_m2,
            "body_repair_mu": self.body_repair_mu,
            "paint_ratio": self.paint_ratio,
            "sim_time": self.sim_time,
        }
        for name, value in positive_parameters.items():
            if not math.isfinite(value) or value <= 0.0:
                raise ValueError(f"{name} должно быть конечным числом > 0.")

        non_negative_parameters = {
            "body_repair_sigma": self.body_repair_sigma,
            "paint_sigma": self.paint_sigma,
        }
        for name, value in non_negative_parameters.items():
            if not math.isfinite(value) or value < 0.0:
                raise ValueError(f"{name} должно быть конечным числом >= 0.")

        if not isinstance(self.seed, int):
            raise ValueError("seed должно быть целым числом.")
        if not isinstance(self.trace, bool):
            raise ValueError("trace должно быть логическим значением.")
        if not isinstance(self.drain, bool):
            raise ValueError("drain должно быть логическим значением.")

    def clone_with(self, **kwargs: Any) -> "WorkshopConfig":
        """Возвращает копию конфигурации с заменой указанных полей.

        Используется в репликациях (замена ``seed``) и в параметрических
        экспериментах.
        """

        return replace(self, **kwargs)

    def to_dict(self) -> dict[str, Any]:
        """Возвращает словарь со всеми параметрами конфигурации."""

        from dataclasses import asdict

        return asdict(self)

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> "WorkshopConfig":
        """Создаёт конфигурацию из словаря."""

        return cls(**data)
