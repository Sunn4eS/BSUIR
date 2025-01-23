#include <iostream>
#include <map>
#include <ctime>
#include <iomanip> // for setw()
#include <Windows.h>

using namespace std;

const int NUM_OF_STEP = 10;
const int MIN_AMOUNT_PLAYER = 2;
const int MAX_AMOUNT_PLAYER = 10;
const int NUMBERS_IN_ROUNT = 5;
//коэффициент, на который умножаем среднее арифместическое повторяющихся цифр
const int FACTOR_OF_AVG = 10;
//коэффициент, на который умножаем количество поинтов полученных в данном раунде
const int FACTOR_OF_POINTS = 50;

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
    while (std::cin.get() != '\n');
    return amountPlayer;
}

int** makingResultSet(int NumberOfPlayers)
{
    int** resultMassive = new int* [NumberOfPlayers];
    for (int i = 0; i < NumberOfPlayers; i++)
        *(resultMassive + i) = new int[10];
    return resultMassive;
}

int** processedArray(int** inputArray, int numRows) {
    int maxSum = 0;
    //int maxSumRow = 0;
    int** outputArray = new int* [2];
    outputArray[1] = new int[numRows];
    for (int i = 0; i < numRows; i++) {
        int sum = 0;
        for (int j = 0; j < 10; j++) {
            sum += inputArray[i][j];
        }
        outputArray[1][i] = sum;
        if (sum > maxSum) {
            maxSum = sum;
            //maxSumRow = i;
        }
    }
    outputArray[0] = new int[numRows + 1]; // was int[0]
    /**/
    int numWin = 0;
    for (int i = 0; i < numRows; i++) {
        if (maxSum == outputArray[1][i])
        {
            numWin++;
            outputArray[0][i + 1] = 1;
        }
        else outputArray[0][i + 1] = 0;
    }
    /**/
    outputArray[0][0] = numWin;
    return outputArray;
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
    int* array = new int[NUMBERS_IN_ROUNT];
    //unsigned int seed = static_cast<unsigned int>(time(nullptr));
    //srand(seed);
    for (int i = 0; i < NUMBERS_IN_ROUNT; i++)
    {
        unsigned int seed = static_cast<unsigned int>(time(nullptr));
        srand(seed);
        for (int j = 0; j < NUMBERS_IN_ROUNT; j++)
            array[j] = 1 + rand() % 6;
    }
    return array;
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
            points = 3;
        }
        else
        {
            points = 2;
        }
    }
    break;
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
    sum = points * FACTOR_OF_POINTS;
    int tempSum = 0;
    int counter = 0;
    for (auto& pair : dict)
    {
        if (pair.second > 1)
        {
            tempSum += pair.second * pair.first;
            counter += pair.second;
        }
    }
    if (counter > 0)
        sum += tempSum * 10 / counter;
    return sum;
}


void outArr(int* array) {
    std::cout << "Ваши случайные числа: ";
    for (int i = 0; i < NUMBERS_IN_ROUNT; i++) {
        std::cout << array[i] << " ";
    }
}

void saveTheResult(int**& resultMassive, int currentPlayer, int currentRound, int RoundResult) {
    resultMassive[currentPlayer][currentRound] = RoundResult;
}

int* getFive()
{
    int* arr = new int[NUMBERS_IN_ROUNT];;
    for (int i = 0; i < NUMBERS_IN_ROUNT; i++) {
        arr[i] = 5;
    }
    return arr;
}


void outputting(int gamers, int**& MassiveWithRoundResults) {
    int sum, bonus;
    bool* boolarr = new bool[gamers];
    for (int i = 0; i < gamers; i++)
    {
        boolarr[i] = false;
    }
    for (int i = 0; i < 10; i++) {
        std::cout << "\n-----------------------| " << i + 1 << " Раунд |-----------------------\n\n";
        for (int j = 0; j < gamers; j++) {
            std::cout << j + 1 << " игрок. Нажмите enter чтобы сгенерировать случайные числа." << std::endl;
            //проверка на ввод
            while (std::cin.get() != '\n')
            {
                std::cout << "Неправильный ввод!!!\n";
            };
            int* array = ((j == 1) ? getFive() : genRandom());
            outArr(array);
            std::map<int, int> dict = sortPoints(array, 5);
                int points = countPoints(dict);
            sum = SumOfRound(dict, points);
            std::cout << "\n   Очки за раунд: " << sum << "\n\n";
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
    cout << "\nТаблица баллов:\n\n";
    cout << "Баллы за раунд |"; // 16 symbols
    for (int i = 0; i < numOfPlayers; i++)
    {
        cout << "Игрок " << std::setw(2) << std::right << i + 1 << "|"; // 9 symbols
    }
    //for ---
    int SizeSymbols = 16 + 9 * numOfPlayers;
    string nextRoundSymbol = "\0";
    for (int i = 0; i < SizeSymbols; i++)
    {
        nextRoundSymbol += "-";
    }
    cout << endl << nextRoundSymbol << endl;
    for (int i = 0; i < 10; i++)
    {
        cout << "Раунд " << std::setw(9) << std::left << i + 1 << "|";
        for (int j = 0; j < numOfPlayers; j++)
        {
            cout << std::setw(8) << std::right << resultMassive[j][i] << "|";
        }
        cout << endl << nextRoundSymbol << endl;
    }
    cout << std::setw(15) << std::left << "Итог" << "|";
    for (int i = 0; i < numOfPlayers; i++)
    {
        cout << std::setw(8) << std::right << winnerArr[1][i] << "|";

    }
    cout << endl;
    if (winnerArr[0][0] == 1) {
        int winNum = 1;
        for (int i = 1; winnerArr[0][i] == 0; i++) winNum++;
        cout << "\nПобедитель игрок " << winNum << "\n";
        cout << "Приз, АААААААВТОООМОБИИЛЬ\n";
        cout << "      ____      \n"
            << " ____/__|_\\____\n"
            << "|  __      __  |\n"
            << "|_/()\\____/()\\_|\n";
    }
    else {
        cout << "\nСегодня у нас несколько победителей!!!:\n";
        int winNum = 1;
        while (winnerArr[0][0] > 0) {
            for (int i = winNum; winnerArr[0][i] == 0; i++) winNum++;
            cout << "\nПобедитель игрок " << winNum << "\n";
            cout << "Приз, АААААААВТОООМОБИИЛЬ\n";
            cout << "      ____      \n"
                << " ____/__|_\\____\n"
                << "|  __      __  |\n"
                << "|_/()\\____/()\\_|\n";
            winnerArr[0][0]--;
            winNum++;
        }
    }
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