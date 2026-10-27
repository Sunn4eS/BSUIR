"""Параметрический скан откликов модели.

Скан выполняет серию прогонов для каждого значения выбранного параметра и
возвращает единый ``pandas.DataFrame``. По нему затем строятся зависимости
``Y = f(X)`` с доверительными интервалами.
"""

from __future__ import annotations

import math
from dataclasses import fields
from statistics import NormalDist, fmean, stdev
from typing import Sequence

import pandas as pd

from config.model_config import WorkshopConfig
from experiments.runner import run_single
from simulation.monitors import SCALAR_RESPONSE_NAMES


def _coerce_parameter_value(
    parameter: str,
    value: float,
    base_config: WorkshopConfig,
) -> int | float:
    """Приводит значение сканируемого параметра к типу поля конфигурации."""

    current = getattr(base_config, parameter)
    if isinstance(current, bool):
        return bool(value)
    if isinstance(current, int):
        numeric = float(value)
        if not numeric.is_integer():
            raise ValueError(
                f"Параметр {parameter} целочисленный, получено {value!r}."
            )
        return int(numeric)
    return float(value)


def run_sweep(
    base_config: WorkshopConfig,
    parameter: str,
    values: Sequence[float],
    seeds_per_point: int = 10,
    *,
    seed_stride: int = 1,
) -> pd.DataFrame:
    """Выполняет параметрический скан.

    :param base_config: базовая конфигурация.
    :param parameter: имя поля :class:`WorkshopConfig`, например
        ``"mean_arrival_m1"``.
    :param values: значения параметра (например, ``[5, 10, 15, 20, 25]``).
    :param seeds_per_point: число независимых репликаций на каждое значение.
    :param seed_stride: шаг между seed внутри точки.
    :return: таблица, где каждая строка -- один прогон.
    """

    field_names = {field.name for field in fields(WorkshopConfig)}
    if parameter not in field_names:
        raise ValueError(
            f"Неизвестный параметр {parameter!r}. "
            f"Доступны: {', '.join(sorted(field_names))}."
        )
    if parameter in {"seed", "trace"}:
        raise ValueError(
            "Параметры seed и trace управляются экспериментом и не сканируются."
        )
    if seeds_per_point <= 0:
        raise ValueError("seeds_per_point должно быть > 0.")
    if seed_stride == 0:
        raise ValueError("seed_stride не может быть нулём.")

    sweep_values = list(values)
    if not sweep_values:
        raise ValueError("Список значений параметра не может быть пустым.")

    rows: list[dict[str, float | int | bool]] = []
    for value in sweep_values:
        coerced_value = _coerce_parameter_value(parameter, value, base_config)

        for replication in range(seeds_per_point):
            seed = base_config.seed + replication * seed_stride
            config = base_config.clone_with(
                **{parameter: coerced_value, "seed": seed}
            )
            result = run_single(config)

            # Сохраняем все параметры конфигурации: это делает выгрузку
            # самодостаточной и удобной для последующего анализа.
            row: dict[str, float | int | bool] = {
                field.name: getattr(config, field.name)
                for field in fields(WorkshopConfig)
            }
            row["replication"] = replication
            row.update(result.to_flat_dict())
            rows.append(row)

    return pd.DataFrame(rows)


def aggregate_sweep(
    dataframe: pd.DataFrame,
    parameter: str,
    response_name: str,
    *,
    confidence_level: float = 0.95,
) -> pd.DataFrame:
    """Агрегирует результаты скана: среднее, стандартное отклонение и CI.

    Используется 95%-й доверительный интервал на основе нормального
    приближения: ``mean ± z * std / sqrt(n)``.
    """

    if parameter not in dataframe.columns:
        raise ValueError(f"В таблице нет колонки параметра {parameter!r}.")
    if response_name not in dataframe.columns:
        raise ValueError(f"В таблице нет колонки отклика {response_name!r}.")
    if not 0.0 < confidence_level < 1.0:
        raise ValueError("confidence_level должен находиться в интервале (0, 1).")

    z_value = NormalDist().inv_cdf(0.5 + confidence_level / 2.0)
    aggregated_rows: list[dict[str, float | int]] = []

    for value, group in dataframe.groupby(parameter, sort=True):
        raw_values = group[response_name].astype(float).dropna().tolist()
        n = len(raw_values)
        if n == 0:
            continue

        mean = fmean(raw_values)
        std = stdev(raw_values) if n > 1 else 0.0
        half_width = z_value * std / math.sqrt(n) if n > 1 else 0.0

        aggregated_rows.append(
            {
                parameter: value,
                "mean": mean,
                "std": std,
                "count": n,
                "ci_low": mean - half_width,
                "ci_high": mean + half_width,
            }
        )

    return pd.DataFrame(aggregated_rows)


# Явно перечисляем отклики, чтобы CLI мог строить графики по всем сразу.
SWEEP_RESPONSE_NAMES = SCALAR_RESPONSE_NAMES
