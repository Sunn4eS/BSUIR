# Имитационная модель участка СТО

Проект реализует дискретно-событийную модель участка авторемонтной станции на
`simpy`. Корнем проекта является каталог `source/`.

## Установка

```bash
cd source
python -m pip install -r requirements.txt
```

## Запуск

```bash
# Короткий прогон с трассировкой событий
python main.py --mode trace --sim-time 60

# Верификация: 10 репликаций и графики накопленных средних
python main.py --mode verify --replications 10

# Параметрический скан: mean_arrival_m1 от 5 до 25 с шагом 5
python main.py --mode sweep \
  --sweep-param mean_arrival_m1 \
  --sweep-start 5 \
  --sweep-stop 25 \
  --sweep-step 5 \
  --seeds 10
```

Графики и CSV-таблицы сохраняются в `source/plots/` по умолчанию. Каталог можно
изменить через `--plots-dir`.

## Тесты

```bash
cd source
python -m pytest -q
```

## Структура

```text
source/
├── config/model_config.py       # входные параметры и валидация
├── simulation/
│   ├── tracer.py                # трассировка событий
│   ├── monitors.py              # интегральные и дискретные отклики
│   └── workshop_model.py        # модель SimPy
├── experiments/
│   ├── runner.py                # одиночный прогон
│   ├── verification.py          # репликации и накопленные средние
│   └── sweep_runner.py          # параметрический скан
├── analysis/visualizer.py       # графики
├── tests/                       # pytest-тесты
├── main.py                      # CLI
└── requirements.txt
```

## Особенности модели

- Один генератор ПСЧ `random.Random(seed)` на прогон.
- Кузовной участок: `simpy.PreemptiveResource(capacity=3)`, Модель 1 имеет
  приоритет и может вытеснить Модель 2.
- Вытесненная Модель 2 сохраняет остаток кузовного ремонта и возвращается в
  очередь.
- Покраска: `simpy.Resource(capacity=1)` с дисциплиной FIFO.
- После `sim_time` новые заявки не принимаются, но все уже принятые автомобили
  дообслуживаются. Длина прогона равна `max(sim_time, момент последнего ухода)`.
- В результате сохраняются 8 откликов из задания: три интегральных средних,
  времена в системе, три аддитивных счётчика и `T_final`, а также сырые ряды для
  графиков.
