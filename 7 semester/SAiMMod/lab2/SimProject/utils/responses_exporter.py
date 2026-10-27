"""
responses_exporter.py - Экспорт откликов по типам в структуру для визуализатора.
"""

import csv
from pathlib import Path
from typing import Any

from core.responses import ResponseSpec


class ResponsesExporter:
    """Сохраняет все отклики в единый файл и разбивает по папкам continuous/discrete."""

    @staticmethod
    def export_all(output_dir: Path, responses: list[ResponseSpec] | tuple[ResponseSpec, ...]) -> None:
        if not responses:
            return

        output_dir.mkdir(parents=True, exist_ok=True)
        responses_root = output_dir / "responses"
        continuous_dir = responses_root / "continuous"
        discrete_dir = responses_root / "discrete"
        continuous_dir.mkdir(parents=True, exist_ok=True)
        discrete_dir.mkdir(parents=True, exist_ok=True)

        all_rows: list[dict[str, Any]] = []

        for spec in responses:
            data = spec.data or []
            if not data:
                continue

            # Собираем унифицированный all_responses.csv
            for row in data:
                all_row = dict(row)
                all_row["response_name"] = spec.name
                all_row["kind"] = spec.kind
                all_row["x_col"] = spec.x_col
                all_row["y_col"] = spec.y_col
                if spec.group_by is not None:
                    all_row["group_by"] = spec.group_by
                if spec.entity_id is not None and "entity_id" not in all_row:
                    all_row["entity_id"] = all_row.get(spec.entity_id) or all_row.get("car_id") or all_row.get("entity")
                all_rows.append(all_row)

            # Сохраняем по отдельному файлу в соответствующую папку
            base_cols = []
            if spec.x_col and spec.x_col in data[0]:
                base_cols.append(spec.x_col)
            if spec.y_col and spec.y_col in data[0]:
                base_cols.append(spec.y_col)
            # Доп колонки для группировки/идентификации
            extra_cols = []
            for c in data[0].keys():
                if c in base_cols:
                    continue
                if spec.group_by and c == spec.group_by:
                    extra_cols.append(c)
                    continue
                if c in ("model_type", "car_id", "entity_id", "id"):
                    extra_cols.append(c)
            fieldnames = base_cols + extra_cols
            # Убираем дубли
            seen = set()
            unique_fields = []
            for f in fieldnames:
                if f not in seen:
                    unique_fields.append(f)
                    seen.add(f)
            if not unique_fields:
                unique_fields = list(data[0].keys())

            if spec.kind == "continuous":
                out_path = continuous_dir / f"{spec.name}.csv"
            else:
                out_path = discrete_dir / f"{spec.name}.csv"

            with open(out_path, "w", newline="", encoding="utf-8") as f:
                writer = csv.DictWriter(f, fieldnames=unique_fields)
                writer.writeheader()
                for row in data:
                    out_row = {k: row.get(k) for k in unique_fields}
                    writer.writerow(out_row)

        # all_responses.csv
        if all_rows:
            all_fields_set = set()
            for r in all_rows:
                all_fields_set.update(r.keys())
            preferred = ["response_name", "kind", "x_col", "y_col", "group_by", "entity_id"]
            ordered = [p for p in preferred if p in all_fields_set]
            ordered += [f for f in sorted(list(all_fields_set)) if f not in ordered]
            all_path = output_dir / "all_responses.csv"
            with open(all_path, "w", newline="", encoding="utf-8") as f:
                writer = csv.DictWriter(f, fieldnames=ordered, extrasaction="ignore")
                writer.writeheader()
                for row in all_rows:
                    writer.writerow(row)
