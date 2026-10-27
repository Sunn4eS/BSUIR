"""Тесты корректности интегрального усреднения непрерывных откликов."""

from __future__ import annotations

import simpy
import pytest

from simulation.monitors import ContinuousVariableTracker


def test_integral_calculation() -> None:
    """Ручной расчёт площади под ступенчатой функцией.

    X(t) = 0 на [0, 2), 5 на [2, 5), 3 на [5, 10].
    Площадь = 0*2 + 5*3 + 3*5 = 30, среднее = 30/10 = 3.
    """

    env = simpy.Environment()
    tracker = ContinuousVariableTracker(env)

    def changes() -> simpy.events.Generator:
        yield env.timeout(2.0)
        tracker.set_value(5.0)
        yield env.timeout(3.0)
        tracker.set_value(3.0)

    env.process(changes())
    env.run()

    assert tracker.get_area(10.0) == pytest.approx(30.0)
    assert tracker.get_time_weighted_average(10.0) == pytest.approx(3.0)


def test_final_interval_is_included() -> None:
    """Последнее значение должно действовать до final_time."""

    env = simpy.Environment()
    tracker = ContinuousVariableTracker(env)
    tracker.set_value(2.0, at=1.0)
    tracker.set_value(4.0, at=2.0)

    # [0,1): 0; [1,2): 2; [2,4): 4 -> площадь 0 + 2 + 8 = 10.
    assert tracker.get_area(4.0) == pytest.approx(10.0)
    assert tracker.get_time_weighted_average(4.0) == pytest.approx(2.5)


def test_duplicate_value_does_not_add_history_point() -> None:
    """Повторная установка того же значения не создаёт лишнюю точку."""

    env = simpy.Environment()
    tracker = ContinuousVariableTracker(env)
    tracker.set_value(1.0, at=1.0)
    history_size = len(tracker.history)
    tracker.set_value(1.0, at=2.0)

    assert len(tracker.history) == history_size
    assert tracker.history[-1] == (1.0, 1.0)


def test_history_cannot_move_back_in_time() -> None:
    """История процесса должна быть неубывающей по времени."""

    env = simpy.Environment()
    tracker = ContinuousVariableTracker(env)
    tracker.set_value(1.0, at=5.0)

    with pytest.raises(ValueError):
        tracker.set_value(2.0, at=4.0)


def test_zero_final_time_returns_zero() -> None:
    """Для нулевой длины прогона среднее не определено и равно нулю."""

    env = simpy.Environment()
    tracker = ContinuousVariableTracker(env, initial_value=3.0)

    assert tracker.get_time_weighted_average(0.0) == 0.0
    assert tracker.get_area(0.0) == 0.0


def test_average_can_be_taken_before_last_history_point() -> None:
    """final_time может находиться между двумя изменениями состояния."""

    env = simpy.Environment()
    tracker = ContinuousVariableTracker(env)
    tracker.set_value(10.0, at=2.0)
    tracker.set_value(20.0, at=8.0)

    # На [0, 5] действует значение 10.
    assert tracker.get_area(5.0) == pytest.approx(30.0)
    assert tracker.get_time_weighted_average(5.0) == pytest.approx(6.0)
