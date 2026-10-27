"""Модуль совместимости со старым именем ``simulation.model``.

Основная реализация находится в :mod:`simulation.workshop_model`. Реэкспорт
сохранён, чтобы старые импорты не ломались.
"""

from simulation.workshop_model import Car, ModelType, WorkshopModel

__all__ = ["Car", "ModelType", "WorkshopModel"]
