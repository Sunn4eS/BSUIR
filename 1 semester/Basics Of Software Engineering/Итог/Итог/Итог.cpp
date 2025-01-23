#include <iostream>
#include <map>
#include <ctime>
#include <Windows.h>
using namespace std;
const int NUM_OF_STEP = 10;
const int MIN_AMOUNT_PLAYER = 2;
const int MAX_AMOUNT_PLAYER = 10;

int InputAmountPlayer()
{

    int amountPlayer;
    bool isCorrect;
    do
    {
        isCorrect = true;
        cout << "Введите количество игроков от " << MIN_AMOUNT_PLAYER << " до " << MAX_AMOUNT_PLAYER << ": ";
        cin >> amountPlayer;
        if (cin.fail() && cin.get() != '\n')
        {
            isCorrect = false;
            cout << "Неправильное количество игроков:\n";
            cin.clear();
            while (cin.get() != '\n');
        }
        if (isCorrect && (amountPlayer < MIN_AMOUNT_PLAYER || amountPlayer > MAX_AMOUNT_PLAYER))
        {
            isCorrect = false;
            cout << "Неправильное количество игроков:\n";
        }
    } while (!isCorrect);

    return amountPlayer;
}

int** makingResultSet(int NumberOfPlayers)
{
    int** resultMassive = new int* [NumberOfPlayers];
    for (int i = 0; i < NumberOfPlayers; i++)
        *(resultMassive + i) = new int[10];

    return resultMassive;
}

void saveTheResult(int**& resultMassive, int currentPlayer, int currentRound, int RoundResult) {
    resultMassive[currentPlayer][currentRound] = RoundResult;
}



std::map<int, int> sortPoints(int* arr, const int SIZE)
{
    std::map<int, int> dict;
    for (size_t i = 0; i < SIZE; i++)
    {
        if (dict.find(arr[i]) == dict.end())
            dict.insert(std::pair<int, int>(arr[i], 0));
        dict[arr[i]]++;
    }
    return dict;
}

int findBonus(std::map<int, int> dict)
{
    int bonus = 0;
    for (auto& pair : dict)
    {
        if (pair.second == 5)
            bonus = 100;
    }
    return bonus;
}

int* genRandom() {
    const int NUM = 5;
    int* array = new int[NUM];
    //srand(time(0));
    srand(0);
    for (int i = 0; i < NUM; i++)
        array[i] = rand() % 6;
    return array;
}

void outArr(int* array) {
    std::cout << " Ваши случайные числа: ";
    for (int i = 0; i < sizeof(array); i++) {
        std::cout << array[i] << " ";
    }
}

int countPoints(std::map<int, int> dict)
{
    int points = 0;
    int firstMax = 0;
    int secondMax = 0;
    for (auto& pair : dict)
    {
        if (pair.second > firstMax)
        {
            secondMax = firstMax;
            firstMax = pair.second;
        }
        else if (pair.second > secondMax)
        {
            secondMax = pair.second;
        }
        else
        {
        }
    }
    switch (firstMax)
    {
    case 5:
    {
        points = 7;
    }
    break;
    case 4:
    {
        points = 6;
    }
    break;
    case 3:
    {
        if (secondMax > 1)
        {
            points = 5;
        }
        else
        {
            points = 4;
        }
    }
    break;
    case 2:
    {
        if (secondMax > 1)
        {
            points = 5;
        }
        else
        {
            points = 4;
        }
    }
    case 1:
    {
        points = 1;
    }
    break;
    default:
        break;
    }
    return points;
}

int SumOfRound(std::map<int, int> dict, int points)
{
    int sum = 0;
    sum = points * 50;
    for (auto& pair : dict)
    {
        sum += 10 * (pair.second * pair.first) / pair.second;
    }
    return sum;
}


void outputting(int gamers, int**& MassiveWithRoundResults) {
    int sum, bonus;
    bool* boolarr = new bool[gamers];
    for (int i = 0; i < gamers; i++)
    {
        boolarr[i] = false;
    }
    for (int i = 0; i < 10; i++) {
        std::cout << "\n" << i + 1 << "Раунд\n";
        for (int j = 0; j < gamers; j++) {
            std::cout << "\n" << j + 1 << "игрок. Нажмите enter чтобы сгенерировать случайные числа\n ";
            std::cin.get();
            int* array = genRandom();
            outArr(array);
            std::map<int, int> dict = sortPoints(array, 5);
            int points = countPoints(dict);
            sum = SumOfRound(dict, points);


            std::cout << "\n Сумма ваших очков в данном раунде: " << sum << "\n";
            if (!boolarr[j] && (bonus = findBonus(dict)) == 100) {
                boolarr[j] = true;
                sum += bonus;
                std::cout << "!!!Вы получили бонус в 100 очков!!!";
                //add to mainsum
            }

            saveTheResult(MassiveWithRoundResults, j, i, sum);
        }
    }
}




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
        cout << "Итог " << winnerArr[1][i] << "\n";

    }

    cout << "\nПобеидтель " << winnerArr[0][0] + 1;
}

int** processedArray(int** inputArray, int numRows) {
    int maxSum = 0;
    int maxSumRow = 0;
    int** outputArray = new int* [2];
    outputArray[1] = new int[numRows];
    for (int i = 0; i < numRows; i++) {
        int sum = 0;
        for (int j = 0; j < 10; j++) {
            sum += inputArray[i][j];
            outputArray[1][i] = sum;
        }
        if (sum > maxSum) {
            maxSum = sum;
            maxSumRow = i;
        }
    }
    outputArray[0] = new int[1];
    outputArray[0][0] = maxSumRow;

    return outputArray;
}

int main() {
    SetConsoleCP(1251);
    SetConsoleOutputCP(1251);
    int numberOfPlayers = InputAmountPlayer();
    int** MassiveWithRoundResults = makingResultSet(numberOfPlayers);
    outputting(numberOfPlayers, MassiveWithRoundResults);
    int** MassiveWithResultSum = processedArray(MassiveWithRoundResults, numberOfPlayers);
    printOutput(MassiveWithRoundResults, numberOfPlayers, MassiveWithResultSum);
    return 0;
}