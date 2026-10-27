"""Сценарии запуска модели."""

from __future__ import annotations

from datetime import datetime
from pathlib import Path
from typing import Any

from analysis.plots import plot_all_responses
from analysis.report import generate_report
from config.loader import AppConfig, save_config
from config.model_config import WorkshopConfig
from experiments.export import create_run_dir, export_results
from experiments.runner import run_single
from experiments.sweep_runner import aggregate_sweep, run_sweep
from experiments.verification import run_verification


def _resolve_output_root(config: WorkshopConfig | AppConfig) -> Path:
    if isinstance(config, AppConfig):
        root = config.experiment.output_root
    else:
        root = "results"
    return Path(root)


def run_once(
    config: WorkshopConfig | AppConfig,
    *,
    start_arrivals: bool = True,
    seed: int | None = None,
) -> tuple[Path, Any]:
    if isinstance(config, AppConfig):
        model_config = config.model
        exp_config = config.experiment
    else:
        model_config = config
        exp_config = None

    run_config = model_config.clone_with(seed=seed) if seed is not None else model_config
    results = run_single(run_config, start_arrivals=start_arrivals)

    output_root = _resolve_output_root(config)
    if exp_config and exp_config.mode == "trace":
        run_dir = create_run_dir(output_root, "trace")
    else:
        run_dir = create_run_dir(output_root, "run")
    
    export_results(run_dir, config, results, extra_meta={"mode": exp_config.mode if exp_config else "run"})
    plot_all_responses(results, run_dir / "plots")
    report_path = generate_report(run_dir, config, results)
    
    return run_dir, results


def run_trace_workflow(config: WorkshopConfig | AppConfig) -> tuple[Path, Any]:
    return run_once(config)


def run_verify_workflow(config: WorkshopConfig | AppConfig) -> tuple[Path, Any]:
    if isinstance(config, AppConfig):
        model_config = config.model
        exp_config = config.experiment
    else:
        model_config = config
        exp_config = None

    replications = exp_config.replications if exp_config else 10
    seed_stride = exp_config.seed_stride if exp_config else 1
    
    report = run_verification(model_config, replications=replications, seed_stride=seed_stride)
    
    output_root = _resolve_output_root(config)
    run_dir = create_run_dir(output_root, "verify")
    
    # Сохраняем первый прогон как основной отчёт
    results = report.results[0] if report.results else None
    if results:
        export_results(run_dir, config, results, extra_meta={"mode": "verify", "replications": replications})
        plot_all_responses(results, run_dir / "plots")
        generate_report(run_dir, config, results, extra_meta={"mode": "verify", "replications": replications})
    
    # Сохраняем все репликации
    import pandas as pd
    df = report.to_dataframe()
    df.to_csv(run_dir / "all_replications.csv", index=False)
    cdf = report.cumulative_dataframe()
    cdf.to_csv(run_dir / "cumulative_means.csv", index=False)
    
    return run_dir, report


def run_sweep_workflow(config: WorkshopConfig | AppConfig) -> tuple[Path, Any]:
    if isinstance(config, AppConfig):
        model_config = config.model
        exp_config = config.experiment
        sweep_cfg = exp_config.sweep
    else:
        model_config = config
        exp_config = None
        from config.loader import SweepConfig
        sweep_cfg = SweepConfig()

    from analysis.visualizer import plot_sweep
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    
    values = []
    start, stop, step = sweep_cfg.start, sweep_cfg.stop, sweep_cfg.step
    current = start
    tol = abs(step) * 1e-9 + 1e-12
    while current <= stop + tol:
        values.append(round(current, 10))
        current += step
    
    df = run_sweep(
        model_config,
        parameter=sweep_cfg.parameter,
        values=values,
        seeds_per_point=sweep_cfg.seeds_per_point,
    )
    
    output_root = _resolve_output_root(config)
    run_dir = create_run_dir(output_root, "sweep")
    
    df.to_csv(run_dir / "sweep_raw.csv", index=False)
    
    from simulation.monitors import SCALAR_RESPONSE_NAMES
    summary_frames = []
    for response_name in SCALAR_RESPONSE_NAMES:
        agg = aggregate_sweep(df, parameter=sweep_cfg.parameter, response_name=response_name, confidence_level=exp_config.confidence if exp_config else 0.95)
        agg2 = agg.copy()
        agg2.insert(0, "response", response_name)
        summary_frames.append(agg2)
        try:
            fig = plot_sweep(df, sweep_cfg.parameter, response_name, output_path=run_dir / "plots" / f"{response_name}.png", confidence_level=exp_config.confidence if exp_config else 0.95)
            plt.close(fig)
        except Exception:
            pass
    
    import pandas as pd
    summary = pd.concat(summary_frames, ignore_index=True)
    summary.to_csv(run_dir / "sweep_summary.csv", index=False)
    
    save_config(config, run_dir / "config.json")
    
    return run_dir, df
