#include <iostream>
#include<cmath>
using namespace std;

int main()
{
	setlocale(LC_ALL, "Russian");
	const float MIN = -10000;
	const float MAX = 10000;
	const int MIN_N = 3;
	const int MAX_N = 10000;
	const int LENGTH_OF_ARR = 2;
	int n = 0; 
	float vectorMultiplication;
	float prevVectorMultiplication = 0;
	float xTest;
	float maxX;
	float minX;
	float maxY;
	float minY;
	float midX;
	float midY;
	float squareOfFigure = 0;
	bool isCorrect = true;
	bool notConvexPolygon = true;
	bool notOnSameLine = true;
	bool isCorrectFigure = true;
	bool sameCoordinate = true;

	cout << "Эта программа находит площадь N-угольника.\n";

	do
	{
		isCorrect = false;
		cout << "Введите количство вершин [" << MIN_N << "; " << MAX_N << "]:\n";
		cin >> n;
		if (cin.get() != '\n')
		{
			isCorrect = true;
			cout << "Проверьте корректность ввода данных!\n";
			cin.clear();
			while (cin.get() != '\n');
		}
		if (!isCorrect && ((n < MIN_N) || (n > MAX_N)))
		{
			isCorrect = true;
			cout << "Значение не попадает в диапазон!" << endl;
		}
	} while (isCorrect);

	float **coordinates = new float* [n];
	
	for (int i = 0; i < n; i++)
	{
		coordinates[i] = new float[LENGTH_OF_ARR];
	}

	for (int i = 0; i < n; i++)
	{
		cout << "Введите " << i + 1 << " пару координат(X, Y)\n";

		do
		{
			isCorrect = false;
			cout << "Введите X [" << MIN << "; " << MAX << "]:\n";
			cin >> coordinates[i][0];
			if (cin.get() != '\n')
			{
				isCorrect = true;
				cout << "Проверьте корректность ввода данных!\n";
				cin.clear();
				while (cin.get() != '\n');
			}
			if (!isCorrect && ((coordinates[i][0] < MIN) || (coordinates[i][0] > MAX)))
			{
				isCorrect = true;
				cout << "Значение не попадает в диапазон!" << endl;
			}
		} while (isCorrect);

		do
		{
			isCorrect = false;
			cout << "Введите Y [" << MIN << "; " << MAX << "]:\n";
			cin >> coordinates[i][1];
			if (cin.get() != '\n')
			{
				isCorrect = true;
				cout << "Проверьте корректность ввода данных!\n";
				cin.clear();
				while (cin.get() != '\n');
			}
			if (!isCorrect && ((coordinates[i][1] < MIN) || (coordinates[i][1] > MAX)))
			{
				isCorrect = true;
				cout << "Значение не попадает в диапазон!" << endl;
			}
		} while (isCorrect);
	}

	int i = 0;
	int j = 0;
	while ((i < n) && (sameCoordinate))
	{
		j = i + 1;
		while ((j < n) && (sameCoordinate))
		{
			if ((coordinates[i][0] == coordinates[j][0]) && (coordinates[i][1] == coordinates[j][1]))
			{
				cout << "Ошибка! Введенные координаты равны!\n";
				sameCoordinate = false;
			}
			j++;
		}
		i++;
	}

	float vec[2][2];
	
	for (int i = 0; i < n; i++)
	{
		for (int j = i + 2; j < n; j++)
		{
			vec[0][0] = coordinates[(i + 1) % n][0] - coordinates[i % n][0];
			vec[0][1] = coordinates[(i + 1) % n][1] - coordinates[i % n][1];
			vec[1][0] = coordinates[(j + 1) % n][0] - coordinates[j % n][0];
			vec[1][1] = coordinates[(j + 1) % n][1] - coordinates[j % n][1];
			vectorMultiplication = vec[0][0] * vec[1][1] - vec[1][0] * vec[0][1];

			if (vectorMultiplication != 0)
			{
				xTest = ((coordinates[i % n][0] * vec[0][1] * vec[1][0]) - 
					     (coordinates[j % n][0] * vec[1][1] * vec[0][0]) + 
					     (vec[1][1] * vec[1][0] * (coordinates[j % n][1]) - 
						  coordinates[i % n][1])) / - vectorMultiplication;
				if ((coordinates[(i + 1) % n][0] - coordinates[i % n][0]) == 0)
				{
					if (coordinates[(i + 1) % n][0] > coordinates[i % n][0])
					{
						maxX = coordinates[(i + 1) % n][0];
						minX = coordinates[i % n][0];
					}
					else
					{
						minX = coordinates[(i + 1) % n][0];
						maxX = coordinates[i % n][0];
					}
					if ((xTest > minX) && (xTest < maxX))
					{
						isCorrectFigure = false;
					}
				}
				else
				{
					if (coordinates[(j + 1) % n][0] > coordinates[j % n][0])
					{
						maxX = coordinates[(j + 1) % n][0];
						minX = coordinates[j % n][0];
					}
					else
					{
						minX = coordinates[(j + 1) % n][0];
						maxX = coordinates[j % n][0];
					}
					if ((xTest > minX) && (xTest < maxX))
					{
						isCorrectFigure = false;
					}
				}
			}
		}
	}

	if ((!isCorrectFigure) && (!sameCoordinate))
	{
		cout << "Ошибка! Стороны многоугольника пересекаются!\n";
	}

	if (isCorrectFigure)
	{
		for (int i = 0; i < n; i++)
		{
			vec[0][0] = coordinates[(i + 1) % n][0] - coordinates[i % n][0];
			vec[0][1] = coordinates[(i + 1) % n][1] - coordinates[i % n][1];
			vec[1][0] = coordinates[(i + 2) % n][0] - coordinates[(i + 1) % n][0];
			vec[1][1] = coordinates[(i + 2) % n][1] - coordinates[(i + 1) % n][1];
			vectorMultiplication = vec[0][0] * vec[1][1] - vec[1][0] * vec[0][1];

			if (vectorMultiplication * prevVectorMultiplication < 0)
			{
				notConvexPolygon = false;
			}
			if (vectorMultiplication == 0)
			{
				notOnSameLine = false;
			}
			prevVectorMultiplication = vectorMultiplication;
		}
	}

	if ((isCorrectFigure) && (!sameCoordinate))
	{
		if (!notOnSameLine)
		{
			cout << "Ошибка! Стороны многоугольника лежат на одной прямой!\n";
		}
		else if (!notConvexPolygon)
		{
			cout << "Многоугольник не является выпуклым";
		}

		maxX = coordinates[0][0];
		minX = coordinates[0][0];
		maxY = coordinates[0][1];
		minY = coordinates[0][1];

		for (int i = 0; i < n; i++)
		{
			if (coordinates[i][0] < minX)
			{
				minX = coordinates[i][0];
			}
			if (coordinates[i][0] > maxX)
			{
				maxX = coordinates[i][0];
			}
			if (coordinates[i][1] < minY)
			{
				minY = coordinates[i][1];
			}
			if (coordinates[i][1] > maxY)
			{
				maxY = coordinates[i][1];
			}
		}

		midX = (minX + maxX) / 2;
		midY = (minY + maxY) / 2;

		for (int i = 0; i < n; i++)
		{
			vec[0][0] = coordinates[(i + 1) % n][0] - midX;
			vec[0][1] = coordinates[(i + 1) % n][1] - midY;
			vec[1][0] = coordinates[(i + 2) % n][0] - midX;
			vec[1][1] = coordinates[(i + 2) % n][1] - midY;
			vectorMultiplication = abs(vec[0][0] * vec[1][1] - vec[1][0] * vec[0][1]);
			squareOfFigure = squareOfFigure + ((0.5) * vectorMultiplication);
		}

		if (notOnSameLine && notConvexPolygon)
		{
			cout << "Площадь многоугольника =  " << squareOfFigure << "\n\n";
		}
	}

	for (int i = 0; i < n; i++)
	{
		delete[] coordinates[i];
	}
	delete[] coordinates;
	
	return 0;
}
