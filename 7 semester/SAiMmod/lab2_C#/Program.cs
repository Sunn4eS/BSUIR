using System;
using System.Collections.Generic;
using System.Linq;

namespace AutoRepairSimulation
{
    // Типы событий в системе
    enum EventType { Arrival, BodyRepairEnd, PaintEnd }

    // Класс события для списка расписания
    class Event : IComparable<Event>
    {
        public double Time { get; set; }
        public EventType Type { get; set; }
        public Car Car { get; set; }

        public int CompareTo(Event other)
        {
            return Time.CompareTo(other.Time);
        }
    }

    // Класс заявки (автомобиля)
    class Car
    {
        public int Id { get; set; }
        public int Model { get; set; } // 1 - высокий приоритет, 2 - низкий
        public double ArrivalTime { get; set; }
        public double RemainingBodyRepairTime { get; set; }
        public double PaintTime { get; set; }
    }

    class Program
    {
        // Глобальное модельное время
        static double CurrentTime = 0.0;
        static double LastEventTime = 0.0;

        // Датчик случайных чисел (единственный)
        static Random rng = new Random(12345);

        // Список событий (расписание)
        static List<Event> EventQueue = new List<Event>();

        // Состояние системы
        static Car[] BodyRepairPlaces = new Car[3]; // 3 рабочих места
        static Queue<Car> QueueModel1 = new Queue<Car>();
        static Queue<Car> QueueModel2 = new Queue<Car>();
        
        static Car PaintBoothPlace = null; // Покрасочная камера (считаем, что 1)
        static Queue<Car> PaintQueue = new Queue<Car>();

        // Статистика (отклики)
        static int ProcessedModel1 = 0;
        static int ProcessedModel2 = 0;
        static double TotalTimeInSystemModel1 = 0.0; // Дискретный отклик 1
        static double TotalTimeInSystemModel2 = 0.0; // Дискретный отклик 2
        
        // Интегралы для непрерывных откликов
        static double AreaBusyBodyRepair = 0.0;      // Непрерывный отклик 1
        static double AreaBodyRepairQueueLength = 0.0; // Непрерывный отклик 2

        // Параметры
        const double MaxTime = 1000.0; // Время моделирования
        const bool TraceMode = true;   // Режим трассировки состояния

        static void Main(string[] args)
        {
            Console.WriteLine("--- Старт имитационного моделирования (Вариант 3) ---");
            
            // Инициализация первых событий прибытия
            ScheduleEvent(CurrentTime + GenerateExponential(15.0), EventType.Arrival, CreateCar(1));
            ScheduleEvent(CurrentTime + GenerateExponential(10.0), EventType.Arrival, CreateCar(2));

            // Главный цикл (организация квазипараллелизма)
            while (EventQueue.Count > 0 && CurrentTime < MaxTime)
            {
                // Извлекаем ближайшее событие
                Event currentEvent = EventQueue[0];
                EventQueue.RemoveAt(0);

                // Сбор статистики непрерывных откликов до изменения времени
                double deltaTime = currentEvent.Time - CurrentTime;
                UpdateContinuousStats(deltaTime);

                CurrentTime = currentEvent.Time;

                // Обработка события
                switch (currentEvent.Type)
                {
                    case EventType.Arrival:
                        HandleArrival(currentEvent.Car);
                        // Планируем следующее прибытие такой же модели
                        ScheduleEvent(CurrentTime + GenerateExponential(currentEvent.Car.Model == 1 ? 15.0 : 10.0), 
                                      EventType.Arrival, CreateCar(currentEvent.Car.Model));
                        break;

                    case EventType.BodyRepairEnd:
                        HandleBodyRepairEnd(currentEvent.Car);
                        break;

                    case EventType.PaintEnd:
                        HandlePaintEnd(currentEvent.Car);
                        break;
                }
            }

            PrintResults();
        }

        static void HandleArrival(Car car)
        {
            Trace($"Прибытие автомобиля {car.Id} (Модель {car.Model})");

            if (car.Model == 1)
            {
                int emptyIndex = Array.IndexOf(BodyRepairPlaces, null);
                if (emptyIndex != -1)
                {
                    // Есть свободное место
                    StartBodyRepair(car, emptyIndex);
                }
                else
                {
                    // Мест нет, пытаемся вытеснить Модель 2
                    int victimIndex = Array.FindIndex(BodyRepairPlaces, c => c.Model == 2);
                    if (victimIndex != -1)
                    {
                        Car victim = BodyRepairPlaces[victimIndex];
                        Trace($"  Автомобиль {car.Id} (Мод 1) вытесняет {victim.Id} (Мод 2) с места {victimIndex}");
                        
                        // Отменяем событие завершения ремонта жертвы
                        Event victimEvent = EventQueue.First(e => e.Type == EventType.BodyRepairEnd && e.Car.Id == victim.Id);
                        EventQueue.Remove(victimEvent);
                        
                        // Пересчитываем остаток времени для жертвы и возвращаем в начало очереди
                        victim.RemainingBodyRepairTime = victimEvent.Time - CurrentTime;
                        var tempQueue = new Queue<Car>();
                        tempQueue.Enqueue(victim);
                        foreach (var q in QueueModel2) tempQueue.Enqueue(q);
                        QueueModel2 = tempQueue;

                        // Ставим Модель 1 на освободившееся место
                        StartBodyRepair(car, victimIndex);
                    }
                    else
                    {
                        // Все 3 места заняты Моделью 1, становимся в очередь
                        QueueModel1.Enqueue(car);
                        Trace($"  Автомобиль {car.Id} (Мод 1) стал в очередь кузовного ремонта.");
                    }
                }
            }
            else // Model == 2
            {
                int emptyIndex = Array.IndexOf(BodyRepairPlaces, null);
                if (emptyIndex != -1)
                {
                    StartBodyRepair(car, emptyIndex);
                }
                else
                {
                    QueueModel2.Enqueue(car);
                    Trace($"  Автомобиль {car.Id} (Мод 2) стал в очередь кузовного ремонта.");
                }
            }
        }

        static void HandleBodyRepairEnd(Car car)
        {
            int placeIndex = Array.IndexOf(BodyRepairPlaces, car);
            BodyRepairPlaces[placeIndex] = null;
            Trace($"Окончание кузовного ремонта авто {car.Id} (Модель {car.Model})");

            // Отправляем в покрасочную камеру
            if (PaintBoothPlace == null)
            {
                StartPaint(car);
            }
            else
            {
                PaintQueue.Enqueue(car);
                Trace($"  Автомобиль {car.Id} ожидает покраски.");
            }

            // Проверяем очередь на кузовной ремонт (Модель 1 в приоритете)
            if (QueueModel1.Count > 0)
            {
                StartBodyRepair(QueueModel1.Dequeue(), placeIndex);
            }
            else if (QueueModel2.Count > 0)
            {
                StartBodyRepair(QueueModel2.Dequeue(), placeIndex);
            }
        }

        static void HandlePaintEnd(Car car)
        {
            PaintBoothPlace = null;
            double timeInSystem = CurrentTime - car.ArrivalTime;
            Trace($"Окончание покраски и выход из системы авто {car.Id}. Время в системе: {timeInSystem:F2}");

            // Накопление статистики
            if (car.Model == 1)
            {
                ProcessedModel1++;
                TotalTimeInSystemModel1 += timeInSystem;
            }
            else
            {
                ProcessedModel2++;
                TotalTimeInSystemModel2 += timeInSystem;
            }

            // Берем следующего на покраску
            if (PaintQueue.Count > 0)
            {
                StartPaint(PaintQueue.Dequeue());
            }
        }

        static void StartBodyRepair(Car car, int placeIndex)
        {
            BodyRepairPlaces[placeIndex] = car;
            ScheduleEvent(CurrentTime + car.RemainingBodyRepairTime, EventType.BodyRepairEnd, car);
            Trace($"  Начат кузовной ремонт авто {car.Id} на месте {placeIndex}. Окончание в {CurrentTime + car.RemainingBodyRepairTime:F2}");
        }

        static void StartPaint(Car car)
        {
            PaintBoothPlace = car;
            ScheduleEvent(CurrentTime + car.PaintTime, EventType.PaintEnd, car);
            Trace($"  Начата покраска авто {car.Id}. Окончание в {CurrentTime + car.PaintTime:F2}");
        }

        static void ScheduleEvent(double time, EventType type, Car car)
        {
            EventQueue.Add(new Event { Time = time, Type = type, Car = car });
            EventQueue.Sort(); // Поддержание упорядоченного списка событий по времени
        }

        static void UpdateContinuousStats(double dt)
        {
            int busyPlaces = BodyRepairPlaces.Count(c => c != null);
            AreaBusyBodyRepair += busyPlaces * dt;

            int queueLen = QueueModel1.Count + QueueModel2.Count;
            AreaBodyRepairQueueLength += queueLen * dt;
        }

        static int carCounter = 1;
        static Car CreateCar(int model)
        {
            return new Car
            {
                Id = carCounter++,
                Model = model,
                ArrivalTime = CurrentTime,
                RemainingBodyRepairTime = GenerateNormal(20.0, 5.0),
                PaintTime = GenerateNormal(10.0, 2.0)
            };
        }

        static double GenerateExponential(double mean)
        {
            return -mean * Math.Log(1.0 - rng.NextDouble());
        }

        static double GenerateNormal(double mean, double stdDev)
        {
            double u1 = 1.0 - rng.NextDouble();
            double u2 = 1.0 - rng.NextDouble();
            double randStdNormal = Math.Sqrt(-2.0 * Math.Log(u1)) * Math.Sin(2.0 * Math.PI * u2);
            return Math.Max(0.1, mean + stdDev * randStdNormal);
        }

        static void Trace(string msg)
        {
            if (TraceMode)
                Console.WriteLine($"[T={CurrentTime:F2}] {msg}");
        }

        static void PrintResults()
        {
            Console.WriteLine("\n=== Результаты имитации ===");
            
            // Дискретные отклики
            double avgTime1 = ProcessedModel1 > 0 ? TotalTimeInSystemModel1 / ProcessedModel1 : 0;
            double avgTime2 = ProcessedModel2 > 0 ? TotalTimeInSystemModel2 / ProcessedModel2 : 0;
            
            Console.WriteLine($"Обслужено автомобилей Модель 1: {ProcessedModel1}");
            Console.WriteLine($"Обслужено автомобилей Модель 2: {ProcessedModel2}");
            Console.WriteLine($"[Дискретный] Ср. время в системе (Модель 1): {avgTime1:F2} мин.");
            Console.WriteLine($"[Дискретный] Ср. время в системе (Модель 2): {avgTime2:F2} мин.");

            // Непрерывные отклики
            double avgBusy = AreaBusyBodyRepair / CurrentTime;
            double avgQueue = AreaBodyRepairQueueLength / CurrentTime;
            
            Console.WriteLine($"[Непрерывный] Ср. кол-во занятых мест кузовного ремонта: {avgBusy:F2} (из 3)");
            Console.WriteLine($"[Непрерывный] Ср. длина очереди на кузовной ремонт: {avgQueue:F2}");
        }
    }
}