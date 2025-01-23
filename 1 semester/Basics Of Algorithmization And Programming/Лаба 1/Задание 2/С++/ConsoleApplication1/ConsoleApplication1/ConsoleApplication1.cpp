#include <iostream>

using namespace std;
int main() 
{
	setlocale (LC_ALL, "Russian");
	const int MINDAY = 0, SECONDDAY = 2, MAXDAY = 1000;
	const float PERCENTAGE = 0.1;
	int i;
	int numOfDays = 0;
	float distancePerDay;
	float totalDistance;
	bool isIncorrect;

	cout << "Данная программа показывает какой суммарный пробег пробежит спортсмен за N дней: \n\n";
	do
	{
		isIncorrect = false;
		cout << "Введите количество дней:\n";
		cin >> numOfDays;
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
		if (!isIncorrect && ((numOfDays < MINDAY) || (numOfDays > MAXDAY)))
		{
			isIncorrect = true;
			cout << "Вне диапазона!\n";
		}
	} while (isIncorrect);

	distancePerDay = 10;
	totalDistance = 10;
	
	for (i = SECONDDAY; i <= numOfDays; i++)
	{
		distancePerDay = distancePerDay * PERCENTAGE + distancePerDay;
		totalDistance += distancePerDay;
	}
	cout << "Общее расстояние: " << totalDistance;
	return 0;
}