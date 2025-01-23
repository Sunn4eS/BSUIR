#include <iostream>
#include <string>
#include <fstream>
using namespace std;
enum ERRORS_LIST {
    CORRECT, RANGE_ERR, NUM_ERR, NOT_TXT, NOT_EXIST, NOT_READABLE, NOT_WRITEABLE, ORDER_ERR, CHOICE_ERR, FILE_EMPTY
};
const string ERRORS[] = {
    "", "Значение не попадает в диапазон!", "Проверьте корректность ввода данных!", "Расширение не txt!", "Проверьте корректность ввода пути к файлу!", "Файл закрыт для чтения!", "Файл закрыт для записи!", "Значения порядков не равны!", "Проверьте корректность выбора!", "Файл пуст!"
};
constexpr int MIN_MATRIX = 2;
constexpr int MAX_MATRIX = 100;

void printTask()
{
    cout << "Данная программа располагает строки матрицы по возрастанию эелементов побочной диагонали исходной матрицы:\n\n";
}
ERRORS_LIST checkArea(int num, const int MIN, const int MAX)
{   
    ERRORS_LIST error;
    error = CORRECT;
    if (num < MIN || num > MAX)
        error = RANGE_ERR;
    return error;
}
void setLengthMatrix(int**& matrix, int order)
{
    matrix = new int* [order];
    for (int i = 0; i < order; i++)
        matrix[i] = new int[order];
}
void printError(ERRORS_LIST error)
{
    cout << ERRORS[error] << "\nПовторите попытку";
}
void setLegnthDiagonal(int**& diagonal, int order)
{
    diagonal = new int* [order];
    for (int i = 0; i < 2; i++)
        diagonal[i] = new int[order];
}
int checkNum(int MIN, int MAX)
{
    ERRORS_LIST error;
    int num;
    do
    {
        error = CORRECT;
        cin >> num;
        if (cin.fail())
        {
            error = CHOICE_ERR;
            cin.clear();
            while (cin.get() != '\n');
        }
        if (error == CORRECT && cin.get() != '\n')
        {
            error = CHOICE_ERR;
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
int** copyMatrix(int**& resMatrix, int** matrix, int order)
{
    setLengthMatrix(resMatrix, order);
    for (int i = 0; i < order; ++i) {
        resMatrix[i] = new int[order];
        for (int j = 0; j < order; ++j) {
            resMatrix[i][j] = matrix[i][j];
        }
    }
    return resMatrix;
}
bool checkInOut()
{
    const int FILE_CHOICE = 1;
    const int CONSOLE_CHOICE = 2;
    ERRORS_LIST error;
    int num;
    bool choose;
    choose = false;
    num = checkNum(FILE_CHOICE, CONSOLE_CHOICE);
    if (num == 1)
        choose = true;
    return choose;
}
void setLegnthMaxInColumn(int*& maxInColumn, int order)
{
    maxInColumn = new int[order];
}
bool chooseFileInput()
{
    bool choose;
    choose = false;
    cout << "Вы хотите вводить матрицу через файл? (Да - " << 1 << " / Нет - " << 2 << ")\n";
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
int readOrder(string& pathTofile, int num)
{
    int buf;
    int order;
    int rows;
    int cols;
    ERRORS_LIST error;
    order = 0;
    error = CORRECT;
    ifstream file(pathTofile);
    if (num == 2)
    {
        cout << "Введите порядок матрицы [" << MIN_MATRIX << ": " << MAX_MATRIX << "]: ";
        order = checkNum(MIN_MATRIX, MAX_MATRIX);
    }
    else
    {
        rows = 0;
        cols = 0;
        buf = 0;
        
        file >> order;
        file.get() != '\n';
        if (checkArea(order, MIN_MATRIX, MAX_MATRIX) != CORRECT)
        {
            error = ORDER_ERR;
            file.close();
        }
        else
        {
            while (error == CORRECT && !file.eof())
            {
                cols = 0;
                while (error == CORRECT && file.peek() != '\n' && !file.eof())
                {
                    file >> buf;
                    cols++;
                }
                if (error == CORRECT)
                {
                    file.get() != '\n';
                    rows++;
                    if (cols == order)
                        error = CORRECT;
                }  
            }
            file.get() != '\n';
        }
        file.close();
        if (error == CORRECT)
        {
            error = checkArea(rows, MIN_MATRIX, MAX_MATRIX);
            error = checkArea(cols, MIN_MATRIX, MAX_MATRIX);
        }
        if ((error == CORRECT) && (rows != order || cols != order))
            error = ORDER_ERR;
    }
    if (error != CORRECT)
        printError(error);
    if (error == CORRECT)
        return order;
}
void readMatrix(int**& matrix, int& order)
{
    string pathToFile;
    const int MIN_ELEMENT = -1000;
    const int MAX_ELEMENT = 1000;
    ERRORS_LIST error;
    bool isCorrect;
    bool fromFile;
    int orderCheck;
    orderCheck = 0;
    fromFile = chooseFileInput();                                              
    pathToFile = ' ';
    if (fromFile)
    {
        do
        {
            isCorrect = true;
            fileReading(pathToFile);
            order = readOrder(pathToFile, 1);
            orderCheck = order;
            if (order == 0)
                isCorrect = false; 
        } while (!isCorrect);
    }
    else
        order = readOrder(pathToFile, 2);
    setLengthMatrix(matrix, order);
    ifstream file(pathToFile);
    file.get() != '\n';

    for (int row = 0; row < order; row++)
    {
        for (int col = 0; col < order; col++)
        {
            if (fromFile)
            {
                file >> matrix[row][col];
                error = checkArea(matrix[row][col], MIN_ELEMENT, MAX_ELEMENT);
            }
            else
            {
                cout << "Введите в " << (row + 1) << " строке " << (col + 1) << " столбце элемент [" << MIN_ELEMENT << " : " << MAX_ELEMENT << "]: ";
                matrix[row][col] = checkNum(MIN_ELEMENT, MAX_ELEMENT);
            }
        }
        if (fromFile)
            file.get() != '\n';
    }
    if (fromFile)
        file.close();
}
void swapMatrixColumns(int**& diagonal, int col1, int col2, int order)
{
    int temp;
    for (int i = 0; i < 2; i++)
    {
        temp = diagonal[i][col1];
        diagonal[i][col1] = diagonal[i][col2];
        diagonal[i][col2] = temp;
    }
}
int** createMatrixOfDiagonalElements(int** matrix, int& order)
{
    int** diagonal;
    setLegnthDiagonal(diagonal, order);
    for (int i = 0; i < order; i++)
    {
        diagonal[0][i] = matrix[i][order - 1 - i];
        diagonal[1][i] = i;                    
    }
    return diagonal;
}
int** sortDiagonal(int**& diagonal, int& order)
{
    int minInColumn;
    int numOfColumn;
    int i;
    for (int j = 0; j < order - 1; j++)
    {
        i = j + 1;
        minInColumn = diagonal[0][j];
        numOfColumn = j;
        while (i < order)
        {
            if (minInColumn > diagonal[0][i])
            {
                minInColumn = diagonal[0][i];
                numOfColumn = i;
            }
            i++;
        }
        if (numOfColumn != j)
            swapMatrixColumns(diagonal, j, numOfColumn, order);
    }
    return diagonal;
}
void moveLines(int** resMatrix, int** matrix, int newLine, int prevLine, int order)
{
    for (int col = 0; col < order; ++col)
        resMatrix[prevLine][col] = matrix[newLine][col];
}
int** sortMatrix(int** matrix, int** diagonal, int order)
{
    int** resMatrix;
    int newLine;
    resMatrix = copyMatrix(resMatrix, matrix, order);
    for (int i = 0; i < order; i++)
    {
        newLine = diagonal[1][i];
        moveLines(resMatrix, matrix, newLine, i, order);
    }
    return resMatrix;

}
void freeMemory(int**& matrix, int**& resMatrix, int**& diagonal, int order)
{
    for (int i = 0; i < order; i++)
        delete[] matrix[i];
    delete[] matrix;

    for (int i = 0; i < order; i++)
        delete[] resMatrix[i];
    delete[] resMatrix;

    for (int i = 0; i < 2; i++)
        delete[] diagonal[i];
    delete[] diagonal;
}
bool chooseFileOutput()
{
    cout << "\nВы хотите выводить матрицу через файл? (Да - " << 1 << " / Нет - " << 2 << ")\n";
    return checkInOut();
}
void printResult(int** resMatrix, int order)
{
    int line = 0;
    int column = 0;
    string pathToFile;
    
    bool printToFile;
    printToFile = chooseFileOutput();
    pathToFile = ' ';
    if (printToFile)
    {
        fileWriting(pathToFile);
        ofstream fileOut(pathToFile, std::ios::app);
        fileOut << "Отсортированная Матрица:\n";
    }
    else
        cout << "Отсортированная Матрица:\n";
    ofstream fileOut(pathToFile, std::ios::app);
    for (line = 0; line < order; line++)
    {
        for (column = 0; column < order; column++)
        {
            if (printToFile)
                fileOut << resMatrix[line][column] << " ";
            else
                cout << resMatrix[line][column] << " ";
        }
        if (printToFile)
            fileOut << "\n";
        else
            cout << "\n";
    }
    if (printToFile)        
        fileOut.close();  
}
int main()
{
    int** matrix;
    int order;
    int** diagonal;
    int** resMatrix;

    setlocale(LC_ALL, "RU");
    printTask();
    readMatrix(matrix, order);
    diagonal = createMatrixOfDiagonalElements(matrix, order);
    diagonal = sortDiagonal(diagonal, order);
    resMatrix = sortMatrix(matrix, diagonal, order);
    printResult(resMatrix, order);
    freeMemory(matrix, resMatrix, diagonal, order);
    return 0;
}
