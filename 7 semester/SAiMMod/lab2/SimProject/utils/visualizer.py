"""
visualizer.py - Визуализация результатов симуляции.
Только сканирует CSV в responses/continuous и responses/discrete,
строит графики по данным столбцов без доменной логики модели.
"""

from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd


class SimulationVisualizer:
    """Примитивный визуализатор: только по структуре CSV."""

    @staticmethod
    def _get_xy(df: pd.DataFrame):
        if df.empty or len(df.columns) < 2:
            return None, None
        x_col = df.columns[0]
        y_col = None
        for c in df.columns[1:]:
            if pd.api.types.is_numeric_dtype(df[c]):
                y_col = c
                break
        if y_col is None:
            # fallback - вторая колонка
            y_col = df.columns[1]
        return x_col, y_col

    @staticmethod
    def _plot_continuous_file(csv_path: Path, graphs_dir: Path) -> None:
        try:
            df = pd.read_csv(csv_path)
        except Exception:
            return
        x_col, y_col = SimulationVisualizer._get_xy(df)
        if not x_col or not y_col:
            return

        df = df.copy()
        try:
            df = df.sort_values(x_col)
        except Exception:
            pass

        df["mavg_cum"] = df[y_col].expanding(min_periods=1).mean()

        fig, ax = plt.subplots(figsize=(10, 6))
        ax.plot(df[x_col], df[y_col], color="blue", linewidth=1, label=str(y_col))
        ax.plot(df[x_col], df["mavg_cum"], color="red", linewidth=1.5, label="Накопленное среднее")
        ax.set_title(csv_path.stem)
        ax.set_xlabel(str(x_col))
        ax.set_ylabel(str(y_col))
        ax.grid(True, linestyle="--", alpha=0.5)
        ax.legend()
        fig.tight_layout()
        out_path = graphs_dir / f"{csv_path.stem}.png"
        out_path.parent.mkdir(parents=True, exist_ok=True)
        fig.savefig(out_path, dpi=150)
        plt.close(fig)

    @staticmethod
    def _plot_discrete_file(csv_path: Path, graphs_dir: Path) -> None:
        try:
            df = pd.read_csv(csv_path)
        except Exception:
            return
        x_col, y_col = SimulationVisualizer._get_xy(df)
        if not x_col or not y_col:
            return

        df = df.copy()
        try:
            df = df.sort_values(x_col)
        except Exception:
            pass

        fig, ax = plt.subplots(figsize=(10, 6))
        ax.scatter(df[x_col], df[y_col], color="blue", s=12, alpha=0.7, label=str(y_col))
        df["mavg_cum"] = df[y_col].expanding(min_periods=1).mean()
        ax.plot(df[x_col], df["mavg_cum"], color="red", linewidth=1.5, label="Накопленное среднее")

        ax.set_title(csv_path.stem)
        ax.set_xlabel(str(x_col))
        ax.set_ylabel(str(y_col))
        ax.grid(True, linestyle="--", alpha=0.5)
        ax.legend(loc="best", fontsize=8)
        fig.tight_layout()
        out_path = graphs_dir / f"{csv_path.stem}.png"
        out_path.parent.mkdir(parents=True, exist_ok=True)
        fig.savefig(out_path, dpi=150)
        plt.close(fig)

    @staticmethod
    def plot_from_responses(responses_root: Path) -> None:
        if not responses_root.exists():
            return
        graphs_dir = responses_root.parent / "graphs"
        graphs_dir.mkdir(parents=True, exist_ok=True)

        continuous_dir = responses_root / "continuous"
        if continuous_dir.exists():
            for csv_path in sorted(continuous_dir.glob("*.csv")):
                SimulationVisualizer._plot_continuous_file(csv_path, graphs_dir)

        discrete_dir = responses_root / "discrete"
        if discrete_dir.exists():
            for csv_path in sorted(discrete_dir.glob("*.csv")):
                SimulationVisualizer._plot_discrete_file(csv_path, graphs_dir)

    @staticmethod
    def plot_all(
        output_dir: Path,
        timeseries_csv: Path,
        cars_csv: Path,
        window: int = 5,
    ) -> None:
        responses_root = output_dir / "responses"
        if responses_root.exists():
            SimulationVisualizer.plot_from_responses(responses_root)
            return
        # Фоллбэк минимальный
        graphs_dir = output_dir / "graphs"
        graphs_dir.mkdir(parents=True, exist_ok=True)
        try:
            timeseries_df = pd.read_csv(timeseries_csv)
            if not timeseries_df.empty and "timestamp" in timeseries_df.columns:
                for col in timeseries_df.columns:
                    if col == "timestamp":
                        continue
                    if not pd.api.types.is_numeric_dtype(timeseries_df[col]):
                        continue
                    df = timeseries_df.copy().sort_values("timestamp")
                    df["mavg_cum"] = df[col].expanding(min_periods=1).mean()
                    fig, ax = plt.subplots(figsize=(10, 6))
                    ax.plot(df["timestamp"], df[col], color="blue", linewidth=1, label=str(col))
                    ax.plot(df["timestamp"], df["mavg_cum"], color="red", linewidth=1.5, label="Накопленное среднее")
                    ax.set_title(col)
                    ax.set_xlabel("timestamp")
                    ax.set_ylabel(col)
                    ax.grid(True, linestyle="--", alpha=0.5)
                    ax.legend()
                    fig.tight_layout()
                    fig.savefig(graphs_dir / f"{col}.png", dpi=150)
                    plt.close(fig)
        except Exception:
            pass
        try:
            cars_df = pd.read_csv(cars_csv)
            if not cars_df.empty and "exit_time" in cars_df.columns and "time_in_system" in cars_df.columns:
                df = cars_df.copy().sort_values("exit_time")
                fig, ax = plt.subplots(figsize=(10, 6))
                ax.scatter(df["exit_time"], df["time_in_system"], color="blue", s=12, alpha=0.7, label="time_in_system")
                df["mavg_cum"] = df["time_in_system"].expanding(min_periods=1).mean()
                ax.plot(df["exit_time"], df["mavg_cum"], color="red", linewidth=1.5, label="Накопленное среднее")
                ax.set_title("time_in_system")
                ax.set_xlabel("exit_time")
                ax.set_ylabel("time_in_system")
                ax.grid(True, linestyle="--", alpha=0.5)
                ax.legend()
                fig.tight_layout()
                fig.savefig(graphs_dir / "time_in_system.png", dpi=150)
                plt.close(fig)
        except Exception:
            pass
