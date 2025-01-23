#include <iostream>
using namespace std;

void outputTask()
{
	cout << "Данная программа выясняет можно ли представить N в виде произведения трех последовательных натуральных чисел:\n\n";
}

bool checkRange(int n)
{
	const int MIN = 1;
	const int MAX = 100000;

	return ((n < MIN) || (n > MAX));

}

int inputNum()
{
	bool isCorrect = true;
	int n;
	bool checkRangeN;
	do
	{
		isCorrect = false;
		cout << "Введите N: ";
		cin >> n;
		if (cin.get() != '\n')
		{
			isCorrect = true;
			cout << "Проверьте корректность ввода данных!\n";
			cin.clear();
			while (cin.get() != '\n');
		}
		checkRangeN = checkRange(n);

		if (checkRangeN && !isCorrect)
		{
			cout << "Значение не попадает в диапазон!\n";
			isCorrect = true;
		}

	} while (isCorrect);
	return n;
}

bool checkMultiplication(int n)
{
	int mult = 0;
	int i = 1;
	while (mult < n)
	{
		mult = i * (i + 1) * (i + 2);
		i++;
	}
		return n == mult;	
}

int main()
{
	bool checkMult;
	setlocale(LC_ALL, "RU");

	outputTask();
	checkMult = checkMultiplication(inputNum());
	if (checkMult)
	{
		cout << "Можно представить";
	}
	else
	{
		cout << "Нельзя представить";
	}
	return 0;
}

