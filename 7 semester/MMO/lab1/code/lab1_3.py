import math

class Triangle:
    def __init__(self, a: float, b: float, c: float):
        self.a = a
        self.b = b
        self.c = c

    def is_valid(self) -> bool:
        """Проверка существования треугольника по неравенству треугольника."""
        return (self.a + self.b > self.c) and \
               (self.a + self.c > self.b) and \
               (self.b + self.c > self.a)

    def perimeter(self) -> float:
        """Нахождение периметра треугольника."""
        if not self.is_valid():
            raise ValueError("Треугольник с такими сторонами не существует!")
        return self.a + self.b + self.c

    def area(self) -> float:
        """Нахождение площади треугольника по формуле Герона."""
        if not self.is_valid():
            raise ValueError("Треугольник с такими сторонами не существует!")
        p = self.perimeter() / 2
        return math.sqrt(p * (p - self.a) * (p - self.b) * (p - self.c))


class House:
    def __init__(self, area: float, price: float):
        self._area = area
        self._price = price

    def final_price(self, discount: float) -> float:
        """Возвращает цену с учетом скидки (discount в процентах, например 10%)."""
        return self._price * (1 - discount / 100.0)


class SmallHouse(House):
    def __init__(self, price: float):
        super().__init__(area=40.0, price=price)


class Human:
    def __init__(self, name: str, money: float):
        self.name = name
        self.__money = money
        self.__home = None

    def __make_deal(self, house: House, price: float):
        """Приватный метод: уменьшает баланс и закрепляет дом."""
        self.__money -= price
        self.__home = house
        print(f"[Сделка] {self.name} успешно купил дом площадью {house._area} м² за {price} руб.")

    def buy_house(self, house: House, discount: float = 0.0):
        """Покупка дома с проверкой баланса."""
        cost = house.final_price(discount)
        if self.__money >= cost:
            self.__make_deal(house, cost)
        else:
            shortage = cost - self.__money
            print(f"[Внимание] У {self.name} недостаточно денег для покупки! Не хватает: {shortage} руб.")

    def info(self):
        home_str = f"дом площадью {self.__home._area} м²" if self.__home else "нет собственного жилья"
        print(f"Человек: {self.name} | Баланс: {self.__money} руб. | Недвижимость: {home_str}")


class Shape:
    def area(self) -> float:
        """Базовый метод нахождения площади."""
        return 0.0


class Circle(Shape):
    def __init__(self, radius: float):
        self.radius = radius

    def area(self) -> float:
        """Переопределенный метод: площадь круга pi * r^2."""
        return math.pi * (self.radius ** 2)


class Square(Shape):
    def __init__(self, side: float):
        self.side = side

    def area(self) -> float:
        """Переопределенный метод: площадь квадрата a^2."""
        return self.side ** 2


class Rectangle(Shape):
    def __init__(self, width: float, height: float):
        self.width = width
        self.height = height

    def area(self) -> float:
        """Переопределенный метод: площадь прямоугольника w * h."""
        return self.width * self.height


class BankAccount:
    bank_name = "Банк"
    interest_rate = 0.05 

    def __init__(self, owner: str, balance: float = 0.0):
        self.owner = owner
        self.balance = balance

   
    def deposit(self, amount: float):
        if amount > 0:
            self.balance += amount
            print(f"Счет {self.owner}: пополнение на {amount} руб. Баланс: {self.balance} руб.")
        else:
            print("Сумма пополнения должна быть положительной!")

   
    @classmethod
    def set_interest_rate(cls, new_rate: float):
        """Изменяет процентную ставку для всех счетов банка."""
        cls.interest_rate = new_rate
        print(f"Новая базовая ставка банка '{cls.bank_name}': {cls.interest_rate * 100}%")

    
    @staticmethod
    def is_valid_account_number(acc_number: str) -> bool:
        """Проверяет корректность 10-значного номера счета."""
        return acc_number.isdigit() and len(acc_number) == 10



if __name__ == "__main__":
    print("=== Задание 3.1: Triangle ===")
    try:
        t = Triangle(3, 4, 5)
        print(f"Треугольник 3, 4, 5 существует? {t.is_valid()}")
        print(f"Периметр: {t.perimeter()}")
        print(f"Площадь: {t.area():.2f}")
    except Exception as e:
        print(f"Ошибка: {e}")
    finally:
        print("Проверка Triangle завершена.")

    print("\n=== Задание 3.2: House, SmallHouse, Human ===")
    try:
        petya = Human("Петр", 25000)
        petya.info()
        
        cottage = House(area=120, price=60000)
        small_house = SmallHouse(price=20000)
        
        petya.buy_house(cottage, discount=10)
        
        petya.buy_house(small_house, discount=5)
        petya.info()
    finally:
        print("Проверка сделок завершена.")

    print("\n=== Задание 3.3: Полиморфизм фигур ===")
    shapes = [
        Circle(radius=5),
        Square(side=4),
        Rectangle(width=3, height=6)
    ]
    for s in shapes:
        print(f"Фигура {type(s).__name__}: площадь = {s.area():.2f}")

    print("\n=== Задание 3.4: Собственный класс BankAccount ===")
    acc = BankAccount("Иван Иванов", 1000)
    acc.deposit(500)
    BankAccount.set_interest_rate(0.07)
    print("Номер счета '1234567890' валиден?", BankAccount.is_valid_account_number("1234567890"))
    print("Номер счета '123ABC' валиден?", BankAccount.is_valid_account_number("123ABC"))