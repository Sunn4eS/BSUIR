"""Генерация HTML-отчёта."""

from __future__ import annotations

import html
from pathlib import Path
from typing import Any

from analysis.response_catalog import RESPONSE_CATALOG, RESPONSE_ORDER
from config.loader import AppConfig, save_config
from config.model_config import WorkshopConfig
from simulation.monitors import SCALAR_RESPONSE_NAMES, SimulationResults


def _table(headers: list[str], rows: list[list[Any]]) -> str:
    head = "".join(f"<th>{html.escape(str(h))}</th>" for h in headers)
    body = []
    for row in rows:
        body.append("<tr>" + "".join(f"<td>{html.escape(str(c))}</td>" for c in row) + "</tr>")
    return f"<table><thead><tr>{head}</tr></thead><tbody>{''.join(body)}</tbody></table>"


def generate_report(
    run_dir: Path,
    config: WorkshopConfig | AppConfig,
    results: SimulationResults,
    extra_meta: dict[str, Any] | None = None,
) -> Path:
    run_dir = Path(run_dir)
    plots_dir = run_dir / "plots"
    report_path = run_dir / "report.html"

    flat = results.to_flat_dict()
    if isinstance(config, AppConfig):
        model_cfg = config.model
        exp_cfg = config.experiment
    else:
        model_cfg = config
        exp_cfg = None

    # Таблица откликов
    resp_rows = []
    for name in RESPONSE_ORDER:
        info = RESPONSE_CATALOG.get(name)
        label = info.label_ru if info else name
        unit = info.unit if info else ""
        val = flat.get(name)
        resp_rows.append([label, f"{val}", unit])

    meta_rows = [
        ["Режим drain", "Да (дообслуживание)" if results.drain_enabled else "Нет (жёсткая остановка)"],
        ["T_final, мин", f"{results.total_run_time:.4f}"],
        ["Прибыло", len(results.entry_times)],
        ["Обслужено всего", results.serviced_model_1 + results.serviced_model_2],
        ["Цензурировано", results.censored_cars],
        ["Цензурировано М1", results.censored_model_1],
        ["Цензурировано М2", results.censored_model_2],
        ["Прерываний М2", results.preemptions_model_2],
    ]
    if extra_meta:
        for k, v in extra_meta.items():
            meta_rows.append([str(k), str(v)])

    # Конфиг
    cfg_rows = []
    for k, v in model_cfg.to_dict().items():
        cfg_rows.append([k, str(v)])

    # Графики
    plot_html = []
    for name in RESPONSE_ORDER:
        p = plots_dir / f"{name}.png"
        if p.exists():
            plot_html.append(f'<h3>{html.escape(RESPONSE_CATALOG.get(name).label_ru if RESPONSE_CATALOG.get(name) else name)}</h3>')
            plot_html.append(f'<img src="plots/{html.escape(p.name)}" style="max-width:1000px;width:100%;">')

    html_content = f"""<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="utf-8">
<title>Отчёт по модели СТО</title>
<style>
body {{ font-family: Arial, sans-serif; margin: 40px; background: #fafafa; }}
h1 {{ color: #333; }}
h2 {{ color: #444; margin-top: 40px; }}
table {{ border-collapse: collapse; width: 100%; max-width: 900px; margin: 20px 0; }}
th, td {{ border: 1px solid #ddd; padding: 8px; }}
th {{ background: #f4f4f4; text-align: left; }}
tr:nth-child(even) {{ background: #f9f9f9; }}
img {{ border: 1px solid #ccc; margin: 10px 0; }}
</style>
</head>
<body>
<h1>Отчёт по имитационной модели участка СТО</h1>
<h2>Основные метрики</h2>
{_table(["Параметр", "Значение"], meta_rows)}
<h2>Отклики по каждому пункту</h2>
{_table(["Отклик", "Значение", "Ед."], resp_rows)}
<h2>Параметры модели</h2>
{_table(["Параметр", "Значение"], cfg_rows)}
<h2>Графики по каждому отклику</h2>
{''.join(plot_html)}
<h2>Файлы</h2>
<ul>
<li><a href="config.json">config.json</a></li>
<li><a href="responses.csv">responses.csv</a></li>
<li><a href="responses.json">responses.json</a></li>
<li><a href="timeseries.csv">timeseries.csv</a></li>
<li><a href="cars.csv">cars.csv</a></li>
<li><a href="preemptions.csv">preemptions.csv</a></li>
</ul>
</body>
</html>
"""

    report_path.write_text(html_content, encoding="utf-8")
    return report_path
