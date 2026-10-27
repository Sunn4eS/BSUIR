"""Экспорт результатов прогона в файлы."""

from __future__ import annotations

import csv
import json
from datetime import datetime
from pathlib import Path
from typing import Any

from config.loader import AppConfig, save_config
from config.model_config import WorkshopConfig
from simulation.monitors import SCALAR_RESPONSE_NAMES, SimulationResults


def _ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def create_run_dir(
    base_root: str | Path,
    mode: str,
    timestamp: str | None = None,
) -> Path:
    if timestamp is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    run_dir = Path(base_root) / f"{mode}_{timestamp}"
    _ensure_dir(run_dir)
    _ensure_dir(run_dir / "plots")
    return run_dir


def export_results(
    run_dir: str | Path,
    config: WorkshopConfig | AppConfig,
    results: SimulationResults,
    extra_meta: dict[str, Any] | None = None,
) -> dict[str, Path]:
    run_dir = Path(run_dir)
    _ensure_dir(run_dir)
    _ensure_dir(run_dir / "plots")

    saved: dict[str, Path] = {}

    # Конфиг
    config_path = run_dir / "config.json"
    save_config(config, config_path)
    saved["config"] = config_path

    # Скалярные отклики
    flat = results.to_flat_dict()
    flat_meta = {
        "drain_enabled": results.drain_enabled,
        "censored_cars": results.censored_cars,
        "censored_model_1": results.censored_model_1,
        "censored_model_2": results.censored_model_2,
        "arrived_count": len(results.entry_times),
        "finished_count": len(results.car_system_times),
    }
    if extra_meta:
        flat_meta.update(extra_meta)

    responses_json = run_dir / "responses.json"
    with responses_json.open("w", encoding="utf-8") as f:
        json.dump({"responses": flat, "meta": flat_meta}, f, ensure_ascii=False, indent=2)
    saved["responses_json"] = responses_json

    responses_csv = run_dir / "responses.csv"
    with responses_csv.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        keys = list(SCALAR_RESPONSE_NAMES) + ["arrived_count", "std_car_system_time", "censored_cars", "censored_model_1", "censored_model_2", "drain_enabled"]
        writer.writerow(keys)
        writer.writerow([flat.get(k) for k in keys])
    saved["responses_csv"] = responses_csv

    # Временные ряды непрерывных
    timeseries_csv = run_dir / "timeseries.csv"
    with timeseries_csv.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["time", "response", "value"])
        for t, v in results.body_queue_history:
            writer.writerow([t, "avg_body_queue_length", v])
        for t, v in results.body_busy_history:
            writer.writerow([t, "avg_busy_body_places", v])
        for t, v in results.paint_busy_history:
            writer.writerow([t, "avg_busy_paint_booths", v])
    saved["timeseries_csv"] = timeseries_csv

    # Автомобили
    cars_csv = run_dir / "cars.csv"
    with cars_csv.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        if results.car_records:
            keys = list(results.car_records[0].keys())
            writer.writerow(keys)
            for rec in results.car_records:
                writer.writerow([rec.get(k) for k in keys])
        else:
            writer.writerow(["car_id", "model", "entry_time", "exit_time", "time_in_system", "status"])
    saved["cars_csv"] = cars_csv

    # Прерывания
    preempt_csv = run_dir / "preemptions.csv"
    with preempt_csv.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        if results.preemption_events:
            keys = list(results.preemption_events[0].keys())
            writer.writerow(keys)
            for rec in results.preemption_events:
                writer.writerow([rec.get(k) for k in keys])
        else:
            writer.writerow(["time", "preempted_car_id", "preempted_model", "preemptor_car_id", "preemptor_model", "remaining_time"])
    saved["preemptions_csv"] = preempt_csv

    return saved
