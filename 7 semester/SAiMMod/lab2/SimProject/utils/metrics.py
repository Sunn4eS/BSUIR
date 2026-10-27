"""
metrics.py - Сбор, агрегирование и сериализация откликов симуляции.
"""

import csv
from pathlib import Path
from typing import Any


class MetricsExporter:
    """Отвечает за сохранение артефактов эксперимента на диск."""

    @staticmethod
    def export_csv(file_path: Path, data: list[dict[str, Any]]) -> None:
        """Сохраняет список словарей в CSV-файл."""
        if not data:
            return

        file_path.parent.mkdir(parents=True, exist_ok=True)
        with open(file_path, mode="w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=list(data[0].keys()))
            writer.writeheader()
            writer.writerows(data)