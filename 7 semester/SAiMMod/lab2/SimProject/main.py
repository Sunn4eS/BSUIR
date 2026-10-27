"""
main.py - Точка входа для запуска симуляции.
"""

import argparse
from engine.runner import SimulationRunner
from models.sto_model import AutoRepairShopModel


def parse_args():
    parser = argparse.ArgumentParser(description="SimPy Enterprise Simulation Platform")
    parser.add_argument(
        "--config",
        type=str,
        default="config/config.json",
        help="Путь к конфигурационному JSON-файлу",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    # Для подключения другой модели просто передайте другой класс,
    # реализующий ISimulationModel, например:
    # runner = SimulationRunner(args.config, AnotherFactoryModel)
    runner = SimulationRunner(
        config_path=args.config,
        model_cls=AutoRepairShopModel
    )
    runner.execute()


if __name__ == "__main__":
    main()