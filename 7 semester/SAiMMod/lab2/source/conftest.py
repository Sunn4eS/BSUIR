"""Настройка путей для запуска pytest из корня репозитория.

Проект использует ``source`` как корень пакетов (``config``, ``simulation`` и
т.д.), поэтому добавляем этот каталог в ``sys.path`` до импорта тестовых
модулей.
"""

from __future__ import annotations

import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))
