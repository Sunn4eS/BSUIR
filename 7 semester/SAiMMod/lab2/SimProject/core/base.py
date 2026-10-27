"""
interfaces.py - Базовые интерфейсы и контракты системы симуляции.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Any

from core.responses import ResponseSpec


@dataclass(frozen=True)
class SimulationArtifacts:
    """Контейнер для собранных результатов симуляции."""
    summary: dict[str, Any]
    timeseries: list[dict[str, Any]]
    cars: list[dict[str, Any]]
    responses: tuple[ResponseSpec, ...] | list[ResponseSpec] = ()


class ISimulationModel(ABC):
    """Интерфейс, обязательный для реализации любой симуляционной моделью."""

    @abstractmethod
    def build_and_run(self) -> SimulationArtifacts:
        """
        Инициализирует окружение simpy, процессы и запускает расчет.
        :return: Структурированные артефакты прогона.
        """
        pass