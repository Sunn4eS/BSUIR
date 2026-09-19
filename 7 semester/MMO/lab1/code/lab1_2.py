def is_password_good(password: str) -> bool:
    try:
        if not isinstance(password, str):
            return False
        
        is_long_enough = len(password) >= 8
        has_upper = any(c.isupper() for c in password)
        has_digit = any(c.isdigit() for c in password)
        
        return is_long_enough and has_upper and has_digit
    except Exception:
        return False
    finally:
        pass


def process_data(data):
    print(f"\nОбработка аргумента типа: {type(data).__name__}")
    try:
        if isinstance(data, dict):
            if not data:
                print("Словарь пуст!")
            else:
                max_key = max(data, key=data.get)
                print(f"Ключ с максимальным значением: {max_key} (значение: {data[max_key]})")
        
        elif isinstance(data, list):
            count = 0
            for item in data:
                if isinstance(item, (int, float)) and item < 0:
                    break
                count += 1
            print(f"Количество элементов до первого отрицательного: {count}")
            
        elif isinstance(data, (int, float)):
            if isinstance(data, float) or data < 2:
                print(f"Число {data} не является простым.")
            else:
                is_prime = True
                for i in range(2, int(data**0.5) + 1):
                    if data % i == 0:
                        is_prime = False
                        break
                print(f"Число {data} {'простое' if is_prime else 'составное (не простое)'}.")
                
        elif isinstance(data, str):
            reversed_str = data[::-1]
            digit_sum = sum(int(c) for c in data if c.isdigit())
            print(f"Строка в обратном порядке: '{reversed_str}'")
            print(f"Сумма цифр в строке: {digit_sum}")
        else:
            print("Тип данных не поддерживается данной функцией.")
            
    except Exception as e:
        print(f"Ошибка при обработке: {e}")
    finally:
        print("Завершение вызова process_data().")


def chess_board(n: int, m: int):
    print(f"\n--- Шахматная доска {n}x{m} ---")
    try:
        if n <= 0 or m <= 0:
            raise ValueError("Размеры матрицы должны быть натуральными числами!")
            
        matrix = []
        for i in range(n):
            row = []
            for j in range(m):
                if (i + j) % 2 == 0:
                    row.append(".")
                else:
                    row.append("*")
            matrix.append(row)
            
        for row in matrix:
            print(" ".join(row))
    except Exception as e:
        print(f"Ошибка: {e}")
    finally:
        print("Матрица сгенерирована.")


def demo_exception():
    print("\n--- Демонстрация механизма try / except / finally ---")
    try:
        val = input("Введите число для деления 100 на него: ")
        num = float(val)
        res = 100 / num
        print(f"100 / {num} = {res}")
    except ValueError:
        print("Исключение: Введено нечисловое значение!")
    except ZeroDivisionError:
        print("Исключение: Деление на ноль невозможно!")
    else:
        print("Блок else: Ошибок не возникло, деление успешно выполнено.")
    finally:
        print("Блок finally: Этот блок выполняется ВСЕГДА, независимо от ошибок.")


if __name__ == "__main__":
    print("Тестирование паролей:")
    print("Pass1234 ->", is_password_good("Pass1234"))  
    print("password ->", is_password_good("password"))  
    print("PassWord ->", is_password_good("PassWord"))  

    process_data({"a": 10, "b": 45, "c": 20})
    process_data([1, 4, 8, -3, 9, 2])
    process_data(17)
    process_data(18)
    process_data("Python 2026 Lab 1")

    chess_board(4, 7)

    demo_exception()