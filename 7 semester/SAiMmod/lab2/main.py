
import heapq
import random
import math
from collections import deque

# Типы событий
class EventType:
    ARRIVAL = 1
    BODY_REPAIR_END = 2
    PAINT_END = 3

# Класс заявки (автомобиля)
class Car:
    def __init__(self, car_id, model, arrival_time, body_time, paint_time):
        self.id = car_id
        self.model = model  # 1 - высокий приоритет, 2 - низкий
        self.arrival_time = arrival_time
        self.remaining_body_repair_time = body_time
        self.paint_time = paint_time

# Класс события для списка расписания
class Event:
    def __init__(self, time, event_type, car):
        self.time = time
        self.type = event_type
        self.car = car
        self.is_cancelled = False # Флаг для отмены события при вытеснении

    # Сравнение для работы heapq (сортировка по времени)
    def __lt__(self, other):
        return self.time < other.time

class AutoRepairSimulation:
    def __init__(self):
        self.current_time = 0.0
        self.max_time = 1000.0
        self.trace_mode = True
        
        # Единственный датчик случайных чисел
        self.rng = random.Random(12345)
        
        # Список событий (расписание)
        self.event_queue = []
        
        # Состояние системы
        self.body_repair_places = [None, None, None] # 3 рабочих места
        self.queue_model_1 = deque()
        self.queue_model_2 = deque()
        self.paint_booth_place = None
        self.paint_queue = deque()
        
        # Статистика (Отклики)
        self.processed_model_1 = 0
        self.processed_model_2 = 0
        self.total_time_in_system_model_1 = 0.0 # Дискретный отклик 1
        self.total_time_in_system_model_2 = 0.0 # Дискретный отклик 2
        
        # Интегралы для непрерывных откликов
        self.area_busy_body_repair = 0.0      # Непрерывный отклик 1
        self.area_body_repair_queue_length = 0.0 # Непрерывный отклик 2
        
        self.car_counter = 1

    def generate_exponential(self, mean):
        return -mean * math.log(1.0 - self.rng.random())

    def generate_normal(self, mean, std_dev):
        return max(0.1, self.rng.gauss(mean, std_dev))

    def create_car(self, model):
        car = Car(
            car_id=self.car_counter,
            model=model,
            arrival_time=self.current_time,
            body_time=self.generate_normal(20.0, 5.0),
            paint_time=self.generate_normal(10.0, 2.0)
        )
        self.car_counter += 1
        return car

    def schedule_event(self, event_time, event_type, car):
        heapq.heappush(self.event_queue, Event(event_time, event_type, car))

    def trace(self, msg):
        if self.trace_mode:
            print(f"[T={self.current_time:06.2f}] {msg}")

    def update_continuous_stats(self, dt):
        busy_places = sum(1 for place in self.body_repair_places if place is not None)
        self.area_busy_body_repair += busy_places * dt
        
        queue_len = len(self.queue_model_1) + len(self.queue_model_2)
        self.area_body_repair_queue_length += queue_len * dt

    def start_body_repair(self, car, place_index):
        self.body_repair_places[place_index] = car
        finish_time = self.current_time + car.remaining_body_repair_time
        self.schedule_event(finish_time, EventType.BODY_REPAIR_END, car)
        self.trace(f"  Начат кузовной ремонт авто {car.id} на месте {place_index}. Окончание в {finish_time:.2f}")

    def start_paint(self, car):
        self.paint_booth_place = car
        finish_time = self.current_time + car.paint_time
        self.schedule_event(finish_time, EventType.PAINT_END, car)
        self.trace(f"  Начата покраска авто {car.id}. Окончание в {finish_time:.2f}")

    def handle_arrival(self, car):
        self.trace(f"Прибытие автомобиля {car.id} (Модель {car.model})")
        
        if car.model == 1:
            try:
                empty_index = self.body_repair_places.index(None)
                self.start_body_repair(car, empty_index)
            except ValueError:
                # Мест нет, ищем Модель 2 для вытеснения
                victim_index = -1
                for i, place in enumerate(self.body_repair_places):
                    if place is not None and place.model == 2:
                        victim_index = i
                        break
                
                if victim_index != -1:
                    victim = self.body_repair_places[victim_index]
                    self.trace(f"  Автомобиль {car.id} (Мод 1) вытесняет {victim.id} (Мод 2) с места {victim_index}")
                    
                    # Находим и отменяем событие окончания ремонта жертвы
                    for event in self.event_queue:
                        if event.type == EventType.BODY_REPAIR_END and event.car.id == victim.id and not event.is_cancelled:
                            event.is_cancelled = True
                            victim.remaining_body_repair_time = event.time - self.current_time
                            break
                    
                    # Возвращаем жертву в начало очереди
                    self.queue_model_2.appendleft(victim)
                    self.start_body_repair(car, victim_index)
                else:
                    # Все места заняты Моделью 1
                    self.queue_model_1.append(car)
                    self.trace(f"  Автомобиль {car.id} (Мод 1) стал в очередь кузовного ремонта.")
        else: # model == 2
            try:
                empty_index = self.body_repair_places.index(None)
                self.start_body_repair(car, empty_index)
            except ValueError:
                self.queue_model_2.append(car)
                self.trace(f"  Автомобиль {car.id} (Мод 2) стал в очередь кузовного ремонта.")

    def handle_body_repair_end(self, car):
        place_index = self.body_repair_places.index(car)
        self.body_repair_places[place_index] = None
        self.trace(f"Окончание кузовного ремонта авто {car.id} (Модель {car.model})")

        # Отправляем в покраску
        if self.paint_booth_place is None:
            self.start_paint(car)
        else:
            self.paint_queue.append(car)
            self.trace(f"  Автомобиль {car.id} ожидает покраски.")

        # Берем следующего на ремонт (приоритет Модель 1)
        if self.queue_model_1:
            self.start_body_repair(self.queue_model_1.popleft(), place_index)
        elif self.queue_model_2:
            self.start_body_repair(self.queue_model_2.popleft(), place_index)

    def handle_paint_end(self, car):
        self.paint_booth_place = None
        time_in_system = self.current_time - car.arrival_time
        self.trace(f"Окончание покраски и выход из системы авто {car.id}. Время в системе: {time_in_system:.2f}")

        if car.model == 1:
            self.processed_model_1 += 1
            self.total_time_in_system_model_1 += time_in_system
        else:
            self.processed_model_2 += 1
            self.total_time_in_system_model_2 += time_in_system

        if self.paint_queue:
            self.start_paint(self.paint_queue.popleft())

    def run(self):
        print("--- Старт имитационного моделирования (Python) ---")
        
        # Планируем первые прибытия
        self.schedule_event(self.generate_exponential(15.0), EventType.ARRIVAL, self.create_car(1))
        self.schedule_event(self.generate_exponential(10.0), EventType.ARRIVAL, self.create_car(2))

        while self.event_queue and self.current_time < self.max_time:
            current_event = heapq.heappop(self.event_queue)
            
            # Пропускаем отмененные события (при вытеснении)
            if current_event.is_cancelled:
                continue

            dt = current_event.time - self.current_time
            self.update_continuous_stats(dt)
            self.current_time = current_event.time

            if current_event.type == EventType.ARRIVAL:
                self.handle_arrival(current_event.car)
                # Планируем следующее прибытие такой же модели
                mean_arrival = 15.0 if current_event.car.model == 1 else 10.0
                next_time = self.current_time + self.generate_exponential(mean_arrival)
                self.schedule_event(next_time, EventType.ARRIVAL, self.create_car(current_event.car.model))
                
            elif current_event.type == EventType.BODY_REPAIR_END:
                self.handle_body_repair_end(current_event.car)
                
            elif current_event.type == EventType.PAINT_END:
                self.handle_paint_end(current_event.car)

        self.print_results()

    def print_results(self):
        print("\n=== Результаты имитации ===")
        avg_time1 = self.total_time_in_system_model_1 / self.processed_model_1 if self.processed_model_1 > 0 else 0
        avg_time2 = self.total_time_in_system_model_2 / self.processed_model_2 if self.processed_model_2 > 0 else 0
        
        print(f"Обслужено автомобилей Модель 1: {self.processed_model_1}")
        print(f"Обслужено автомобилей Модель 2: {self.processed_model_2}")
        print(f"[Дискретный] Ср. время в системе (Модель 1): {avg_time1:.2f} мин.")
        print(f"[Дискретный] Ср. время в системе (Модель 2): {avg_time2:.2f} мин.")

        avg_busy = self.area_busy_body_repair / self.current_time
        avg_queue = self.area_body_repair_queue_length / self.current_time
        
        print(f"[Непрерывный] Ср. кол-во занятых мест кузовного ремонта: {avg_busy:.2f} (из 3)")
        print(f"[Непрерывный] Ср. длина очереди на кузовной ремонт: {avg_queue:.2f}")

if __name__ == "__main__":
    sim = AutoRepairSimulation()
    sim.run()

