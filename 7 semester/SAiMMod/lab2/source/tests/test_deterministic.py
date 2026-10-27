"""Детерминированные тесты логики вытеснения и дообслуживания."""

from __future__ import annotations

from statistics import fmean

import pytest

from config.model_config import WorkshopConfig
from simulation.workshop_model import ModelType, WorkshopModel


def _deterministic_config(**overrides: object) -> WorkshopConfig:
    """Конфигурация с отключёнными случайными потоками и обслуживанием."""

    defaults: dict[str, object] = {
        "num_body_places": 3,
        "num_paint_booths": 1,
        # Большие интервалы не важны: в тестах приходы задаются вручную.
        "mean_arrival_m1": 1000.0,
        "mean_arrival_m2": 1000.0,
        "body_repair_mu": 10.0,
        "body_repair_sigma": 0.0,
        "paint_ratio": 0.5,
        "paint_sigma": 0.0,
        "sim_time": 1000.0,
        "seed": 1,
        "trace": False,
    }
    defaults.update(overrides)
    return WorkshopConfig(**defaults)  # type: ignore[arg-type]


def test_preemption() -> None:
    """Модель 1 вытесняет Модель 2, когда все три кузовных места заняты.

    Сценарий:
    * t=0 -- три Модели 2 начинают кузовной ремонт по 10 минут;
    * t=1 -- приходит Модель 1 с ремонтом 5 минут;
    * одно место освобождается, прерванная Модель 2 сохраняет 9 минут;
    * после ухода Модели 1 прерванная Модель 2 продолжает ремонт.
    """

    model = WorkshopModel(_deterministic_config())
    for _ in range(3):
        model.add_car(
            ModelType.MODEL_2,
            entry_time=0.0,
            body_duration=10.0,
            paint_duration=1.0,
        )
    model.add_car(
        ModelType.MODEL_1,
        entry_time=1.0,
        body_duration=5.0,
        paint_duration=1.0,
    )

    result = model.run(start_arrivals=False)

    assert result.preemptions_model_2 == 1
    assert result.preemption_remaining_times == pytest.approx([9.0])
    assert result.preemption_times == pytest.approx([1.0])

    assert result.serviced_model_1 == 1
    assert result.serviced_model_2 == 3
    assert result.total_run_time == pytest.approx(16.0)

    # Времена в системе: М1 завершилась в 7, М2 -- в 11, 12 и 16.
    assert sorted(result.car_system_times) == pytest.approx([6.0, 11.0, 12.0, 16.0])

    # Ни в один момент занятость кузова не превышает трёх мест.
    assert max(value for _, value in result.raw_body_busy) <= 3.0

    # Проверяем интегральные средние вручную:
    # очередь: 1 автомобиль ждёт 5 минут из 16;
    # кузов: 3 места заняты 10 минут, затем 1 место -- 5 минут;
    # покраска: занята 1+2+1 = 4 минуты.
    assert result.avg_body_queue_length == pytest.approx(5.0 / 16.0)
    assert result.avg_busy_body_places == pytest.approx(35.0 / 16.0)
    assert result.avg_busy_paint_booths == pytest.approx(4.0 / 16.0)


def test_no_preemption_when_body_slot_is_free() -> None:
    """Если есть свободное кузовное место, Модель 1 не прерывает Модель 2."""

    model = WorkshopModel(_deterministic_config())
    model.add_car(
        ModelType.MODEL_2,
        entry_time=0.0,
        body_duration=10.0,
        paint_duration=1.0,
    )
    model.add_car(
        ModelType.MODEL_1,
        entry_time=1.0,
        body_duration=5.0,
        paint_duration=1.0,
    )

    result = model.run(start_arrivals=False)

    assert result.preemptions_model_2 == 0
    assert result.serviced_model_1 == 1
    assert result.serviced_model_2 == 1
    assert result.total_run_time == pytest.approx(11.0)
    assert sorted(result.car_system_times) == pytest.approx([6.0, 11.0])


def test_draining() -> None:
    """После sim_time новые заявки не принимаются, но все старые дообслуживаются."""

    config = _deterministic_config(
        mean_arrival_m1=5.0,
        mean_arrival_m2=8.0,
        body_repair_mu=10.0,
        body_repair_sigma=2.0,
        paint_sigma=1.0,
        sim_time=100.0,
        seed=7,
    )
    model = WorkshopModel(config)
    result = model.run()

    assert result.total_run_time >= config.sim_time
    assert all(entry <= config.sim_time + 1e-9 for entry in result.entry_times)

    # Баланс "прибыло = обслужено" означает отсутствие потерянных автомобилей.
    arrived = len(result.entry_times)
    served = result.serviced_model_1 + result.serviced_model_2
    assert arrived == served
    assert len(result.car_system_times) == arrived
    assert model.active_cars == 0

    assert max(result.exit_times) <= result.total_run_time + 1e-9
    assert result.total_run_time == pytest.approx(
        max(config.sim_time, max(result.exit_times))
    )
    assert result.avg_car_system_time == pytest.approx(
        fmean(result.car_system_times)
    )


def test_paint_queue_is_fifo() -> None:
    """Покрасочная камера обслуживает автомобили в порядке запроса."""

    model = WorkshopModel(_deterministic_config())
    for _ in range(3):
        model.add_car(
            ModelType.MODEL_2,
            entry_time=0.0,
            body_duration=0.0,
            paint_duration=5.0,
        )

    result = model.run(start_arrivals=False)

    # Кузовной ремонт нулевой, поэтому все три автомобиля одновременно
    # встают в очередь покраски. Выходы должны идти строго по порядку.
    assert result.exit_times == pytest.approx([5.0, 10.0, 15.0])
    assert result.total_run_time == pytest.approx(15.0)


def test_trace_preemption_format(capsys: pytest.CaptureFixture[str]) -> None:
    """Строка вытеснения должна соответствовать формату из задания."""

    model = WorkshopModel(_deterministic_config(trace=True))
    for _ in range(3):
        model.add_car(
            ModelType.MODEL_2,
            entry_time=0.0,
            body_duration=10.0,
            paint_duration=1.0,
        )
    model.add_car(
        ModelType.MODEL_1,
        entry_time=1.0,
        body_duration=5.0,
        paint_duration=1.0,
    )

    model.run(start_arrivals=False)
    output = capsys.readouterr().out

    assert (
        "[t=1.00] | Автомобиль: M1_1 | Событие: ВЫТЕСНЕНИЕ | "
        "Прерван: M2_1 (Осталось: 9.00 мин)"
    ) in output


def test_same_seed_is_reproducible() -> None:
    """Одинаковый seed должен давать полностью одинаковые отклики."""

    config = _deterministic_config(
        mean_arrival_m1=6.0,
        mean_arrival_m2=9.0,
        body_repair_sigma=3.0,
        paint_sigma=1.0,
        sim_time=120.0,
        seed=123,
    )
    first = WorkshopModel(config).run()
    second = WorkshopModel(config).run()

    assert first.to_flat_dict() == second.to_flat_dict()
    assert first.car_system_times == second.car_system_times
    assert first.entry_times == second.entry_times
