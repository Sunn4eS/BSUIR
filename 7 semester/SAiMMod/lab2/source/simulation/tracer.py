"""Трассировка событий имитационной модели.

Класс :class:`Tracer` намеренно не зависит от логики модели: он только
форматирует и печатает события. При ``enabled=False`` все вызовы становятся
почти бесплатными, поэтому трассировку можно включать флагом конфигурации.
"""

from __future__ import annotations

import simpy


class Tracer:
    """Печатает шаги модели в едином формате.

    Пример строки::

        [t=12.45] | Автомобиль: M1_3 | Событие: ВЫТЕСНЕНИЕ | Прерван: M2_1 (Осталось: 5.20 мин)
    """

    def __init__(self, env: simpy.Environment, enabled: bool = False) -> None:
        self.env = env
        self.enabled = enabled
        self._header_printed = False

    def _print_header(self) -> None:
        """Печатает заголовок один раз перед первым событием."""

        if self._header_printed:
            return
        self._header_printed = True
        print("\n" + "=" * 110)
        print("ТРАССИРОВКА СОБЫТИЙ")
        print("=" * 110)

    def log(self, car_id: str, event: str, details: str = "") -> None:
        """Записывает одно событие.

        :param car_id: идентификатор автомобиля, например ``M1_3``.
        :param event: название события, например ``ВЫТЕСНЕНИЕ``.
        :param details: дополнительные сведения (остаток времени, очередь и т.п.).
        """

        if not self.enabled:
            return

        self._print_header()
        line = f"[t={self.env.now:.2f}] | Автомобиль: {car_id} | Событие: {event}"
        if details:
            line += f" | {details}"
        print(line)
