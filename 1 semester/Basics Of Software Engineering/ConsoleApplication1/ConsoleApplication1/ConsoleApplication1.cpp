#include <iostream>
using namespace std;

void printOutput(int** resultMassive, int numOfPlayers, int** winnerArr)
{
	int count = 10;
	
	cout << "Таблица игроков:\n";

	for (int i = 0; i < numOfPlayers; i++)
	{
		cout << "Игрок " << i + 1 << " ";

		for (int j = 0; j < 10; j++)
		{
			cout << resultMassive[i][j] << " ";
		}
		cout << "Итог " << winnerArr[1][i] << "\n\n";

	}
	cout << "Побеидтель " << winnerArr[0][0];
}

int main()
{
	int numberOfPlayers = 2;
	int** resultMassive = new int* [numberOfPlayers];
	for (int i = 0; i < numberOfPlayers; i++)
	{
		int* resultMassive = new int[10];
	}
	for (int i = 0; i < numberOfPlayers; i++)
	{
		for (int j = 0; j < 10; j++)
		{
			cin >> resultMassive[i][j];
		}
	}
	int** winner = new int* [2];
	printOutput(resultMassive, numberOfPlayers, winner);
	setlocale(LC_ALL, "RU");

	return 0;
}