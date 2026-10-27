"""Пакет экспериментов: одиночный прогон, верификация и параметрический скан."""

from experiments.runner import run_single
from experiments.sweep_runner import aggregate_sweep, run_sweep
from experiments.verification import (
    VerificationReport,
    run_verification,
)

__all__ = [
    "VerificationReport",
    "aggregate_sweep",
    "run_single",
    "run_sweep",
    "run_verification",
]
