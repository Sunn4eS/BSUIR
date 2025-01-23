#include <iostream>

using std::cin;
using std::cout;
using std::endl;

int main()
{
	setlocale(LC_ALL, "Russian");
	int numOfEl = 0;
	float prod;
	bool isIncorrect;
	const int MAXNUMOFEL = 100;
	const int MINNUMOFEL = 0;
	const int MAXEL = 300;
	const int MINEL = -300;

	cout << "Данная программа вычисляет произведение жлементов массива с N элементов: \n\n";

	isIncorrect = true;
	do
	{
		isIncorrect = false;
		cout << "Введите количство элементов [0; 100]:\n";
		cin >> numOfEl;
		if (cin.get() != '\n')
		{
			isIncorrect = true;
			cout << "Проверьте корректность ввода данных!\n";
			cin.clear();
			while (cin.get() != '\n');
		}
		if (!isIncorrect && ((numOfEl < MINNUMOFEL) || (numOfEl > MAXNUMOFEL)))
		{
			isIncorrect = true;
			cout << "Значение не попадает в диапазон!" << endl;
		}
	} while (isIncorrect);
	
	float *arr = new float[numOfEl];
	for (int i = 0; i < numOfEl; i++) 
	{
		do
		{
			isIncorrect = false;
			cout << "Введите элемент массива [-300; 300]:\n";
			cin >> arr[i];
			if (cin.get() != '\n')
			{
				isIncorrect = true;
				cout << "Проверьте корректность ввода данных!\n";
				cin.clear();
				while (cin.get() != '\n');
			}
			if (!isIncorrect && ((arr[i] < MINEL) || (arr[i] > MAXEL)))
			{
				isIncorrect = true;
				cout << "Значение не попадает в диапазон!" << endl;
			}
		} while (isIncorrect);
	}
	prod = arr[0];
	for (int i = 0; i < numOfEl; i++)
	{
		prod *= arr[i];
	}
	cout << "Произведение = " << prod;
	return 0;
}