    #include <iostream>
    #include <string.h>
    #include <fstream>
using namespace std;
const int MIN_LENGTH = 2;
const int MAX_LENGTH = 1000;
const int MIN_ELEMENT = -10000;
const int MAX_ELEMENT = 10000;

void printTask()
{
    cout << "Данная программа проверяет невозрастающая ли последовательность:\n\n";
}
void setLengthArr(int*& arr, int length)
{
    arr = new int [length];
}
bool chooseFileInput()
{
    int isFileInput;
    bool isCorrect, choose;
    isFileInput = 0;
    choose = false;
    do {
        isCorrect = true;
        cout << "Вы хотите вводить последовательность через файл? (Да - " << 1 << " / Нет - " << 0 << ")\n";
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
        cout << "Введите путь к файлу с расширением .txt с последовательностью, у которой количество членов должно быть не меньше " <<  MIN_LENGTH << " и не больше "  << MAX_LENGTH << " а элементы должны быть в диапазоне [" <<  MIN_ELEMENT << " : " << MAX_ELEMENT << "]:";
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
    int numOfElements;
    bool isCorrect;
    numOfElements = 0;
    element = 0;
    isCorrect = true;
    ifstream file(pathToFile);
    file >> numOfElements;
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
            cout << "Длины не равны\n";
        }
    }
    if (isCorrect)
        isCorrect = checkArea(numOfElements, MIN_LENGTH, MAX_LENGTH);
    (file.get() != '\n');
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
    int length;
    int element;
    int numOfElements;
    bool isCorrect;
    numOfElements = 0;
    length = 0;
    element = 0;
    isCorrect = true;
    ifstream file(pathToFile);
    file >> numOfElements;
    file.get() != '\n';
    while (isCorrect && !file.eof())
    {
        file >> element;
        length++;
        isCorrect = checkArea(length, 0, MAX_LENGTH);
        if (length != numOfElements)
            isCorrect = true;
    }
    file.close();
    if (isCorrect && (numOfElements != length))
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
int readFileLengthOfArr(string pathToFile)
{
    int numOfElements;
    numOfElements = 0;
    ifstream file(pathToFile);
    file >> numOfElements;
    file.close();
    return numOfElements;
}
int* readFileArr(string pathToFile, int numOfElements)
{
    int* arr;
    int num;
    setLengthArr(arr, numOfElements);
    ifstream file(pathToFile);
    file.get() != '\n';
    for (num = 0; num < numOfElements; num++)
    {
        file >> arr[num];
        file.get() != '\n';
    }
    file.close();
    return arr;
}
int readConsoleLengthOfArr()
{
    int numOfElements;
    bool isCorrect;
    numOfElements = 0;
    do
    {
        isCorrect = true;
        cout << "Введите длинну числовой последовательности[" << MIN_LENGTH << " : " << MAX_LENGTH << "]: ";
        cin >> numOfElements;
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
            isCorrect = checkArea(numOfElements, MIN_LENGTH, MAX_LENGTH);
    } while (!isCorrect);
    return numOfElements;
}
int* readConsoleArr(int numOfElements)
{
    int* arr;
    bool isCorrect;
    int num;
    num = 0;
    setLengthArr(arr, numOfElements);
    for (int num = 0; num < numOfElements; num++)
            do
            {
                isCorrect = true;
                cout << "Введите в " << (num + 1) << " член последовательности [" << MAX_ELEMENT << " : " << MIN_ELEMENT << "]: "; 
                    cin >> arr[num];
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
                    isCorrect = checkArea(arr[num], MIN_ELEMENT, MAX_ELEMENT);
            } while (!isCorrect);
            return arr;
}
void readArr(int*& arr, int& numOfElements)
{
    string pathToFile;
    pathToFile = "";
    if (chooseFileInput())
    {
        getFileNormalReading(pathToFile);
        numOfElements = readFileLengthOfArr(pathToFile);
        arr = readFileArr(pathToFile, numOfElements);
    }
    else
    {
        numOfElements = readConsoleLengthOfArr();
        arr = readConsoleArr(numOfElements);
    }
}

bool isSequenceNonGrowing(int*& arr, int numOfElements)
{
    bool nonGrowing;
    int ind;
    nonGrowing = true;
    ind = 0;
    for (ind; ind < numOfElements - 1; ind++)
    {
        if (arr[ind] < arr[ind + 1])
            nonGrowing = false;
    }
    return nonGrowing;
}

void freeMemory(int*& arr)
{
    delete[] arr;
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
void printConsoleResult(bool& nonGrowing)
{
    if (nonGrowing)
        cout << "Последовательность является невозрастающей";
    else
        cout << "Последовательность не соответствует условию";
}
void printFileResult(string pathToFile, bool& nonGrowing)
{
    fstream file(pathToFile, ios::app);
    file << "\n";
    if (nonGrowing)
        file << "Последовательность является невозрастающей";
    else
        file << "Последовательность не соответствует условию";
    file.close();
}
void printResult(bool nonGrowing)
{
    string pathToFile;
    pathToFile = "";
    if (chooseFileOutput())
    {
        getFileNormalWriting(pathToFile);
        printFileResult(pathToFile, nonGrowing);
    }
    else
        printConsoleResult(nonGrowing);
}
int main()
{
    bool nonGrowing;
    int* arr;
    int numOfElements;
    nonGrowing = true;
    numOfElements = 0;
    
    setlocale(LC_ALL, "RU");
    printTask();
    readArr(arr, numOfElements);
    nonGrowing = isSequenceNonGrowing(arr, numOfElements);
    printResult(nonGrowing);
    freeMemory(arr);
    return 0;
}
