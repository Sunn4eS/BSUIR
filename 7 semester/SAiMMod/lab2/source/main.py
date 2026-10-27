"""CLI для запуска имитационной модели участка СТО."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Sequence

import matplotlib

matplotlib.use("Agg")

from config.loader import AppConfig, ExperimentConfig, SweepConfig, load_app_config
from config.model_config import WorkshopConfig
from experiments.workflows import run_once, run_sweep_workflow, run_trace_workflow, run_verify_workflow


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Имитационное моделирование участка авторемонтной станции.",
    )
    parser.add_argument("--config", type=Path, default=None, help="Путь к JSON-конфигу")
    parser.add_argument(
        "--mode",
        choices=("run", "trace", "verify", "sweep"),
        default=None,
        help="Режим запуска",
    )
    parser.add_argument("--sim-time", type=float, default=None)
    parser.add_argument("--seed", type=int, default=None)
    parser.add_argument("--replications", type=int, default=None)
    parser.add_argument("--sweep-param", default=None)
    parser.add_argument("--sweep-start", type=float, default=None)
    parser.add_argument("--sweep-stop", type=float, default=None)
    parser.add_argument("--sweep-step", type=float, default=None)
    parser.add_argument("--seeds", type=int, default=None)
    parser.add_argument("--confidence", type=float, default=None)
    parser.add_argument("--output-root", default=None)
    parser.add_argument("--drain", dest="drain", action="store_true", default=None)
    parser.add_argument("--no-drain", dest="drain", action="store_false", default=None)
    parser.add_argument("--trace", dest="trace_flag", action="store_true", default=None)
    parser.add_argument("--num-body-places", type=int, default=None)
    parser.add_argument("--num-paint-booths", type=int, default=None)
    parser.add_argument("--mean-arrival-m1", type=float, default=None)
    parser.add_argument("--mean-arrival-m2", type=float, default=None)
    parser.add_argument("--body-repair-mu", type=float, default=None)
    parser.add_argument("--body-repair-sigma", type=float, default=None)
    parser.add_argument("--paint-ratio", type=float, default=None)
    parser.add_argument("--paint-sigma", type=float, default=None)
    return parser


def _apply_overrides(app_config: AppConfig, args: argparse.Namespace) -> AppConfig:
    model_dict = app_config.model.to_dict()
    exp_dict = {
        "mode": app_config.experiment.mode,
        "replications": app_config.experiment.replications,
        "seed_stride": app_config.experiment.seed_stride,
        "output_dir": app_config.experiment.output_dir,
        "output_root": app_config.experiment.output_root,
        "time_step": app_config.experiment.time_step,
        "confidence": app_config.experiment.confidence,
    }
    sweep_dict = {
        "parameter": app_config.experiment.sweep.parameter,
        "start": app_config.experiment.sweep.start,
        "stop": app_config.experiment.sweep.stop,
        "step": app_config.experiment.sweep.step,
        "seeds_per_point": app_config.experiment.sweep.seeds_per_point,
    }

    # Model overrides
    if args.seed is not None:
        model_dict["seed"] = args.seed
    if args.sim_time is not None:
        model_dict["sim_time"] = args.sim_time
    if args.drain is not None:
        model_dict["drain"] = args.drain
    if args.trace_flag is not None:
        model_dict["trace"] = args.trace_flag
    if args.num_body_places is not None:
        model_dict["num_body_places"] = args.num_body_places
    if args.num_paint_booths is not None:
        model_dict["num_paint_booths"] = args.num_paint_booths
    if args.mean_arrival_m1 is not None:
        model_dict["mean_arrival_m1"] = args.mean_arrival_m1
    if args.mean_arrival_m2 is not None:
        model_dict["mean_arrival_m2"] = args.mean_arrival_m2
    if args.body_repair_mu is not None:
        model_dict["body_repair_mu"] = args.body_repair_mu
    if args.body_repair_sigma is not None:
        model_dict["body_repair_sigma"] = args.body_repair_sigma
    if args.paint_ratio is not None:
        model_dict["paint_ratio"] = args.paint_ratio
    if args.paint_sigma is not None:
        model_dict["paint_sigma"] = args.paint_sigma

    # Exp overrides
    if args.mode is not None:
        exp_dict["mode"] = args.mode
    if args.replications is not None:
        exp_dict["replications"] = args.replications
    if args.seeds is not None:
        sweep_dict["seeds_per_point"] = args.seeds
    if args.sweep_param is not None:
        sweep_dict["parameter"] = args.sweep_param
    if args.sweep_start is not None:
        sweep_dict["start"] = args.sweep_start
    if args.sweep_stop is not None:
        sweep_dict["stop"] = args.sweep_stop
    if args.sweep_step is not None:
        sweep_dict["step"] = args.sweep_step
    if args.confidence is not None:
        exp_dict["confidence"] = args.confidence
    if args.output_root is not None:
        exp_dict["output_root"] = args.output_root

    model_config = WorkshopConfig.from_dict(model_dict)
    experiment_config = ExperimentConfig(
        mode=exp_dict["mode"],
        replications=exp_dict["replications"],
        seed_stride=exp_dict["seed_stride"],
        output_dir=exp_dict["output_dir"],
        output_root=exp_dict["output_root"],
        time_step=exp_dict["time_step"],
        confidence=exp_dict["confidence"],
        sweep=SweepConfig(**sweep_dict),
    )
    return AppConfig(model=model_config, experiment=experiment_config)


def main(argv: Sequence[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    try:
        if args.config:
            app_config = load_app_config(args.config)
        else:
            app_config = AppConfig(
                model=WorkshopConfig(),
                experiment=ExperimentConfig(),
            )
        app_config = _apply_overrides(app_config, args)

        mode = app_config.experiment.mode
        if mode == "trace":
            run_dir, results = run_trace_workflow(app_config)
            print(f"Результаты сохранены: {run_dir}")
            print(f"Отчёт: {run_dir / 'report.html'}")
            return 0
        if mode == "verify":
            run_dir, report = run_verify_workflow(app_config)
            print(f"Результаты сохранены: {run_dir}")
            print(f"Отчёт: {run_dir / 'report.html'}")
            return 0
        if mode == "sweep":
            run_dir, df = run_sweep_workflow(app_config)
            print(f"Результаты сохранены: {run_dir}")
            return 0
        # run
        run_dir, results = run_once(app_config)
        print(f"Результаты сохранены: {run_dir}")
        print(f"Отчёт: {run_dir / 'report.html'}")
        return 0
    except (ValueError, RuntimeError, FileNotFoundError) as error:
        parser.error(str(error))


if __name__ == "__main__":
    raise SystemExit(main())
