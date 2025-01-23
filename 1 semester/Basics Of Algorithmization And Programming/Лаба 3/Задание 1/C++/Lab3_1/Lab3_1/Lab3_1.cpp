#include <iostream>
#include <string.h>
#include <fstream>
#include <string>
using namespace std;
const int MIN_LENGTH = 1;
const int MAX_LENGTH = 1000;

void printTask()
{
    cout << "Данная программа находит место последнего вхождения первой строки во вторую:\n\n";
}
bool chooseFileInput()
{
    int isFileInput;
    bool isCorrect, choose;
    isFileInput = 0;
    choose = false;
    do {
        isCorrect = true;
        cout << "Вы хотите вводить строки через файл? (Да - " << 1 << " / Нет - " << 0 << ")\n";
        cin >> isFileInput;
        if (cin.fail())
        {
            isCorrect = false;
            cout << "Некорректный выбор!\n";
            cin.clear();
            while (cin.get() != '\n');
        }
        if (isCorrect && cin.get() != '\n')
        {
            isCorrect = false;
            cout << "Некорректный выбор!\n";
            while (cin.get() != '\n');
        }
        if (isCorrect)
        {
            if (isFileInput == 1)
                choose = true;
            else if (isFileInput == 0)
                choose = false;
            else
            {
                isCorrect = false;
                cout << "Некорректный выбор!\n";
            }
        }
    } while (!isCorrect);
    return choose;
}
bool checkLength(string str)
{
    bool isCorrect;
    isCorrect = true;
    if ((str.length() < MIN_LENGTH) || (str.length() > MAX_LENGTH))
    {
        cout << "Значение не попадает в диапазон!\n";
        isCorrect = false;
    }
    return isCorrect;
}
string readPathFile()
{
    string pathToFile;
    bool isCorrect;
    pathToFile = "";
    do
    {
        isCorrect = true;
        cout << "Введите путь к файлу с расширением .txt: ";
        cin >> pathToFile;
        if (pathToFile.size() < 5 || pathToFile[pathToFile.length() - 4] != '.' || pathToFile[pathToFile.length() - 3] != 't' || pathToFile[pathToFile.length() - 2] != 'x' || pathToFile[pathToFile.length() - 1] != 't')
        {
            cout << "Расширение файла не .txt!\n";
            isCorrect = false;
        }
    } while (!isCorrect);
    return pathToFile;
}
bool isExists(string pathToFile)
{
    bool isCorrect;
    isCorrect = false;
    ifstream file(pathToFile);
    if (file.good())
        isCorrect = true;
    file.close();
    return isCorrect;
}
bool isAbleToReading(string pathToFile)
{
    bool isCorrect;
    isCorrect = false;
    ifstream file(pathToFile);
    if (file.is_open())
        isCorrect = true;
    file.close();
    return isCorrect;
}
bool isAbleToWriting(string pathToFile)
{
    bool isCorrect;
    isCorrect = false;
    ofstream file(pathToFile, ios::app);
    if (file.is_open())
        isCorrect = true;
    file.close();
    return isCorrect;
}
bool isEmpty(string pathToFile)
{
    bool isCorrect;
    isCorrect = false;
    ifstream file(pathToFile);
    if (file.peek() == ifstream::traits_type::eof())
        isCorrect = true;
    file.close();
    return isCorrect;
}
bool isRightFileString(string pathToFile)
{
    bool isCorrect;
    isCorrect = false;
    ifstream file(pathToFile);
    file.get() != '\n';
    if (file.peek() == ifstream::traits_type::eof())
        isCorrect = true;
    file.get() != '\n';
    if (file.peek() != ifstream::traits_type::eof())
        isCorrect = true;
    file.close();
    return isCorrect;
}
void getFileNormalReading(string& pathToFile)
{
    bool isCorrect;
    do
    {
        isCorrect = true;
        pathToFile = readPathFile();
        if (!isExists(pathToFile))
        {
            isCorrect = false;
            cout << "Проверьте корректность ввода пути к файлу!\n";
        }
        if (isCorrect && !isAbleToReading(pathToFile))
        {
            isCorrect = false;
            cout << "Файл закрыт для чтения!\n";
        }
        if (isCorrect && isEmpty(pathToFile))
        {
            isCorrect = false;
            cout << "Файл пуст!\n";
        }
        if (isCorrect && !isRightFileString(pathToFile))
        {
            isCorrect = false;
            cout << "Количество строк не совпадает с условием!\n";
        }
    } while (!isCorrect);
}
void getFileNormalWriting(string& pathToFile)
{
    bool isCorrect;
    do
    {
        isCorrect = true;
        pathToFile = readPathFile();
        if (!isExists(pathToFile))
        {
            isCorrect = false;
            cout << "Проверьте корректность ввода пути к файлу!\n";
        }
        if (isCorrect && !isAbleToWriting(pathToFile))
        {
            isCorrect = false;
            cout << "Файл закрыт для записи!\n";
        }
    } while (!isCorrect);
}
string readFileString(ifstream& file)
{
    string str;
    getline(file, str);
    return str;
}
string readConsoleString(int num)
{
    string str;
    bool isCorrect;
    str = ' ';
    do
    {
        isCorrect = true;
        cout << "Введите строку номер " << num << " [" << MIN_LENGTH << ":" << MAX_LENGTH << "]: ";
        cin >> str;
        isCorrect = checkLength(str);
    } while (!isCorrect);
    return str;
}
void readString(string& str1, string& str2)
{
    string pathToFile;
    bool isCorrect;
    pathToFile = "";
    do
    {
        isCorrect = true;
        if (chooseFileInput())
        {
            getFileNormalReading(pathToFile);
            ifstream file(pathToFile);
            str1 = readFileString(file);
            str2 = readFileString(file);
            file.close();
        }
        else
        {
            str1 = readConsoleString(1);
            str2 = readConsoleString(2);
        }
        if (str1.length() > str2.length())
        {
            isCorrect = false;
            cout << "Длинна не соответсвует условию!\n";
        }
    } while (!isCorrect);
}
int findLastOccurrence(string& str1, string& str2)
{
    int lengthOfStr1;
    int lengthOfStr2;
    int indOfStr1;
    int indOfStr2;
    int place;
    bool endOfStr1;
    lengthOfStr1 = str1.length();
    lengthOfStr2 = str2.length();
    place = 0;
    indOfStr1 = 0;
    indOfStr2 = 0;
    endOfStr1 = false;

    while ((lengthOfStr2 > 0) && (place == 0))
    {
        if (str1[lengthOfStr1 - 1] == str2[lengthOfStr2 - 1])
        {
            indOfStr1 = lengthOfStr1 - 1;
            indOfStr2 = lengthOfStr2 - 1;
            endOfStr1 = false;
            while ((indOfStr1 > 0) && (indOfStr2 > 0) && (str1[indOfStr1] == str2[indOfStr2]))
            {
                indOfStr1--;
                indOfStr2--;
            }
            if (indOfStr1 != 0)
                endOfStr1 = true;
            if (!endOfStr1)
                place = indOfStr2 + 1;
        }
        lengthOfStr2--;
    }
    return place;
}
bool chooseFileOutput()
{
    int isFileOutput;
    bool isCorrect, choose;
    isFileOutput = 0;
    choose = false;
    cout << "\n";
    do {
        isCorrect = true;
        cout << "Вы хотите выводить результат через файл? (Да - " << 1 << " / Нет - " << 0 << ")\n";
        cin >> isFileOutput;
        if (cin.fail())
        {
            isCorrect = false;
            cout << "Некорректный выбор!\n";
            cin.clear();
            while (cin.get() != '\n');
        }
        if (isCorrect && cin.get() != '\n')
        {
            isCorrect = false;
            cout << "Некорректный выбор!\n";
            while (cin.get() != '\n');
        }
        if (isCorrect)
        {
            if (isFileOutput == 1)
                choose = true;
            else if (isFileOutput == 0)
                choose = false;
            else
            {
                isCorrect = false;
                cout << "Некорректный выбор!\n";
            }
        }
    } while (!isCorrect);
    return choose;
}
void printConsoleResult(int place)
{
    cout << "Номер позиции последнего вхождения строки st1 в строку st2 = " << place;
}
void printFileResult(string pathToFile, int place)
{
    fstream file(pathToFile, ios::app);
    file << "\n";
    file << "Номер позиции последнего вхождения строки st1 в строку st2 = " << place;
    file.close();
}
void printResult(int place)
{
    string pathToFile;
    pathToFile = "";
    if (chooseFileOutput())
    {
        getFileNormalWriting(pathToFile);
        printFileResult(pathToFile, place);
    }
    else
        printConsoleResult(place);
}
int main()
{
    string str1;
    string str2;
    int place;
    str1 = " ";
    str2 = " ";
    setlocale(LC_ALL, "RU");
    printTask();
    readString(str1, str2);
    place = findLastOccurrence(str1, str2);
    printResult(place);
    return 0;
}
