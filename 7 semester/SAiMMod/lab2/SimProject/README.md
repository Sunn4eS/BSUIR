Быстрый старт

1. Требования к окружению

   Python 3.10+

   Менеджер пакетов pip

1. Клонирование и создание виртуального окружения

Linux / macOS:
code Bash

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

Windows (PowerShell):
code Powershell

python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt

3. Запуск симуляции

Запуск со стандартным конфигурационным файлом config.json:
code Bash

python main.py

Запуск с кастомным конфигурационным файлом:
code Bash

python main.py --config path/to/my_config.json

⚙️ Параметры конфигурации (config.json)
Секция Параметр Тип Описание
simulation sim_time float Базовый горизонт моделирования (

Tsim
Tsim​

).
drain_mode bool true — с дообслуживанием, false — строгий обрыв в sim_time.
seed int Базовое зерно генератора случайных чисел.
logging trace_enabled bool Включение/отключение пошагового лога событий.
log_to_file bool true — запись в trace.log, false — вывод в консоль (stdout).
resources body_workstations int Количество рабочих мест кузовного участка (по умолчанию: 3).
paint_chambers int Количество покрасочных камер (по умолчанию: 1).
arrival_rates model_1_mean_interval float Математическое ожидание интервала прихода Модели 1 (

Exp
Exp

).
model_2_mean_interval float Математическое ожидание интервала прихода Модели 2 (

Exp
Exp

).
service_times body_repair.mean float Матожидание времени кузовного ремонта (

N
N

).
body_repair.std float Стандартное отклонение кузовного ремонта.
paint.mean_ratio float Коэффициент пропорциональности среднего времени покраски:

μpaint=k⋅Tкузов
μpaint​=k⋅Tкузов​

.
paint.std float Стандартное отклонение времени покраски.
📊 Сохраняемые отклики модели

Каждый запуск создает уникальную папку ./plots/<timestamp>/.

1. timeseries_metrics.csv (Непрерывные отклики)

Фиксируются при каждом событии изменения состояния очередей и постов:

    timestamp — модельное время события.

    body_queue_length — длина очереди на кузовной ремонт.

    body_busy_places — число занятых кузовных постов (


    0…3
    0…3



    ).

    paint_queue_length — длина очереди в покрасочную камеру.

    paint_busy_places — занятость покрасочной камеры (


    0…1
    0…1



    ).

2. cars_metrics.csv (Дискретные отклики)

Формируется по мере выезда автомобилей:

    car_id — уникальный идентификатор авто (Car_M1_X или Car_M2_Y).

    model_type — модель (1 или 2).

    arrival_time, exit_time — время прибытия и покидания СТО.

    time_in_system — суммарное время нахождения в системе (Turnaround Time).

    body_wait_time, body_work_time — время ожидания и чистой работы на кузовном посту.

    paint_wait_time, paint_work_time — время ожидания и покраски.

    preemptions — число прерываний обслуживания данного авто (для Модели 2).

3. summary_metrics.csv (Аддитивные и финальные отклики)

   run_duration — общая длительность прогона (с учетом дообслуживания).

   finished_model_1, finished_model_2 — число полностью обслуженных авто.

   preemptions_model_2 — общее число прерываний Модели 2 за прогон.

   drain_mode_applied — флаг режима завершения.

🧩 Расширение системы (Подключение новой модели)

Благодаря паттерну Dependency Injection замена логики не требует изменения инфраструктурного кода:

    Создайте файл models/my_new_model.py.

    Реализуйте интерфейс ISimulationModel:
    code Python

    from interfaces import ISimulationModel, SimulationArtifacts

    class MyNewModel(ISimulationModel):
        def __init__(self, config: dict, logger):
            self.config = config
            self.logger = logger

        def build_and_run(self) -> SimulationArtifacts:
            # Ваша логика SimPy
            return SimulationArtifacts(summary=..., timeseries=..., cars=...)

    В main.py замените передаваемый класс:
    code Python

    # runner = SimulationRunner(args.config, AutoRepairShopModel)
    runner = SimulationRunner(args.config, MyNewModel)
    runner.execute()

Все механизмы сборки логов, формирования структуры каталогов и выгрузки CSV продолжат работать штатно.
code Code
