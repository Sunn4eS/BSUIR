"""Построение графиков по результатам имитационных экспериментов."""

from __future__ import annotations

from collections.abc import Sequence
from pathlib import Path
from statistics import fmean

import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.figure import Figure

from experiments.sweep_runner import aggregate_sweep
from experiments.verification import VerificationReport
from simulation.monitors import SCALAR_RESPONSE_NAMES, SimulationResults

RESPONSE_LABELS: dict[str, str] = {
    "avg_body_queue_length": "Средняя длина очереди на кузов",
    "avg_busy_body_places": "Среднее число занятых кузовных мест",
    "avg_busy_paint_booths": "Среднее число занятых покрасочных камер",
    "avg_car_system_time": "Среднее время автомобиля в системе, мин",
    "serviced_model_1": "Обслужено автомобилей Модели 1",
    "serviced_model_2": "Обслужено автомобилей Модели 2",
    "preemptions_model_2": "Прерываний обслуживания Модели 2",
    "total_run_time": "Длина прогона T_final, мин",
}


def _save_figure(figure: Figure, output_path: str | Path | None) -> None:
    """Сохраняет график, если указан путь; родительские каталоги создаются."""

    if output_path is None:
        return
    path = Path(output_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    figure.savefig(path, dpi=150, bbox_inches="tight")


def _step_xy(
    history: list[tuple[float, float]],
    final_time: float,
) -> tuple[list[float], list[float]]:
    """Дополняет историю последней точкой до ``final_time`` для графика."""

    if not history:
        return [0.0, final_time], [0.0, 0.0]

    times = [float(t) for t, _ in history]
    values = [float(value) for _, value in history]

    # Последнее состояние действует до конца прогона, даже если изменений
    # больше не было.
    if final_time > times[-1]:
        times.append(float(final_time))
        values.append(values[-1])

    return times, values


def plot_continuous_states(
    results: SimulationResults,
    output_path: str | Path | None = None,
) -> Figure:
    """Строит ступенчатые графики трёх непрерывных откликов."""

    figure, axes = plt.subplots(3, 1, figsize=(11, 8), sharex=True)
    final_time = results.total_run_time

    series = (
        (results.raw_body_queue, "Длина очереди на кузов", "tab:blue"),
        (results.raw_body_busy, "Занято кузовных мест", "tab:orange"),
        (results.raw_paint_busy, "Занято покрасочных камер", "tab:green"),
    )

    for axis, (history, label, color) in zip(axes, series):
        times, values = _step_xy(history, final_time)
        axis.step(times, values, where="post", color=color, linewidth=1.6)
        axis.set_ylabel(label)
        axis.grid(True, alpha=0.3)
        axis.set_ylim(bottom=0.0)

    axes[-1].set_xlabel("Время, мин")
    axes[0].set_title(
        f"Непрерывные состояния СТО (T_final = {final_time:.2f} мин)"
    )
    figure.tight_layout()
    _save_figure(figure, output_path)
    return figure


def _cumulative_means(
    results: Sequence[SimulationResults],
) -> dict[str, list[float]]:
    """Считает накопленные средние для набора результатов."""

    cumulative: dict[str, list[float]] = {}
    for response_name in SCALAR_RESPONSE_NAMES:
        values = [float(getattr(result, response_name)) for result in results]
        running: list[float] = []
        for k in range(1, len(values) + 1):
            running.append(fmean(values[:k]))
        cumulative[response_name] = running
    return cumulative


def plot_verification(
    results: VerificationReport | Sequence[SimulationResults],
    output_path: str | Path | None = None,
) -> Figure:
    """Показывает реализацию процесса и стабилизацию накопленных средних.

    Допускаются оба варианта вызова:

    * ``plot_verification(report)`` -- когда уже есть :class:`VerificationReport`;
    * ``plot_verification(results_list)`` -- когда передан обычный список
      результатов репликаций.
    """

    if isinstance(results, VerificationReport):
        result_list = results.results
        seeds = results.seeds
        cumulative_means = results.cumulative_means
    else:
        result_list = list(results)
        seeds = list(range(1, len(result_list) + 1))
        cumulative_means = _cumulative_means(result_list)

    if not result_list:
        raise ValueError("Для построения графика нужна хотя бы одна репликация.")

    figure, axes = plt.subplots(2, 2, figsize=(14, 9))
    first = result_list[0]
    final_time = first.total_run_time

    # 1. Реализации длины очереди на кузов по всем репликациям.
    for index, result in enumerate(result_list):
        times, values = _step_xy(result.raw_body_queue, result.total_run_time)
        axes[0, 0].step(
            times,
            values,
            where="post",
            color="tab:blue",
            alpha=1.0 if index == 0 else 0.25,
            linewidth=1.6 if index == 0 else 0.9,
        )
    axes[0, 0].set_title("Реализации Q_body(t) по репликациям")
    axes[0, 0].set_xlabel("Время, мин")
    axes[0, 0].set_ylabel("Длина очереди")
    axes[0, 0].grid(True, alpha=0.3)

    # 2. Занятость кузова и покраски в первой репликации.
    body_times, body_values = _step_xy(first.raw_body_busy, final_time)
    paint_times, paint_values = _step_xy(first.raw_paint_busy, final_time)
    axes[0, 1].step(
        body_times, body_values, where="post", label="Кузов", color="tab:orange"
    )
    axes[0, 1].step(
        paint_times, paint_values, where="post", label="Покраска", color="tab:green"
    )
    axes[0, 1].set_title("Занятость постов, репликация 1")
    axes[0, 1].set_xlabel("Время, мин")
    axes[0, 1].set_ylabel("Число занятых мест")
    axes[0, 1].legend()
    axes[0, 1].grid(True, alpha=0.3)

    # 3. Накопленное среднее времени в системе.
    replications = list(range(1, len(result_list) + 1))
    system_time_values = [
        result.avg_car_system_time for result in result_list
    ]
    cumulative_system_time = cumulative_means["avg_car_system_time"]

    axes[1, 0].plot(
        replications,
        system_time_values,
        marker="o",
        linestyle="none",
        alpha=0.6,
        label="Среднее по репликации",
    )
    axes[1, 0].plot(
        replications,
        cumulative_system_time,
        marker="s",
        linewidth=2.0,
        label="Накопленное среднее",
    )
    axes[1, 0].set_title("Стабилизация времени в системе")
    axes[1, 0].set_xlabel("Номер репликации k")
    axes[1, 0].set_ylabel("T_сист, мин")
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)

    # 4. Накопленные средние непрерывных откликов.
    continuous_responses = (
        "avg_body_queue_length",
        "avg_busy_body_places",
        "avg_busy_paint_booths",
    )
    for response_name in continuous_responses:
        axes[1, 1].plot(
            replications,
            cumulative_means[response_name],
            marker="o",
            linewidth=1.5,
            label=RESPONSE_LABELS[response_name],
        )
    axes[1, 1].set_title("Накопленные средние непрерывных откликов")
    axes[1, 1].set_xlabel("Номер репликации k")
    axes[1, 1].set_ylabel("Среднее значение")
    axes[1, 1].legend(fontsize=8)
    axes[1, 1].grid(True, alpha=0.3)

    figure.suptitle(
        f"Верификация: {len(result_list)} репликаций; "
        f"seed/индекс от {seeds[0]} до {seeds[-1]}",
        fontsize=13,
    )
    figure.tight_layout(rect=(0.0, 0.0, 1.0, 0.96))
    _save_figure(figure, output_path)
    return figure


def plot_sweep(
    df: pd.DataFrame,
    param_name: str,
    response_name: str,
    output_path: str | Path | None = None,
    *,
    confidence_level: float = 0.95,
) -> Figure:
    """Строит зависимость отклика от параметра с доверительной полосой."""

    aggregated = aggregate_sweep(
        df,
        parameter=param_name,
        response_name=response_name,
        confidence_level=confidence_level,
    )
    if aggregated.empty:
        raise ValueError("После агрегации не осталось данных для графика.")

    x_values = aggregated[param_name].to_numpy(dtype=float)
    mean_values = aggregated["mean"].to_numpy(dtype=float)
    low_values = aggregated["ci_low"].to_numpy(dtype=float)
    high_values = aggregated["ci_high"].to_numpy(dtype=float)

    figure, axis = plt.subplots(figsize=(9, 5.5))
    axis.plot(
        x_values,
        mean_values,
        marker="o",
        linewidth=2.0,
        color="tab:blue",
        label="Среднее по репликациям",
    )
    axis.fill_between(
        x_values,
        low_values,
        high_values,
        color="tab:blue",
        alpha=0.2,
        label=f"{int(confidence_level * 100)}% доверительный интервал",
    )
    axis.set_xlabel(param_name)
    axis.set_ylabel(RESPONSE_LABELS.get(response_name, response_name))
    axis.set_title(
        f"Зависимость отклика {RESPONSE_LABELS.get(response_name, response_name)} "
        f"от {param_name}"
    )
    axis.grid(True, alpha=0.3)
    axis.legend()

    figure.tight_layout()
    _save_figure(figure, output_path)
    return figure
