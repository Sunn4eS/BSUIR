"""
responses_builder.py - Логика формирования откликов модели в унифицированный вид.
"""

from typing import Any

from core.responses import ResponseSpec


class ResponsesBuilder:
    """Построение ResponseSpec из сырых логов модели."""

    @staticmethod
    def from_timeseries(
        timeseries_log: list[dict[str, Any]],
        items: list[tuple[str, str, str]],
    ) -> list[ResponseSpec]:
        """Сформировать непрерывные отклики из timeseries_log."""
        responses: list[ResponseSpec] = []
        for name, x_col, y_col in items:
            data = []
            for r in timeseries_log:
                if x_col in r and y_col in r:
                    data.append({x_col: r[x_col], y_col: r[y_col]})
            if not data:
                continue
            responses.append(
                ResponseSpec(
                    name=name,
                    kind="continuous",
                    x_col=x_col,
                    y_col=y_col,
                    data=data,
                )
            )
        return responses

    @staticmethod
    def from_cars_discrete(
        cars_log: list[dict[str, Any]],
        x_col: str,
        y_col: str,
        group_col: str | None = None,
        base_name: str = "time_in_system",
    ) -> list[ResponseSpec]:
        """Сформировать дискретные отклики: все + по группам."""
        responses: list[ResponseSpec] = []
        if not cars_log:
            return responses

        # Все
        responses.append(
            ResponseSpec(
                name=f"{base_name}_all",
                kind="discrete",
                x_col=x_col,
                y_col=y_col,
                data=cars_log,
            )
        )

        if group_col and group_col in cars_log[0]:
            # Уникальные группы
            groups = []
            seen = set()
            for c in cars_log:
                g = c.get(group_col)
                if g not in seen:
                    seen.add(g)
                    groups.append(g)
            for g in groups:
                filtered = [c for c in cars_log if c.get(group_col) == g]
                if not filtered:
                    continue
                responses.append(
                    ResponseSpec(
                        name=f"{base_name}_group_{group_col}_{g}",
                        kind="discrete",
                        x_col=x_col,
                        y_col=y_col,
                        data=filtered,
                    )
                )
        return responses

    @staticmethod
    def from_cars_discrete_fixed(
        cars_log: list[dict[str, Any]],
        x_col: str,
        y_col: str,
        specs: list[tuple[str, str | int | None]],
        filter_col: str,
    ) -> list[ResponseSpec]:
        """Фиксированный набор файлов (напр. по model_type 1 и 2)."""
        responses: list[ResponseSpec] = []
        if not cars_log:
            return responses

        for name, value in specs:
            if value is None:
                filtered = cars_log
            else:
                filtered = [c for c in cars_log if c.get(filter_col) == value]
            if not filtered:
                continue
            responses.append(
                ResponseSpec(
                    name=name,
                    kind="discrete",
                    x_col=x_col,
                    y_col=y_col,
                    data=filtered,
                )
            )
        return responses
