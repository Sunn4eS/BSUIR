#include <iostream>
#include <string.h>
#include <fstream>
using namespace std;
const int MIN_MATRIX = 2;
const int MAX_MATRIX = 100;
const int MIN_ELEMENT = -100000;
const int MAX_ELEMENT = 100000;

void printTask()
{
    cout << "Данная программа находит седловую точку матрицы:\n\n";
}
void setLengthMatrix(int**& matrix, int order)
{
    matrix = new int* [order];
    for (int i = 0; i < order; i++)
        matrix[i] = new int[order];
}
void setLegnthMinInLine(int*& minInLine, int order)
{
    minInLine = new int [order];
}
void setLegnthMaxInColumn(int*& maxInColumn, int order)
{
    maxInColumn = new int[order];
}
bool chooseFileInput()
{
    int isFileInput;
    bool isCorrect, choose;
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
            while ( cin.get() != '\n');
        }
        if (isCorrect &&  cin.get() != '\n')
        {
            isCorrect = false;
             cout << "Некорректный выбор!\n";
            while ( cin.get() != '\n');
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
        cout << "Введите путь к файлу с расширением .txt с матрицей, у которой разряд не должен превышать " << MAX_MATRIX << ", а её натуральные элементы должны лежать в пределе[" << MIN_ELEMENT << " : " << MAX_ELEMENT << "]: ";
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
    int element;
    int order;
    bool isCorrect;
    element = 0;
    order = 0;
    isCorrect = true;
    ifstream file(pathToFile);
    file >> order;
    if (file.fail())
    {
        isCorrect = false;
        file.clear();
        cout << "Проверьте порядок матрицы!\n";
    }
    if (isCorrect)
    {
        if (file.peek() != '\n')
        {
            isCorrect = false;
            cout << "Неправильный порядок матрицы!\n";
        }
    }
    if (isCorrect)
        isCorrect = checkArea(order, MIN_MATRIX, MAX_MATRIX);
    file.get() != '\n';
    while (isCorrect && !file.eof())
    {
        while (isCorrect && file.peek() != '\n' && !file.eof())
        {
            file >> element;
            if (file.fail())
            {
                isCorrect = false;
                file.clear();
            }
            if (isCorrect)
                isCorrect = checkArea(element, MIN_ELEMENT, MAX_ELEMENT);
        }
        file.get() != '\n';
    }
    file.close();
    return isCorrect;
}
bool isOrdersEqual(string pathToFile)
{
    int order, rows, cols, k;
    bool isCorrect;
    order = 0;
    rows = 0;
    cols = 0;
    k = 0;
    isCorrect = true;
    ifstream file(pathToFile);
    file >> order;
    file.get() != '\n';
    while (isCorrect && !file.eof())
    {
        cols = 0;
        while (isCorrect && file.peek() != '\n' && !file.eof())
        {
            file >> k;
            cols++;
        }
        if (isCorrect)
        {
            file.get() != '\n';
            rows++;
            if (cols != order)
                isCorrect = false;
        }
    }
    file.close();
    if (isCorrect)
    {
        isCorrect = checkArea(cols, MIN_MATRIX, MAX_MATRIX);
        isCorrect = checkArea(rows, MIN_MATRIX, MAX_MATRIX);
    }
    if (isCorrect && rows != order)
        isCorrect = false;
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
        if (isCorrect && !isOrdersEqual(pathToFile))
        {
            isCorrect = false;
             cout << "Значения порядков не равны!\n";
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
int readFileOrder(string pathToFile)
{
    int order;
    order = 0;
    ifstream file(pathToFile);
    file >> order;
    file.close();
    return order;
}
int** readFileMatrix(string pathToFile, int order)
{
    int** matrix;
    int row, col;
    setLengthMatrix(matrix, order);
    ifstream file(pathToFile);
    file.get() != '\n';
    for (int row = 0; row < order; row++)
    {
        for (int col = 0; col < order; col++)
            file >> matrix[row][col];
        file.get() != '\n';
    }
    file.close();
    return matrix;
}
int readConsoleOrder()
{
    int order;
    bool isCorrect;
    order = 0;
    do
    {
        isCorrect = true;
        cout << "Введите порядок матрицы [" << MIN_MATRIX << " : " << MAX_MATRIX << "]: ";
        cin >> order;
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
            while (cin.get() != '\n');
        }
        if (isCorrect)
            isCorrect = checkArea(order, MIN_MATRIX, MAX_MATRIX);
    } while (!isCorrect);
    return order;
}
int** readConsoleMatrix(int order)
{
    int** matrix;
    bool isCorrect;
    setLengthMatrix(matrix, order);
    for (int row = 0; row < order; row++)
        for (int col = 0; col < order; col++)
            do
            {
                isCorrect = true;
                cout << "Введите в " << (row + 1) << " строке " << (col + 1) << " столбце элемент [" << MIN_ELEMENT << " : " << MAX_ELEMENT << "]: "; 
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
                    while (cin.get() != '\n');
                }
                if (isCorrect)
                    isCorrect = checkArea(matrix[row][col], MIN_ELEMENT, MAX_ELEMENT);
            } while (!isCorrect);
    return matrix;
}
void readMatrix(int**& matrix, int& order)
{
    string pathToFile;
    pathToFile = "";
    if (chooseFileInput())
    {
        getFileNormalReading(pathToFile);
        order = readFileOrder(pathToFile);
        matrix = readFileMatrix(pathToFile, order);
    }
    else
    {
        order = readConsoleOrder();
        matrix = readConsoleMatrix(order);
    }
}
int* findMinInLine(int** matrix, int order)
{
    int* minInLine;
    int line;
    int column;
    line = 0;
    column = 0;
    setLegnthMinInLine(minInLine, order);
    for (line = 0; line < order; line++)
    {
        minInLine[line] = matrix[line][0];
        for (column = 0; column < order; column++)
            if (matrix[line][column] < minInLine[line])
                minInLine[line] = matrix[line][column];
    }
    return minInLine;
}
int* findMaxInColumn(int** matrix, int order)
{
    int* maxInColumn;
    int line;
    int column;
    setLegnthMaxInColumn(maxInColumn, order);
    line = 0;
    column = 0;
    for (column = 0; column < order; column++)
    {
        maxInColumn[column] = matrix[0][column];
        for (line = 0; line < order; line++)
            if (matrix[line][column] > maxInColumn[column])
                maxInColumn[column] = matrix[line][column];
    }
    return maxInColumn;
}
void freeMemory(int**& matrix, int order, int*& minInLine, int*& maxInColumn)
{
    for (int i = 0; i < order; i++)
        delete[] matrix[i];
    delete[] matrix;
    delete[] minInLine;
    delete[] maxInColumn;
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
void printConsoleResult(int* minInLine, int* maxInColumn, int order)
{
    int line;
    int column;
    bool saddlePoint;
    line = 0;
    column = 0;
    saddlePoint = false;
    for (line = 0; line < order; line++)
        for (column = 0; column < order; column++)
            if (minInLine[line] == maxInColumn[column])
            {
                cout << "Седловая точка находиться на месте: " << line + 1 << " " << column + 1;
                saddlePoint = true;
            }
    if (!saddlePoint)
        cout << "Нет седловой точки!";
}
void printFileResult(string pathToFile, int* minInLine, int* maxInColumn, int order)
{
    int line;
    int column;
    bool saddlePoint;
    line = 0;
    column = 0;
    saddlePoint = false;
    ofstream file(pathToFile, ios::app);
    file << "\n";
    for (line = 0; line < order; line++)
        for (column = 0; column < order; column++)
            if (minInLine[line] == maxInColumn[column])
            {
                file << "Седловая точка находиться на месте: " << line + 1 << " " << column + 1;
                saddlePoint = true;
            }
    if (!saddlePoint)
        file << "Нет седловой точки!";
    file.close();
}
void printResult(int* minInLine, int* maxInColumn, int order)
{
    string pathToFile;
    pathToFile = "";
    if (chooseFileOutput())
    {
        getFileNormalWriting(pathToFile);
        printFileResult(pathToFile, minInLine, maxInColumn, order);
    }
    else
        printConsoleResult(minInLine, maxInColumn, order);
}
int main()
{
    int** matrix;
    int order;

    int* maxInColumn;
    int H;
    int* minInLine = &H;
    int& link = H;
  
    setlocale(LC_ALL, "RU");
    printTask();
    readMatrix(matrix, order);
    maxInColumn = findMaxInColumn(matrix, order);
    minInLine = findMinInLine(matrix, order);
    printResult(minInLine, maxInColumn, order);
    freeMemory(matrix, order, minInLine, maxInColumn);
    //cout << &H << std::endl << &link << std::endl << H << std::endl << link << std::endl << *minInLine << std::endl;
   // cout << sizeof(int) << sizeof(short);
    return 0;
}
