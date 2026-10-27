"""
runner.py - Универсальный исполнитель (Runner) симуляций.
"""

import json
import shutil
from datetime import datetime
from pathlib import Path
from typing import Any, Type

from core.base import ISimulationModel
from utils.tracer import SimulationTracer
from utils.metrics import MetricsExporter


class SimulationRunner:
    """
    Класс управления жизненным циклом симуляционного эксперимента.
    Полностью абстрагирован от конкретной модели.
    """

    def __init__(self, config_path: str, model_cls: type[ISimulationModel]):
        self.config_path = Path(config_path)
        self.model_cls = model_cls

        if not self.config_path.exists():
            raise FileNotFoundError(f"Config file not found: {self.config_path}")

        self.config = self._load_config()
        self.output_dir = self._init_output_dir()
        self.logger = SimulationTracer.setup(
            enabled=self.config["logging"]["trace_enabled"],
            log_to_file=self.config["logging"]["log_to_file"],
            output_dir=self.output_dir,
        )

    def _load_config(self) -> dict[str, Any]:
        with open(self.config_path, "r", encoding="utf-8") as f:
            return json.load(f)

    def _init_output_dir(self) -> Path:
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        target_dir = Path("./data/plots") / timestamp
        target_dir.mkdir(parents=True, exist_ok=True)
        # Сохраняем слепок конфига для абсолютной воспроизводимости эксперимента
        shutil.copy(self.config_path, target_dir / "config_snapshot.json")
        return target_dir

    def execute(self) -> None:
        """Запуск цикла симуляции, экспорта откликов и вывода отчета."""
        print(f"[*] Старт эксперимента. Модель: {self.model_cls.__name__}")
        print(f"[*] Директория результатов: {self.output_dir.resolve()}")

        # Инстанцирование через интерфейс (DI)
        model: ISimulationModel = self.model_cls(self.config, self.logger)

        # Выполнение расчета
        artifacts = model.build_and_run()

        # Сохранение откликов (CSV)
        print("[*] Сохранение метрик в CSV...")
        MetricsExporter.export_csv(
            self.output_dir / "summary_metrics.csv", [artifacts.summary]
        )
        MetricsExporter.export_csv(
            self.output_dir / "timeseries_metrics.csv", artifacts.timeseries
        )
        MetricsExporter.export_csv(
            self.output_dir / "cars_metrics.csv", artifacts.cars
        )

        # Унифицированный экспорт откликов
        try:
            from utils.responses_exporter import ResponsesExporter

            responses = getattr(artifacts, "responses", None)
            if responses:
                print("[*] Экспорт откликов по структуре responses/...")
                ResponsesExporter.export_all(self.output_dir, responses)
        except Exception as e:
            print(f"[!] Не удалось выполнить унифицированный экспорт откликов: {e}")

        # Построение графиков
        try:
            from utils.visualizer import SimulationVisualizer

            print("[*] Построение графиков...")
            SimulationVisualizer.plot_all(
                output_dir=self.output_dir,
                timeseries_csv=self.output_dir / "timeseries_metrics.csv",
                cars_csv=self.output_dir / "cars_metrics.csv",
                window=5,
            )
            print("[+] Графики сохранены в data/plots/<timestamp>/graphs/")
        except Exception as e:
            print(f"[!] Не удалось построить графики: {e}")

        print("\n" + "=" * 50)
        print("ИТОГИ ЭКСПЕРИМЕНТА:")
        print(f"  • Время прогона:                {artifacts.summary['run_duration']:.2f}")
        print(f"  • Обслужено Модель 1:           {artifacts.summary['finished_model_1']}")
        print(f"  • Обслужено Модель 2:           {artifacts.summary['finished_model_2']}")
        print(f"  • Всего обслужено:              {artifacts.summary['total_serviced']}")
        print(f"  • Число вытеснений Модели 2:    {artifacts.summary['preemptions_model_2']}")
        print(f"  • Режим дообслуживания:         {artifacts.summary['drain_mode_applied']}")
        print("=" * 50)
        print(f"[+] Успешно сохранено в: {self.output_dir}\n")