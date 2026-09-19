import math

def task1_count_digits():
    print("\n--- Задание 1.1: Четные и нечетные цифры ---")
    try:
        user_input = input("Введите целое число: ").strip()
        num = abs(int(user_input))
        
        even_count = 0
        odd_count = 0
        
        for digit_char in str(num):
            d = int(digit_char)
            if d % 2 == 0:
                even_count += 1
            else:
                odd_count += 1
                
        print(f"В числе {user_input}: четных цифр = {even_count}, нечетных цифр = {odd_count}")
    except ValueError:
        print("Ошибка: введено не целое число!")
    finally:
        print("Завершение работы Задания 1.")


def task2_register_pairs():
    print("\n--- Задание 1.2: Пары регистра в слове ---")
    try:
        word = input("Введите слово: ").strip()
        if not word:
            raise ValueError("Строка не должна быть пустой!")
            
        lower_pairs = 0
        upper_pairs = 0
        total_letters = sum(1 for ch in word if ch.isalpha())
        
        i = 0
        while i < len(word) - 1:
            if word[i].islower() and word[i+1].islower():
                lower_pairs += 1
                i += 2  
            elif word[i].isupper() and word[i+1].isupper():
                upper_pairs += 1
                i += 2 
            else:
                i += 1
                
        print(f"Слово: {word}")
        print(f"Всего букв: {total_letters}")
        print(f"Пар нижнего регистра: {lower_pairs}")
        print(f"Пар верхнего регистра: {upper_pairs}")
    except Exception as e:
        print(f"Произошла ошибка: {e}")
    finally:
        print("Завершение работы Задания 2.")


def task3_list_sums():
    print("\n--- Задание 1.3: Суммы в списке ---")
    try:
        raw_input = input("Введите элементы списка через пробел (целые числа): ")
        lst = [int(x) for x in raw_input.split()]
        
        neg_sum = sum(x for x in lst if x < 0)
        print(f"Сумма отрицательных элементов: {neg_sum}")
        
        zero_indices = [idx for idx, val in enumerate(lst) if val == 0]
        if len(zero_indices) >= 2:
            first_zero = zero_indices[0]
            second_zero = zero_indices[1]
            sum_between = sum(lst[first_zero + 1 : second_zero])
            print(f"Сумма между первыми двумя нулями (индексы {first_zero} и {second_zero}): {sum_between}")
        else:
            print("Сумма между нулями: 0 (в списке менее двух нулей)")
    except ValueError:
        print("Ошибка: введены некорректные числа!")
    finally:
        print("Завершение работы Задания 3.")


def task4_scrabble():
    print("\n--- Задание 1.4: Scrabble ---")
    scores = {
        1: "AEIOULNSTR",
        2: "DG",
        3: "BCMP",
        4: "FHVWY",
        5: "K",
        6: "JX",
        10: "QZ"
    }
    letter_to_score = {}
    for score, letters in scores.items():
        for char in letters:
            letter_to_score[char] = score
            
    try:
        word = input("Введите слово (на английском языке): ").strip().upper()
        if not word.isalpha():
            raise ValueError("Слово должно состоять только из английских букв!")
            
        total_score = sum(letter_to_score.get(ch, 0) for ch in word)
        print(f"Стоимость слова '{word}' составляет: {total_score} очков")
    except ValueError as err:
        print(f"Ошибка ввода: {err}")
    finally:
        print("Завершение работы Задания 4.")


def task5_car_parts_shop():
    print("\n--- Задание 1.5: Магазин автозапчастей ---")
    products = {
        "Колодки": ["Тормозные колодки передние керамические", 120.0, 15],
        "Фильтр": ["Масляный фильтр тонкой очистки", 35.0, 20],
        "Свечи": ["Комплект свечей зажигания иридиевых (4 шт)", 80.0, 10],
        "Масло": ["Синтетическое моторное масло 5W-40 4л", 150.0, 8]
    }
    
    try:
        while True:
            print("\nМеню магазина автозапчастей:")
            print("1. Просмотр описания")
            print("2. Просмотр цены")
            print("3. Просмотр количества")
            print("4. Вся информация")
            print("5. Покупка")
            print("6. До свидания (Выход)")
            
            choice = input("Выберите пункт меню (1-6): ").strip()
            
            if choice == "1":
                for name, data in products.items():
                    print(f"{name} — {data[0]}")
            elif choice == "2":
                for name, data in products.items():
                    print(f"{name} — {data[1]} руб.")
            elif choice == "3":
                for name, data in products.items():
                    print(f"{name} — {data[2]} шт.")
            elif choice == "4":
                for name, data in products.items():
                    print(f"Товар: {name} | Описание: {data[0]} | Цена: {data[1]} руб. | Остаток: {data[2]} шт.")
            elif choice == "5":
                total_cart_sum = 0.0
                while True:
                    p_name = input("\nВведите название товара (или 'n' для завершения покупок): ").strip()
                    if p_name.lower() == 'n':
                        break
                    if p_name not in products:
                        print("Такого товара нет в наличии!")
                        continue
                    try:
                        qty = int(input(f"Введите количество для '{p_name}': "))
                        if qty <= 0:
                            print("Количество должно быть положительным!")
                            continue
                        if qty > products[p_name][2]:
                            print(f"Недостаточно товара на складе! В наличии всего {products[p_name][2]} шт.")
                            continue
                        
                        cost = qty * products[p_name][1]
                        products[p_name][2] -= qty
                        total_cart_sum += cost
                        print(f"Куплено {qty} шт. на сумму {cost} руб.")
                    except ValueError:
                        print("Ошибка: количество должно быть целым числом!")
                
                print(f"\nОбщая сумма покупок: {total_cart_sum} руб.")
                print("Остатки товаров в магазине:")
                for name, data in products.items():
                    print(f"  {name}: {data[2]} шт.")
            elif choice == "6":
                print("Спасибо за визит! До свидания!")
                break
            else:
                print("Неверный пункт меню, попробуйте снова.")
    except Exception as e:
        print(f"Произошла непредвиденная ошибка: {e}")
    finally:
        print("Работа программы 'Магазин автозапчастей' завершена.")


def task6_tuple_min_max():
    print("\n--- Задание 1.6: Мин/Макс в кортеже ---")
    try:
        raw = input("Введите целые числа для кортежа через пробел: ")
        tup = tuple(int(x) for x in raw.split())
        if not tup:
            raise ValueError("Кортеж не должен быть пустым!")
        min_val = min(tup)
        max_val = max(tup)
        print(f"Кортеж: {tup}")
        print(f"Минимальный элемент: {min_val}")
        print(f"Максимальный элемент: {max_val}")
    except ValueError as ve:
        print(f"Ошибка ввода: {ve}")
    finally:
        print("Завершение работы Задания 6.")


if __name__ == "__main__":
    task1_count_digits()
    task2_register_pairs()
    task3_list_sums()
    task4_scrabble()
    task5_car_parts_shop()
    task6_tuple_min_max()