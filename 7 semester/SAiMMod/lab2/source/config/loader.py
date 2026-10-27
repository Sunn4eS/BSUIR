"""Загрузчик конфигураций для запуска модели.

Конфигурация задаётся в JSON-файле. Приоритет значений:
1. Явно переданные аргументы CLI
2. Значения из JSON-конфига
3. Значения по умолчанию в :class:`WorkshopConfig`
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any

from config.model_config import WorkshopConfig


@dataclass(slots=True)
class SweepConfig:
    """Параметры параметрического скана."""

    parameter: str = "mean_arrival_m1"
    start: float = 5.0
    stop: float = 25.0
    step: float = 5.0
    seeds_per_point: int = 10


@dataclass(slots=True)
class ExperimentConfig:
    """Параметры эксперимента."""

    mode: str = "run"
    replications: int = 10
    seed_stride: int = 1
    output_dir: str | None = None
    output_root: str = "results"
    time_step: float = 0.5
    confidence: float = 0.95
    sweep: SweepConfig = field(default_factory=SweepConfig)


@dataclass(slots=True)
class AppConfig:
    """Полная конфигурация запуска."""

    model: WorkshopConfig
    experiment: ExperimentConfig

    def to_dict(self) -> dict[str, Any]:
        """Сериализация в словарь."""

        return {
            "model": self.model.to_dict(),
            "experiment": {
                "mode": self.experiment.mode,
                "replications": self.experiment.replications,
                "seed_stride": self.experiment.seed_stride,
                "output_dir": self.experiment.output_dir,
                "output_root": self.experiment.output_root,
                "time_step": self.experiment.time_step,
                "confidence": self.experiment.confidence,
                "sweep": asdict(self.experiment.sweep),
            },
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> "AppConfig":
        """Десериализация из словаря."""

        if not isinstance(data, dict):
            raise ValueError("Конфиг должен быть словарём JSON.")

        model_data = data.get("model")
        if model_data is None:
            raise ValueError("В конфиге отсутствует секция 'model'.")
        if not isinstance(model_data, dict):
            raise ValueError("Секция 'model' должна быть словарём.")

        exp_data = data.get("experiment")
        if exp_data is None:
            exp_data = {}
        if not isinstance(exp_data, dict):
            raise ValueError("Секция 'experiment' должна быть словарём.")

        sweep_data = exp_data.get("sweep")
        if sweep_data is None:
            sweep_data = {}
        if not isinstance(sweep_data, dict):
            raise ValueError("Секция 'experiment.sweep' должна быть словарём.")

        try:
            model = WorkshopConfig.from_dict(model_data)
        except Exception as error:
            raise ValueError(f"Ошибка в секции 'model': {error}") from error

        try:
            sweep = SweepConfig(**sweep_data)
            experiment = ExperimentConfig(
                mode=exp_data.get("mode", "run"),
                replications=exp_data.get("replications", 10),
                seed_stride=exp_data.get("seed_stride", 1),
                output_dir=exp_data.get("output_dir"),
                output_root=exp_data.get("output_root", "results"),
                time_step=exp_data.get("time_step", 0.5),
                confidence=exp_data.get("confidence", 0.95),
                sweep=sweep,
            )
        except Exception as error:
            raise ValueError(f"Ошибка в секции 'experiment': {error}") from error

        return cls(model=model, experiment=experiment)


def load_app_config(path: str | Path) -> AppConfig:
    """Загружает AppConfig из JSON-файла."""

    config_path = Path(path)
    if not config_path.exists():
        raise FileNotFoundError(f"Файл конфигурации не найден: {config_path}")
    if not config_path.is_file():
        raise ValueError(f"Путь не является файлом: {config_path}")

    try:
        with config_path.open("r", encoding="utf-8") as file:
            data = json.load(file)
    except json.JSONDecodeError as error:
        raise ValueError(f"Ошибка парсинга JSON: {error}") from error

    return AppConfig.from_dict(data)


def save_config(config: WorkshopConfig | AppConfig, path: str | Path) -> Path:
    """Сохраняет конфигурацию в JSON."""

    output_path = Path(path)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    if isinstance(config, AppConfig):
        payload = config.to_dict()
    elif isinstance(config, WorkshopConfig):
        payload = {"model": config.to_dict(), "experiment": {}}
    else:
        raise TypeError("config должен быть WorkshopConfig или AppConfig")

    with output_path.open("w", encoding="utf-8") as file:
        json.dump(payload, file, ensure_ascii=False, indent=2)

    return output_path
