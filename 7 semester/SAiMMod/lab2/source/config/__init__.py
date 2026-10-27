"""Пакет конфигурации имитационной модели."""

from config.loader import AppConfig, ExperimentConfig, load_app_config, save_config
from config.model_config import WorkshopConfig

__all__ = ["AppConfig", "ExperimentConfig", "WorkshopConfig", "load_app_config", "save_config"]

