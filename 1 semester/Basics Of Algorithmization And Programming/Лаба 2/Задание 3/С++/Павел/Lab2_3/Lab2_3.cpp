#include <iostream>
#include <string.h>
#include <fstream>
using std::cin;
using std::cout;
using std::string;
using std::fstream;
const int
MIN_O = 1,
MAX_O = 10,
MIN_MAT = 1,
MAX_MAT = 1000000,
YES = 1,
NO = 2;
void printTask()
{
    cout << "Данная программа подсчитывает число повторяющихся элементов в матрице.\n\n";
}
void setLengthMatrix(int**& matrix, int order)
{
    matrix = new int* [order];
    for (int i = 0; i < order; i++)
        matrix[i] = new int[order];
}
bool chooseFileInput()
{
    int isFileInput;
    bool isCorrect, choose;
    isFileInput = 0;
    choose = false;
    do {
        isCorrect = true;
        cout << "Вы хотите вводить матрицу через файл? (Да - " << YES << " / Нет - " << NO << ")\n";
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
            if (isFileInput == YES)
                choose = true;
            else if (isFileInput == NO)
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
        cout << "Введите путь к файлу с расширением .txt с матрицей, у которой разряд не должен превышать " << MAX_O << ", а её натуральные элементы должны лежать в пределе[" <<
            MIN_MAT << ":" << MAX_MAT << "]: ";
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
    std::ifstream file(pathToFile);
    if (file.good())
        isCorrect = true;
    file.close();
    return isCorrect;
}
bool isAbleToReading(std::string pathToFile)
{
    bool isCorrect;
    isCorrect = false;
    std::ifstream file(pathToFile);
    if (file.is_open())
        isCorrect = true;
    file.close();
    return isCorrect;
}
bool isAbleToWriting(std::string pathToFile)
{
    bool isCorrect;
    isCorrect = false;
    std::ofstream file(pathToFile, std::ios::app);
    if (file.is_open())
        isCorrect = true;
    file.close();
    return isCorrect;
}
bool isEmpty(std::string pathToFile)
{
    bool isCorrect;
    isCorrect = false;
    std::ifstream file(pathToFile);
    if (file.peek() == std::ifstream::traits_type::eof())
        isCorrect = true;
    file.close();
    return isCorrect;
}
bool isRightFileNums(std::string pathToFile)
{
    int k;
    bool isCorrect;
    k = 0;
    isCorrect = true;
    std::ifstream file(pathToFile);
    file >> k;
    if (file.fail())
    {
        isCorrect = false;
        file.clear();
        std::cout << "Проверьте порядок матрицы!\n";
    }
    if (isCorrect)
    {
        if (file.peek() != '\n')
        {
            isCorrect = false;
            std::cout << "Неправильный порядок матрицы!\n";
        }
    }
    if (isCorrect)
        isCorrect = checkArea(k, MIN_O, MAX_O);
    file.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    while (isCorrect && !file.eof())
    {
        while (isCorrect && file.peek() != '\n' && !file.eof())
        {
            file >> k;
            if (file.fail())
            {
                isCorrect = false;
                file.clear();
            }
            if (isCorrect)
                isCorrect = checkArea(k, MIN_MAT, MAX_MAT);
        }
        file.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }
    file.close();
    return isCorrect;
}
bool isOrdersEqual(std::string pathToFile)
{
    int order, rows, cols, k;
    bool isCorrect;
    order = 0;
    rows = 0;
    cols = 0;
    k = 0;
    isCorrect = true;
    std::ifstream file(pathToFile);
    file >> order;
    file.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    while (isCorrect && !file.eof())
    {
        cols = 0;
        while (isCorrect && file.peek() != '\n' && !file.eof())
        {
            file >> k;
            cols++;
            isCorrect = checkArea(cols, MIN_O, MAX_O);
        }
        if (isCorrect)
        {
            file.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            rows++;
            isCorrect = checkArea(rows, MIN_O, MAX_O);
            if (cols != order)
                isCorrect = false;
        }
    }
    file.close();
    if (isCorrect && rows != order)
        isCorrect = false;
    return isCorrect;
}
void getFileNormalReading(std::string& pathToFile)
{
    bool isCorrect;
    do
    {
        isCorrect = true;
        pathToFile = readPathFile();
        if (!isExists(pathToFile))
        {
            isCorrect = false;
            std::cout << "Проверьте корректность ввода пути к файлу!\n";
        }
        if (isCorrect && !isAbleToReading(pathToFile))
        {
            isCorrect = false;
            std::cout << "Файл закрыт для чтения!\n";
        }
        if (isCorrect && !isAbleToWriting(pathToFile))
        {
            isCorrect = false;
            std::cout << "Файл закрыт для записи!\n";
        }
        if (isCorrect && isEmpty(pathToFile))
        {
            isCorrect = false;
            std::cout << "Файл пуст!\n";
        }
        if (isCorrect && !isRightFileNums(pathToFile))
        {
            isCorrect = false;
            std::cout << "Некорректный тип данных внутри файла!\n";
        }
        if (isCorrect && !isOrdersEqual(pathToFile))
        {
            isCorrect = false;
            std::cout << "Значения порядков не равны!\n";
        }
    } while (!isCorrect);

}
void getFileNormalWriting(std::string& pathToFile)
{
    bool isCorrect;
    do
    {
        isCorrect = true;
        pathToFile = readPathFile();
        if (!isExists(pathToFile))
        {
            isCorrect = false;
            std::cout << "Проверьте корректность ввода пути к файлу!\n";
        }
        if (isCorrect && !isAbleToWriting(pathToFile))
        {
            isCorrect = false;
            std::cout << "Файл закрыт для записи!\n";
        }
    } while (!isCorrect);
}
int readFileOrder(std::string pathToFile)
{
    int order;
    order = 0;
    std::ifstream file(pathToFile);
    file >> order;
    file.close();
    return order;
}
int** readFileMatrix(std::string pathToFile, int order)
{
    int** matrix;
    int row, col;
    setLengthMatrix(matrix, order);
    std::ifstream file(pathToFile);
    file.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    for (int row = 0; row < order; row++)
    {
        for (int col = 0; col < order; col++)
            file >> matrix[row][col];
        file.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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
        std::cout << "Введите порядок матрицы order[" << MIN_O << "; " << MAX_O << "]: ";
        std::cin >> order;
        if (std::cin.fail())
        {
            isCorrect = false;
            std::cin.clear();
            std::cout << "Проверьте корректность ввода данных!\n";
            while (std::cin.get() != '\n');
        }
        if (isCorrect && std::cin.get() != '\n')
        {
            isCorrect = false;
            std::cout << "Проверьте корректность ввода данных!\n";
            while (std::cin.get() != '\n');
        }
        if (isCorrect)
            isCorrect = checkArea(order, MIN_O, MAX_O);
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
                std::cout << "Введите в " << (row + 1) << " строке " << (col + 1) << " столбце натуральный элемент[" << MIN_MAT << "; " << MAX_MAT << "]: ";
                std::cin >> matrix[row][col];
                if (std::cin.fail())
                {
                    isCorrect = false;
                    std::cin.clear();
                    std::cout << "Проверьте корректность ввода данных!\n";
                    while (std::cin.get() != '\n');
                }
                if (isCorrect && std::cin.get() != '\n')
                {
                    isCorrect = false;
                    std::cout << "Проверьте корректность ввода данных!\n";
                    while (std::cin.get() != '\n');
                }
                if (isCorrect)
                    isCorrect = checkArea(matrix[row][col], MIN_MAT, MAX_MAT);
            } while (!isCorrect);
            return matrix;
}
void readMatrix(int**& matrix, int& order)
{
    std::string pathToFile;
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
void fillArr(int** matrix, int order, int*& arr, int& arrLen)
{
    int i;
    i = 0;
    arrLen = order * order;
    arr = new int[arrLen];
    for (int row = 0; row < order; row++)
        for (int col = 0; col < order; col++)
        {
            arr[i] = matrix[row][col];
            i++;
        }
}
void sortArr(int*& arr, int arrLen)
{
    int maxIndex, buf;
    maxIndex = arrLen - 1;
    for (int i = 0; i < arrLen; i++)
        for (int j = 0; j < maxIndex - i; j++)
            if (arr[j] > arr[j + 1])
            {
                buf = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = buf;
            }
}
void findSame(int* arr, int arrLen, int**& resMatrix)
{
    int j, count, maxIndex;
    count = 1;
    j = 0;
    maxIndex = arrLen - 1;
    setLengthMatrix(resMatrix, arrLen);
    for (int i = 0; i < maxIndex; i++)
        if (arr[i] == arr[i + 1])
            count++;
        else
        {
            resMatrix[j][0] = arr[i];
            resMatrix[j][1] = count;
            j++;
            count = 1;
        }
    resMatrix[j][0] = arr[arrLen - 1];
    resMatrix[j][1] = count;
    resMatrix[j + 1][1] = 0;
}
void freeMemory(int**& matrix, int order, int*& arr, int**& resMatrix, int arrLen)
{
    for (int i = 0; i < order; i++)
        delete[] matrix[i];
    delete[] matrix;
    delete[] arr;
    for (int i = 0; i < arrLen; i++)
        delete[] resMatrix[i];
    delete[] resMatrix;
}
bool chooseFileOutput()
{
    int isFileOutput;
    bool isCorrect, choose;
    isFileOutput = 0;
    choose = false;
    std::cout << "\n";
    do {
        isCorrect = true;
        std::cout << "Вы хотите выводить матрицу через файл? (Да - " << YES << " / Нет - " << NO << ")\n";
        std::cin >> isFileOutput;
        if (std::cin.fail())
        {
            isCorrect = false;
            std::cout << "Некорректный выбор!\n";
            std::cin.clear();
            while (std::cin.get() != '\n');
        }
        if (isCorrect && std::cin.get() != '\n')
        {
            isCorrect = false;
            std::cout << "Некорректный выбор!\n";
            while (std::cin.get() != '\n');
        }
        if (isCorrect)
        {
            if (isFileOutput == YES)
                choose = true;
            else if (isFileOutput == NO)
                choose = false;
            else
            {
                isCorrect = false;
                std::cout << "Некорректный выбор!\n";
            }
        }
    } while (!isCorrect);
    return choose;
}
void printConsoleResult(int** resMatrix, int arrLen)
{
    int i;
    i = 0;
    while (i < arrLen && resMatrix[i][1] != 0)
    {
        std::cout << "\nЧисло " << resMatrix[i][0] << " встречается " << resMatrix[i][1] << " раз(а).";
        i++;
    }
}
void printFileResult(std::string pathToFile, int** resMatrix, int arrLen)
{
    int i;
    std::ofstream file(pathToFile, std::ios::app);
    i = 0;
    file << "\n";
    while (i < arrLen && resMatrix[i][1] != 0)
    {
        file << "\nЧисло " << resMatrix[i][0] << " встречается " << resMatrix[i][1] << " раз(а).";
        i++;
    }
    file.close();
}
void printResult(int** resMatrix, int arrLen)
{
    std::string pathToFile;
    pathToFile = "";
    if (chooseFileOutput())
    {
        getFileNormalWriting(pathToFile);
        printFileResult(pathToFile, resMatrix, arrLen);
    }
    else
        printConsoleResult(resMatrix, arrLen);
}
int main()
{
    int** matrix;
    int order;
    int* arr;
    int arrLen;
    int** resMatrix;
    setlocale(LC_ALL, "RU");
    printTask();
    readMatrix(matrix, order);
    fillArr(matrix, order, arr, arrLen);
    sortArr(arr, arrLen);
    findSame(arr, arrLen, resMatrix);
    printResult(resMatrix, arrLen);
    freeMemory(matrix, order, arr, resMatrix, arrLen);
    return 0;
}