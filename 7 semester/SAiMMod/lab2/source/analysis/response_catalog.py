"""Единый реестр откликов модели.

Содержит названия, русские подписи, типы и единицы измерения для всех
8 откликов, а также служебных полей.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal


@dataclass(frozen=True)
class ResponseInfo:
    name: str
    label_ru: str
    rtype: Literal["continuous", "discrete", "count", "final", "meta"]
    unit: str = ""


RESPONSE_CATALOG: dict[str, ResponseInfo] = {
    "avg_body_queue_length": ResponseInfo("avg_body_queue_length", "Средняя длина очереди на кузов", "continuous", "авт."),
    "avg_busy_body_places": ResponseInfo("avg_busy_body_places", "Среднее число занятых кузовных мест", "continuous", "мест"),
    "avg_busy_paint_booths": ResponseInfo("avg_busy_paint_booths", "Среднее число занятых покрасочных камер", "continuous", "камер"),
    "avg_car_system_time": ResponseInfo("avg_car_system_time", "Среднее время автомобиля в системе", "discrete", "мин"),
    "serviced_model_1": ResponseInfo("serviced_model_1", "Обслужено автомобилей Модели 1", "count", "шт."),
    "serviced_model_2": ResponseInfo("serviced_model_2", "Обслужено автомобилей Модели 2", "count", "шт."),
    "preemptions_model_2": ResponseInfo("preemptions_model_2", "Прерываний обслуживания Модели 2", "count", "шт."),
    "total_run_time": ResponseInfo("total_run_time", "Длина прогона T_final", "final", "мин"),
}

RESPONSE_ORDER = [
    "avg_body_queue_length",
    "avg_busy_body_places",
    "avg_busy_paint_booths",
    "avg_car_system_time",
    "serviced_model_1",
    "serviced_model_2",
    "preemptions_model_2",
    "total_run_time",
]


def get_label(name: str) -> str:
    info = RESPONSE_CATALOG.get(name)
    if info is None:
        return name
    return info.label_ru


def get_info(name: str) -> ResponseInfo | None:
    return RESPONSE_CATALOG.get(name)
