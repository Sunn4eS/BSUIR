"""
tracer.py - Модуль конфигурирования логирования и трассировки симуляции.
"""

import sys
import logging
from pathlib import Path
from typing import Optional


class SimulationTracer:
    """Управляет выводом логов симуляции в консоль либо файл."""

    LOGGER_NAME = "SimPyTracer"

    @classmethod
    def setup(
        cls,
        enabled: bool,
        log_to_file: bool,
        output_dir: Optional[Path] = None
    ) -> logging.Logger:
        logger = logging.getLogger(cls.LOGGER_NAME)
        logger.setLevel(logging.INFO if enabled else logging.CRITICAL)
        logger.handlers.clear()
        logger.propagate = False

        if not enabled:
            logger.addHandler(logging.NullHandler())
            return logger

        formatter = logging.Formatter("%(message)s")

        if log_to_file and output_dir:
            log_file = output_dir / "trace.log"
            handler = logging.FileHandler(log_file, encoding="utf-8")
        else:
            handler = logging.StreamHandler(sys.stdout)

        handler.setFormatter(formatter)
        logger.addHandler(handler)
        return logger