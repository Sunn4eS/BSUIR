#include <iostream>
#include <string>
#include <fstream>
#include <set>
using namespace std;
enum ERRORS_LIST {
    CORRECT, RANGE_ERR, NUM_ERR, NOT_TXT, NOT_EXIST, NOT_READABLE, NOT_WRITEABLE, FILE_EMPTY
};
const string ERRORS[] = {
    "", "Значение не попадает в диапазон!", "Проверьте корректность ввода данных!", "Расширение не txt!", "Проверьте корректность ввода пути к файлу!", "Файл закрыт для чтения!", "Файл закрыт для записи!", "Файл пуст!"
};
constexpr int MIN_NUMBER = 2;
constexpr int MAX_NUMBER = 10000;
void printTask()
{
    cout << "Данная программа ищет все простые числа до числа P:\n\n";
}
ERRORS_LIST checkArea(int num, const int MIN, const int MAX)
{
    ERRORS_LIST error;
    error = CORRECT;
    if (num < MIN || num > MAX)
        error = RANGE_ERR;
    return error;
}
void printError(ERRORS_LIST error)
{
    cout << ERRORS[error] << "\nПовторите попытку: ";
}
int checkNum(int MIN, int MAX)
{
    ERRORS_LIST error;
    int num;
    num = 0;
    do
    {
        error = CORRECT;
        cin >> num;
        if (cin.fail())
        {
            error = NUM_ERR;
            cin.clear();
            while (cin.get() != '\n');
        }
        if (error == CORRECT && cin.get() != '\n')
        {
            error = NUM_ERR;
            cout << "Некорректный выбор!\n";
            while (cin.get() != '\n');
        }
        if (error == CORRECT)
            error = checkArea(num, MIN, MAX);
        if (error != CORRECT)
            printError(error);
    } while (error != CORRECT);
    return num;
}
bool checkInOut()
{
    const int FILE_CHOICE = 1;
    const int CONSOLE_CHOICE = 2;
    int num;
    bool choose;
    choose = false;
    num = checkNum(FILE_CHOICE, CONSOLE_CHOICE);
    if (num == 1)
        choose = true;
    return choose;
}
bool chooseFileInput()
{
    bool choose;
    choose = false;
    cout << "Вы хотите вводить число через файл? (Да - " << 1 << " / Нет - " << 2 << ")\n";
    choose = checkInOut();
    return choose;
}
void fileReading(string& pathToFile)
{
    ERRORS_LIST error;
    do
    {
        error = CORRECT;
        cout << "Введите путь к файлу с расширением .txt: ";
        getline(cin, pathToFile);
        if (pathToFile.substr(pathToFile.length() - 4, 4) != ".txt")
            error = NOT_TXT;
        else if (!ifstream(pathToFile))
            error = NOT_EXIST;
        else
        {
            ifstream file(pathToFile);
            if (!file.is_open())
                error = NOT_READABLE;
            else if (file.peek() == ifstream::traits_type::eof())
            {
                error = FILE_EMPTY;
                file.close();
            }
            file.close();
        }
        if (error != CORRECT)
            printError(error);
    } while (error != CORRECT);

}
void fileWriting(string& pathToFile)
{
    ERRORS_LIST error;
    do
    {
        error = CORRECT;
        cout << "Введите путь к файлу с расширением .txt: ";
        getline(cin, pathToFile);
        if (pathToFile.substr(pathToFile.length() - 4, 4) != ".txt")
            error = NOT_TXT;
        else if (!ifstream(pathToFile))
            error = NOT_EXIST;
        else
        {
            ifstream file(pathToFile);
            if (!file.is_open())
                error = NOT_WRITEABLE;
        }
        if (error != CORRECT)
            printError(error);
    } while (error != CORRECT);
}
set<int> readSet() 
{
    set<int> numbers;
    bool fromFile;
    int num;
    ERRORS_LIST error;
    string pathToFile;
    num = 0;
    error = CORRECT;
    pathToFile= "";
    fromFile = chooseFileInput();
    if (!fromFile)
    {
        cout << "Введите число до которого вы хотетие найти простые числа [" << MIN_NUMBER << ":" << MAX_NUMBER << "] ";
        num = checkNum(MIN_NUMBER, MAX_NUMBER);
        for (int i = 2; i <= num; ++i)
            numbers.insert(i);
    }
    else
    {
        do
        {
            fileReading(pathToFile);
            ifstream file(pathToFile);
            file >> num;
            if (file.fail())
            {
                error = NUM_ERR;
                file.clear();
            }
            if (error == CORRECT)
                if (file.peek() != '\n') 
                    error = NUM_ERR;
            if (error == CORRECT)
                error = checkArea(num, MIN_NUMBER, MAX_NUMBER);
            file.close();
            if (error != CORRECT)
                printError(error);
        } while (error != CORRECT);
        for (int i = 2; i <= num; ++i)
            numbers.insert(i);
    }
    return numbers;
}
set<int> sortSet(const set<int> primeNumbers)
{
    set<int> sortedSet;
    int prime;
    int length;
    prime= MIN_NUMBER;
    sortedSet = primeNumbers;
    length = sortedSet.size() + 1;
    while (prime * prime <= length) {
        if (sortedSet.count(prime) > 0)
            for (int i = 2 * prime; i <= length; i += prime)
                sortedSet.erase(i);
        ++prime;
    }
    return sortedSet;
}
bool chooseFileOutput()
{   
    bool choose;
    cout << "\nВы хотите выводить ответ через файл? (Да - " << 1 << " / Нет - " << 2 << ")\n";
    choose = checkInOut();
    return choose;
}
void printResult(set<int> primeNumbers)
{
    int num;
    string pathToFile;
    bool printToFile;
    num = 0;
    printToFile = chooseFileOutput();
    pathToFile = ' ';
    if (printToFile)
    {
        fileWriting(pathToFile);
        ofstream fileOut(pathToFile, std::ios::app);
        fileOut << "Множество простых чисел:";
    }
    else
        cout << "Множество простых чисел:\n";
    ofstream fileOut(pathToFile, std::ios::app);
    for (int num : primeNumbers)
    {
        if (printToFile)
            fileOut << num << " ";
        else
            cout << num << " ";
    }
    if (printToFile)
        fileOut.close();
}
int main()
{
    set<int> primeNumbers;
    setlocale(LC_ALL, "RU");
    printTask();
    primeNumbers = readSet();
    primeNumbers = sortSet(primeNumbers);
    printResult(primeNumbers);
    return 0;
}
