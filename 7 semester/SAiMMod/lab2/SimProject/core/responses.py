"""
responses.py - Описание откликов симуляции для унифицированного экспорта и визуализации.
"""

from dataclasses import dataclass, field
from typing import Any, Literal


@dataclass(frozen=True)
class ResponseSpec:
    """Спецификация отклика модели."""

    name: str
    kind: Literal["continuous", "discrete"]
    x_col: str
    y_col: str
    data: list[dict[str, Any]]
    group_by: str | None = None
    entity_id: str | None = None
    title: str | None = None
    y_label: str | None = None
    extra_meta: dict[str, Any] = field(default_factory=dict)
