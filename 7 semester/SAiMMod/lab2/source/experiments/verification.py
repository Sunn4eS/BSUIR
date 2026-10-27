"""Верификация модели по нескольким независимым репликациям.

Каждая репликация использует свой seed, но одинаковые остальные параметры.
По набору оценок строится накопленное среднее:

.. math::

    \\bar{Y}_k = \\frac{1}{k}\\sum_{i=1}^{k} Y_i.

Если модель и генератор ПСЧ корректны, кривая должна стабилизироваться.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from statistics import fmean

import pandas as pd

from config.model_config import WorkshopConfig
from experiments.runner import run_single
from simulation.monitors import SCALAR_RESPONSE_NAMES, SimulationResults


@dataclass(slots=True)
class VerificationReport:
    """Результаты серии репликаций и накопленные средние откликов."""

    base_config: WorkshopConfig
    seeds: list[int]
    results: list[SimulationResults]
    cumulative_means: dict[str, list[float]] = field(default_factory=dict)

    def to_dataframe(self) -> pd.DataFrame:
        """Возвращает таблицу "одна строка = одна репликация"."""

        rows: list[dict[str, float | int]] = []
        for index, (seed, result) in enumerate(
            zip(self.seeds, self.results), start=1
        ):
            row: dict[str, float | int] = {
                "replication": index,
                "seed": seed,
            }
            row.update(result.to_flat_dict())
            rows.append(row)
        return pd.DataFrame(rows)

    def cumulative_dataframe(self) -> pd.DataFrame:
        """Возвращает накопленные средние в длинном формате для графиков."""

        rows: list[dict[str, float | int | str]] = []
        for response_name, values in self.cumulative_means.items():
            for k, value in enumerate(values, start=1):
                rows.append(
                    {
                        "replication": k,
                        "response": response_name,
                        "cumulative_mean": value,
                    }
                )
        return pd.DataFrame(rows)


def run_verification(
    base_config: WorkshopConfig,
    replications: int = 10,
    *,
    seed_stride: int = 1,
) -> VerificationReport:
    """Выполняет ``replications`` прогонов с разными seed.

    :param base_config: конфигурация, общая для всех репликаций.
    :param replications: число репликаций, должно быть > 0.
    :param seed_stride: шаг изменения seed между репликациями.
    """

    if replications <= 0:
        raise ValueError("replications должно быть > 0.")
    if seed_stride == 0:
        raise ValueError("seed_stride не может быть нулём.")

    seeds = [
        base_config.seed + index * seed_stride
        for index in range(replications)
    ]
    results = [run_single(base_config, seed=seed) for seed in seeds]

    # Для каждого скалярного отклика строим последовательность средних:
    # сначала по одной репликации, затем по двум и т.д.
    cumulative_means: dict[str, list[float]] = {}
    for response_name in SCALAR_RESPONSE_NAMES:
        values = [float(getattr(result, response_name)) for result in results]
        running: list[float] = []
        for k in range(1, len(values) + 1):
            running.append(fmean(values[:k]))
        cumulative_means[response_name] = running

    return VerificationReport(
        base_config=base_config,
        seeds=seeds,
        results=results,
        cumulative_means=cumulative_means,
    )
