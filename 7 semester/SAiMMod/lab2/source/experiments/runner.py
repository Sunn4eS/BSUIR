"""Одиночный запуск имитационной модели."""

from __future__ import annotations

from config.model_config import WorkshopConfig
from simulation.monitors import SimulationResults
from simulation.workshop_model import WorkshopModel


def run_single(
    config: WorkshopConfig,
    *,
    seed: int | None = None,
    start_arrivals: bool = True,
) -> SimulationResults:
    """Выполняет один прогон и возвращает все отклики.

    :param config: базовая конфигурация.
    :param seed: если задан, заменяет ``config.seed`` (удобно для репликаций).
    :param start_arrivals: ``False`` отключает случайные потоки приходов; режим
        используется детерминированными тестами.
    """

    run_config = config.clone_with(seed=seed) if seed is not None else config
    model = WorkshopModel(run_config)
    return model.run(start_arrivals=start_arrivals)
