#include <iostream>
#include <math.h>

using std::cin;
using std::cout;
using std::endl;


int main()
{
	setlocale(LC_ALL, "Russian");
	const int MIN_EPS = 0;
	const int MAX_EPS = 1;
	const int MIN_X = -1;
	const int MAX_X = 1;
	float eps;
	float x;
	bool isCorrect;

	cout << "Данная программа считает значение функции LN(1+X) для введённого значения X, а также подсчитывает количество чисел из ряда Маклорена больших EPS: \n\n";
	
	isCorrect = true;
	do
	{
		isCorrect = false;
		cout << "Введите EPS (0; 1): ";
		cin >> eps;
		if (cin.get() != '\n')
		{
			isCorrect = true;
			cout << "Проверьте корректность ввода данных!\n";
			cin.clear();
			while (cin.get() != '\n');
		}
		if (!isCorrect && ((eps < MIN_EPS) || eps > MAX_EPS))
		{
			isCorrect = true;
			cout << "Значение не попадает в диапазон!" << endl;
		}
	} while (isCorrect);

	isCorrect = true;
	do
	{
		isCorrect = false;
		cout << "Введите X [-1; 1]: ";
		cin >> x;
		if (cin.get() != '\n')
		{
			isCorrect = true;
			cout << "Проверьте корректность ввода данных!\n";
			cin.clear();
			while (cin.get() != '\n');
		}
		if (!isCorrect && ((x < MIN_X) || (x > MAX_X)))
		{
			isCorrect = true;
			cout << "Значение не попадает в диапазон!" << endl;
		}
	} while (isCorrect);
	
	int i = 1;
	int n = 0;
	float multiple = x;
	float sum = x;

	while ((abs(multiple) / i) > eps)
	{
		i++;
		multiple = -multiple * x;
		sum = sum + multiple / i;
		n++;
	}
	cout << "Общая сумма = " << sum << '\n' << "Количество членов ряда = " << n;
	return 0;
}