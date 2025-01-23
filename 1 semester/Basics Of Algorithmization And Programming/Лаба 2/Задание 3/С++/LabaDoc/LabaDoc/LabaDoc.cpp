#include <iostream>
#include <string.h>
#include <fstream>
using std::cin;
using std::cout;
using std::string;
using std::fstream;
using std::ifstream;
using std::ofstream;
using std::ios;
using std::numeric_limits;
using std::streamsize;
const int
MIN_MARK = 0,
MAX_MARK = 10,
FIRST_STUDENT = 1,
LAST_STUDENT = 30,
LAST_COLUMN = 10,
FIRST_COLUMN = 1;

void printTask()
{
    cout << "Данная программа выводит номера отличников за семестр.\n\n";
}
void createMatrix(int**& matrix)
{
    matrix = new int* [LAST_STUDENT];
    for (int i = 0; i < LAST_STUDENT; i++)
        matrix[i] = new int[LAST_COLUMN];
}
void createGoodMen(int*& goodMen)
{
    goodMen = new int[LAST_STUDENT];
}

bool chooseFileInput()
{
    int isFileInput;
    bool isCorrect;
    bool choose;
    isFileInput = 0;
    choose = false;
    do {
        isCorrect = true;
        cout << "Вы хотите вводить матрицу через файл? (Да - " << 1 << " / Нет - " << 0 << ")\n";
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
            while (std::cin.get() != '\n');
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

bool checkArea(int num, const int MIN, const int MAX)
{
    bool isCorrect;
    isCorrect = true;
    if (num < MIN || num > MAX)
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
    int len;
    pathToFile = "";
    isCorrect = false;
    len = 0;
    do
    {
        cout << "'Введите путь к файлу с расширением .txt с матрицей, у которой числа должны соответствовать оценкам[" << MIN_MARK << ":" << MAX_MARK << "]: ";
        cin >> pathToFile;
        len = pathToFile.length();
        if (len > 4 && pathToFile.substr(len - 4, 4) == ".txt")
            isCorrect = true;
        else
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

bool isRightFileNums(string pathToFile)
{
    int mark;
    bool isCorrect;
    mark = 0;
    isCorrect = true;
    ifstream file(pathToFile);

    while (isCorrect && !file.eof())
    {
        while (isCorrect && file.peek() != '\n' && !file.eof())
        {
            file >> mark;
            if (file.fail())
            {
                isCorrect = false;
                file.clear();
            }
            if (isCorrect)
                isCorrect = checkArea(mark, MIN_MARK, MAX_MARK);
        }
        file.ignore(numeric_limits<streamsize>::max(), '\n');
    }
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
        if (isCorrect && !isAbleToWriting(pathToFile))
        {
            isCorrect = false;
            cout << "Файл закрыт для записи!\n";
        }
        if (isCorrect && isEmpty(pathToFile))
        {
            isCorrect = false;
            cout << "Файл пуст!\n";
        }
        if (isCorrect && !isRightFileNums(pathToFile))
        {
            isCorrect = false;
            cout << "Некорректный тип данных внутри файла!\n";
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

int** readFileMatrix(string pathToFile)
{
    int** matrix;
    createMatrix(matrix);
    ifstream file(pathToFile);
    file.ignore(numeric_limits<streamsize>::max(), '\n');
    for (int row = 0; row < LAST_STUDENT; row++)
    {
        for (int col = 0; col < LAST_COLUMN; col++)
            file >> matrix[row][col];
        file.ignore(numeric_limits<streamsize>::max(), '\n');
    }
    file.close();
    return matrix;
}

int** readConsoleMatrix()
{
    int** matrix;
    bool isCorrect;
    createMatrix(matrix);
    for (int row = 1; row < LAST_STUDENT; row++)
        for (int col = 0; col < LAST_COLUMN; col++)
            do
            {
                isCorrect = true;
                cout << " Введите оценку " << row << " человека за " << col << " день: ";
                cin >> matrix[row][col];
                if (cin.fail())
                {
                    isCorrect = false;
                    cin.clear();
                    cout << "Проверьте корректность ввода данных!\n";
                    while (cin.get() != '\n');
                }
                if (isCorrect && cin.get() != '\n')
                {
                    isCorrect = false;
                    cout << "Проверьте корректность ввода данных!\n";
                    while (std::cin.get() != '\n');
                }
                if (isCorrect)
                    isCorrect = checkArea(matrix[row][col], MIN_MARK, MAX_MARK);
            } while (!isCorrect);
            return matrix;
}
void readMatrix(int**& matrix)
{
    string pathToFile;
    pathToFile = "";
    if (chooseFileInput())
    {
        getFileNormalReading(pathToFile);
        matrix = readFileMatrix(pathToFile);
    }
    else
        matrix = readConsoleMatrix();
}

int* findGoodMen(int**& matrix, int*& goodMen)
{
    bool goodMarks;
    int num;
    num = 1;
    goodMarks = true;
    for (int row = FIRST_STUDENT; row < LAST_STUDENT; row++)
    {
        for (int col = FIRST_COLUMN; col < LAST_COLUMN; col++)
        {
            if (matrix[row][col] < 9)
                goodMarks = false;
        }
        if (goodMarks)
            goodMen[num] = num;
        goodMarks = true;
        num++;
    }
    return goodMen;
}



bool chooseFileOutput()
{
    int isFileOutput;
    bool isCorrect;
    bool choose;
    isFileOutput = 0;
    choose = false;
    cout << "\n";
    do {
        isCorrect = true;
        cout << "Вы хотите выводить матрицу через файл? (Да - " << 1 << " / Нет - " << 0 << ")\n";
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

void printConsoleResult(int* goodMen)
{
    int row;
    row = FIRST_STUDENT;
    cout << "Номера отличников: ";
    for (row; row < LAST_STUDENT; row++)
    {
        if (goodMen[row] > 0)
            cout << goodMen[row] << " ";
    }
}
void printFileResult(string pathToFile, int* goodMen)
{
    int row;
    ofstream file(pathToFile, ios::app);
    row = FIRST_STUDENT;
    file << "Номера отличников\n";
    for (row; row < LAST_STUDENT; row++)
    {
        if (goodMen[row] > 0)
            file << goodMen[row] << " ";
    }
    file.close();
}
void printResult(int* goodMen)
{
    string pathToFile;
    pathToFile = "";
    if (chooseFileOutput())
    {
        getFileNormalWriting(pathToFile);
        printFileResult(pathToFile, goodMen);
    }
    else
        printConsoleResult(goodMen);
}

void freeMemory(int**& matrix, int*& goodMen)
{
    for (int i = 0; i < LAST_COLUMN; i++)
        delete[] matrix[i];
    delete[] matrix;
    delete[] goodMen;
}

int main()
{
    int** matrix;
    int* goodMen;
    createGoodMen(goodMen);
    setlocale(LC_ALL, "RU");
    printTask();
    readMatrix(matrix);
    findGoodMen(matrix, goodMen);
    printResult(goodMen);
    freeMemory(matrix, goodMen);
    return 0;
}
