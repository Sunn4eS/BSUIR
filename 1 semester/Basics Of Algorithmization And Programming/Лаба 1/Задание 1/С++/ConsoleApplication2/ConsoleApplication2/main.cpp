#include <iostream>

using namespace std;
int main()
{
	setlocale(LC_ALL, "Russian");

	const int MIN_MONTH = 1, MAX_MONTH = 12;
	int numOfMonth;
	bool isIncorrect;

	cout << "Данная программа называет пору года по номеру месяца.\n\n";

	do 
	{
		isIncorrect = false;
		cout << "Введите номер месяца:\n";
		cin >> numOfMonth;
		if (cin.fail())
		{
			isIncorrect = true;
			cout << "Введён неправильный формат данных!\n";
			cin.clear();
			while (cin.get() != '\n');
		}
		if (cin.get() != '\n')
		{
			isIncorrect = true;
			cout << "Ошибка ввода\n";
			cin.clear();
			while (cin.get() != '\n');
			cout << endl;
		}
		if (!isIncorrect && (numOfMonth < MIN_MONTH || numOfMonth > MAX_MONTH))
		{
			isIncorrect = true;
			cout << "Вне диапазона!\n";
		}
	} while (isIncorrect);
	
	if (numOfMonth < 6 && numOfMonth > 2)
	{
	    cout << "Весна";
	}
	if (numOfMonth > 8 && numOfMonth < 12)
	{
		cout << "Осень";
	}
    if (numOfMonth > 5 && numOfMonth < 9) 
	{
		cout << "Лето";
	}
	if ((numOfMonth == 12) || (numOfMonth == 1) || (numOfMonth == 2))
	{
		cout << "Зима";
	}
	return 0;
}