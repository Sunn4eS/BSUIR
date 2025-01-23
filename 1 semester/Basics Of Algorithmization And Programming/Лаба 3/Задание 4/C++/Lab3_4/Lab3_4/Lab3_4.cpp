#include <iostream>
#include <string>
#include <fstream>
using namespace std;
enum ERRORS_LIST {
    CORRECT, RANGE_ERR, NUM_ERR, NOT_TXT, NOT_EXIST, NOT_READABLE, NOT_WRITEABLE, FILE_EMPTY
};
const string ERRORS[] = {
    "", "Значение не попадает в диапазон!", "Проверьте корректность ввода данных!", "Расширение не txt!", "Проверьте корректность ввода пути к файлу!", "Файл закрыт для чтения!", "Файл закрыт для записи!", "Файл пуст!"
};
constexpr int MIN_NUMBER = 0;
constexpr int MAX_NUMBER = 1000000;
void printTask()
{
    cout << "Данная программа переводит числа из 10 с/с в 16 с/с \n";
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
int readDec()
{
    bool fromFile;
    int decNum;
    ERRORS_LIST error;
    string pathToFile;
    decNum = 0;
    error = CORRECT;
    pathToFile = "";
    fromFile = chooseFileInput();
    if (fromFile)
    {
        do
        {
            fileReading(pathToFile);
            ifstream file(pathToFile);
            file >> decNum;
            if (file.fail())
            {
                error = NUM_ERR;
                file.clear();
            }
            if (error == CORRECT)
                error = checkArea(decNum, MIN_NUMBER, MAX_NUMBER);
            file.close();
            if (error != CORRECT)
                printError(error);
        } while (error != CORRECT);
    }
    else
    {
        cout << "Введите число [" << MIN_NUMBER << ":" << MAX_NUMBER << "] ";
        decNum = checkNum(MIN_NUMBER, MAX_NUMBER);
    }
    return decNum;
}
string decToHex(int decNum)
{
    string hexNum;
    int modFromDec;
    const char hexCharList[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    hexNum = "";
    modFromDec = 0;
   
    while (decNum > 0)
    {
        modFromDec = decNum % 16;
        hexNum = hexCharList[modFromDec] + hexNum; 
        decNum /= 16;
    }
    return hexNum;
}
bool chooseFileOutput()
{
    bool choose;
    cout << "\nВы хотите выводить ответ через файл? (Да - " << 1 << " / Нет - " << 2 << ")\n";
    choose = checkInOut();
    return choose;
}
void printResult(string hexNum)
{
    string pathToFile;
    bool printToFile;
    printToFile = chooseFileOutput();
    pathToFile = ' ';
    if (printToFile)
    {
        fileWriting(pathToFile);
        ofstream fileOut(pathToFile, std::ios::app);
        fileOut << "Число в 16с/c: ";
        fileOut << hexNum;
        fileOut.close();
    }
    else
    {
        cout << "Число в 16с/c: ";
        cout << hexNum;
    }
}
int main()
{
    int decNum;
    string hexNum;
    setlocale(LC_ALL, "RU");
    printTask();
    decNum = readDec();
    hexNum = decToHex(decNum);
    printResult(hexNum);
    return 0;
}
