"""Построение графиков по каждому отклику с использованием скользящего среднего."""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

from analysis.response_catalog import RESPONSE_CATALOG, get_label
from simulation.monitors import SimulationResults


def _save(fig: plt.Figure, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)


def _step_xy(history: list[tuple[float, float]], final_time: float):
    if not history:
        return [0.0, final_time], [0.0, 0.0]
    times = [float(t) for t, _ in history]
    values = [float(v) for _, v in history]
    if final_time > times[-1]:
        times.append(float(final_time))
        values.append(values[-1])
    return times, values


def _time_weighted_moving_average(
    history: list[tuple[float, float]],
    final_time: float,
    window: float | None = None,
    dt: float = 0.5,
) -> tuple[np.ndarray, np.ndarray]:
    """Вычисляет взвешенное по времени скользящее среднее для ступенчатой функции."""
    if final_time <= 0.0 or not history:
        return np.array([]), np.array([])

    if window is None or window <= 0.0:
        window = max(10.0, final_time * 0.1)

    window = min(window, final_time)

    grid = np.arange(0.0, final_time + dt * 0.5, dt)
    if grid.size == 0:
        return np.array([]), np.array([])

    # Преобразуем историю в ступенчатую функцию
    hist_times = np.array([h[0] for h in history], dtype=float)
    hist_vals = np.array([h[1] for h in history], dtype=float)

    def step_value(t: float) -> float:
        if t < 0.0:
            return 0.0
        # Находим последнее изменение <= t
        idx = np.searchsorted(hist_times, t, side="right") - 1
        if idx < 0:
            return 0.0
        return float(hist_vals[idx])

    ma_vals = []
    for t in grid:
        t_start = t - window
        if t_start < 0.0:
            t_start = 0.0
        # Приближённый интеграл по сетке
        pts = np.arange(t_start, t + dt * 0.25, dt)
        if pts.size == 0:
            ma_vals.append(step_value(t))
            continue
        area = 0.0
        for p in pts:
            area += step_value(p) * dt
        denom = t - t_start
        if denom <= 0.0:
            ma_vals.append(step_value(t))
        else:
            ma_vals.append(area / denom)

    return grid, np.array(ma_vals)


def _cumulative_moving_average(
    event_times: list[float],
    final_time: float,
    window: float | None = None,
    dt: float = 0.5,
) -> tuple[np.ndarray, np.ndarray]:
    """Скользящее среднее по скорости накопления для кумулятивных счётчиков."""
    if final_time <= 0.0:
        return np.array([]), np.array([])

    if window is None or window <= 0.0:
        window = max(10.0, final_time * 0.1)

    window = min(window, final_time)
    grid = np.arange(0.0, final_time + dt * 0.5, dt)
    rate_vals = []

    for t in grid:
        t_start = t - window
        if t_start < 0.0:
            t_start = 0.0
        c_t = sum(1 for et in event_times if et <= t)
        c_s = sum(1 for et in event_times if et <= t_start)
        delta_count = c_t - c_s
        denom = t - t_start
        if denom <= 0.0:
            rate_vals.append(0.0)
        else:
            rate_vals.append(delta_count / denom)

    return grid, np.array(rate_vals)


def plot_all_responses(results: SimulationResults, plots_dir: Path) -> list[Path]:
    plots_dir = Path(plots_dir)
    plots_dir.mkdir(parents=True, exist_ok=True)
    saved: list[Path] = []

    flat = results.to_flat_dict()
    final_time = results.total_run_time

    # Непрерывные отклики со скользящим средним
    for name, history in [
        ("avg_body_queue_length", results.body_queue_history),
        ("avg_busy_body_places", results.body_busy_history),
        ("avg_busy_paint_booths", results.paint_busy_history),
    ]:
        fig, ax = plt.subplots(figsize=(9, 4))
        times, values = _step_xy(history, final_time)
        ax.step(times, values, where="post", color="tab:blue", alpha=0.4, label="Текущее значение X(t)")

        ma_t, ma_v = _time_weighted_moving_average(history, final_time)
        if ma_t.size > 0:
            ax.plot(ma_t, ma_v, color="tab:red", linewidth=2.0, label="Скользящее среднее по времени")

        ax.set_title(get_label(name))
        ax.set_xlabel("Время, мин")
        info = RESPONSE_CATALOG.get(name)
        ax.set_ylabel(info.unit if info else "")
        ax.grid(True, alpha=0.3)
        ax.legend()
        path = plots_dir / f"{name}.png"
        _save(fig, path)
        saved.append(path)

    # Время в системе
    name = "avg_car_system_time"
    fig, ax = plt.subplots(figsize=(9, 4))
    if results.car_system_times:
        ax.hist(results.car_system_times, bins=20, color="tab:orange", alpha=0.8, edgecolor="black")
        ax.axvline(flat.get(name, 0.0), linestyle="--", color="tab:red", linewidth=1.8, label=f"Среднее по выборке: {flat.get(name, 0.0):.2f} мин")
    ax.set_title(get_label(name))
    ax.set_xlabel("Время, мин")
    ax.set_ylabel("Частота")
    ax.grid(True, alpha=0.3)
    ax.legend()
    path = plots_dir / f"{name}.png"
    _save(fig, path)
    saved.append(path)

    # Аддитивные - кумулятивный счётчик + скользящее среднее интенсивности
    for name in ["serviced_model_1", "serviced_model_2"]:
        fig, ax = plt.subplots(figsize=(9, 4))
        model = 1 if name.endswith("1") else 2
        exits = []
        for t, rec in zip(results.exit_times, results.car_records):
            if rec.get("model") == model and rec.get("status") == "finished":
                exits.append(t)
        if not exits:
            exits = sorted([t for t in results.exit_times])

        if exits:
            counts = list(range(1, len(exits) + 1))
            ax.step(exits, counts, where="post", color="tab:green", linewidth=1.6, label="Накопленное число обслуженных")

        ma_t, ma_v = _cumulative_moving_average(exits, final_time)
        if ma_t.size > 0:
            ax2 = ax.twinx()
            ax2.plot(ma_t, ma_v, color="tab:red", linestyle="--", linewidth=1.8, label="Скользящее среднее интенсивности, авт/мин")
            ax2.set_ylabel("Интенсивность, авт./мин")
            lines, labels = ax.get_legend_handles_labels()
            lines2, labels2 = ax2.get_legend_handles_labels()
            ax.legend(lines + lines2, labels + labels2, loc="best")
        else:
            ax.legend()

        ax.set_title(get_label(name))
        ax.set_xlabel("Время, мин")
        ax.set_ylabel("Число автомобилей")
        ax.grid(True, alpha=0.3)
        path = plots_dir / f"{name}.png"
        _save(fig, path)
        saved.append(path)

    # Прерывания М2
    name = "preemptions_model_2"
    fig, ax = plt.subplots(figsize=(9, 4))
    preempt_times = list(results.preemption_times)
    if preempt_times:
        counts = list(range(1, len(preempt_times) + 1))
        ax.step(preempt_times, counts, where="post", color="tab:purple", linewidth=1.6, label="Накопленное число прерываний")

    ma_t, ma_v = _cumulative_moving_average(preempt_times, final_time)
    if ma_t.size > 0:
        ax2 = ax.twinx()
        ax2.plot(ma_t, ma_v, color="tab:red", linestyle="--", linewidth=1.8, label="Скользящее среднее интенсивности прерываний, 1/мин")
        ax2.set_ylabel("Интенсивность, прерываний/мин")
        lines, labels = ax.get_legend_handles_labels()
        lines2, labels2 = ax2.get_legend_handles_labels()
        ax.legend(lines + lines2, labels + labels2, loc="best")
    else:
        ax.legend()

    ax.set_title(get_label(name))
    ax.set_xlabel("Время, мин")
    ax.set_ylabel("Число прерываний")
    ax.grid(True, alpha=0.3)
    path = plots_dir / f"{name}.png"
    _save(fig, path)
    saved.append(path)

    # T_final
    name = "total_run_time"
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.bar([get_label(name)], [flat.get(name, 0.0)], color="tab:blue")
    ax.text(0, flat.get(name, 0.0), f"{flat.get(name, 0.0):.2f} мин", ha="center", va="bottom")
    ax.set_title(get_label(name))
    ax.set_ylabel("мин")
    path = plots_dir / f"{name}.png"
    _save(fig, path)
    saved.append(path)

    return saved

