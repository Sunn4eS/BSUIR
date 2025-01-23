#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_LENGTH 255


enum tCharType {
    ctUnknown,
    ctChar,
    ctQuotes
};
// Первый столбец ctUnknown
// Второй столбец ctChar
// Третий столбец сtQuotes
const int currState [4][3] = {
    {0, 0, 0}, //Ошибка
    {0, 0, 2}, //Ждём кавычки
    {0, 2, 3}, //Читаем кавычки, ждём символ
    {0, 0, 2}  //Ждём кавычки
};
const int isFinalState [4] = {0, 0, 0, 1};

int getFirstQuote(char ch) {
    if (ch == '\'') {
        return ctQuotes;
    }
    return ctUnknown;
}

int getNextChar(char ch) {
    if (ch == '\'') {
        return ctQuotes;
    }
    if (ch >= 32 && ch <= 127) {
        return ctChar;
    }
    return ctUnknown;
}
int checkChar(char inputStr[]) {
    int i = 0;
    int curr = 1;
    for (i = 0; inputStr[i] != '\0' && inputStr[i] != '\n'; i++) {
        curr = currState[curr][getNextChar(inputStr[i])];
    }
    int res = isFinalState[curr] ;
    return res;
}

int isDuplicate(char** arr, int size, const char* str) {
    for (int i = 0; i < size; i++) {
        if (strcmp(arr[i], str) == 0) {
            return 1; // Найден дубликат
        }
    }
    return 0; // Дубликат не найден
}

void removeDuplicates(char*** arr, int* size) {
    char** uniqueArr = NULL;
    int uniqueCount = 0;

    for (int i = 0; i < *size; i++) {
        if (!isDuplicate(uniqueArr, uniqueCount, (*arr)[i])) {
            uniqueCount++;
            uniqueArr = (char**)realloc(uniqueArr, uniqueCount * sizeof(char*));
            uniqueArr[uniqueCount - 1] = strdup((*arr)[i]); // Копируем строку
        }
    }

    // Освобождаем старый массив
    for (int i = 0; i < *size; i++) {
        free((*arr)[i]);
    }
    free(*arr); // Освобождаем массив указателей

    *arr = uniqueArr; // Обновляем указатель на массив
    *size = uniqueCount; // Обновляем размер
}

char** getPascalLiterals(char inputStr[], int* size) {
    char** resultStrArr = NULL;
    *size = 0;
    int state = 1, start = 1, nextState = 1;
    for (int i = 0; inputStr[i] != '\0' && inputStr[i] != '\n'; i++) {
        state = currState[state][getNextChar(inputStr[i])];
        if (state == 0) {
            start = i + 1;
            state = 1;
        }
        else if (isFinalState[state]) {
            (*size)++;
            if (resultStrArr == NULL) {
                resultStrArr = (char**)calloc((*size), sizeof(char*));
            } else {
                resultStrArr = (char**)realloc(resultStrArr, (*size) * sizeof(char*));
            }
            resultStrArr[*size - 1] = (char*)calloc(strlen(inputStr) - start, sizeof(char));
            strcpy(resultStrArr[*size - 1], inputStr + start);
            resultStrArr[*size - 1][i - start + 1] = '\0';
            start = i + 1;
            state = 1;
        }
    }

        state = 1, start = 1;
        for (int j = 0; inputStr[j] != '\0' && inputStr[j] != '\n'; j++) {
            state = currState[state][getNextChar(inputStr[j])];
            nextState = currState[state][getNextChar(inputStr[j + 1])];
            if (state == 0) {
                start = j + 1;
                state = 1;
            }
            else if (isFinalState[state] && nextState == 0) {
                (*size)++;
                if (resultStrArr == NULL) {
                    resultStrArr = (char**)calloc(*size, sizeof(char*));
                } else {
                    resultStrArr = (char**)realloc(resultStrArr, (*size) * sizeof(char*));
                }
                resultStrArr[*size - 1] = (char*)calloc(strlen(inputStr) - start, sizeof(char));
                strcpy(resultStrArr[*size - 1], inputStr + start);
                resultStrArr[*size - 1][j - start + 1] = '\0';
                start = j + 1;
                state = 1;
                nextState = 1;
            }
        }
    removeDuplicates(&resultStrArr, size);
    return resultStrArr;

}
int chooseInput() {
    int choice;
    int isGoodChoice = 1;
    while (isGoodChoice) {
        printf("Read from file - 1\nRead from console - 2\n");
        scanf("%d", &choice);
        fflush(stdin);
        if (choice == 1) {
            isGoodChoice = 0;
        } else if (choice == 2) {
            isGoodChoice = 0;
        }
        return choice;
    }
}
void readFileStr(char inputStr[]) {
    char path[MAX_LENGTH];
    int flag = 1;
    while (flag) {
        printf("Please enter a file path: ");
        fgets(path, MAX_LENGTH, stdin);
        path[strlen(path) - 1] = '\0';
        FILE *file = fopen(path, "r");
        if (file == NULL) {
            printf("File not found\n");
        } else {
            fgets(inputStr, MAX_LENGTH, file);
            printf("File was read\n");
            flag = 0;
        }
        fclose(file);
    }
    printf("You entered a string [%s]\n", inputStr);
}

int main(void)
{
    char inputStr [MAX_LENGTH];
    int choice = chooseInput();
    if (choice == 2) {
        printf("Enter a string [%d]: ", MAX_LENGTH);
        if (fgets(inputStr, MAX_LENGTH, stdin) != "\n") {
            if (strlen(inputStr) == MAX_LENGTH - 1 && inputStr[MAX_LENGTH - 2] != '\n') {
                printf("You entered a long string, program will check first %d symbols:\n", MAX_LENGTH - 2);
                while (getchar() != '\n');
            }
            inputStr[strlen(inputStr) - 1] = '\0';
            //printf("You entered a string [%s]\n", inputStr);
        }
    } else if (choice == 1) {
        readFileStr(inputStr);
    }



    int size = 1;
    if (checkChar(inputStr) == 1) {
        printf("Your string is correct\n");
        printf("You entered a string [%s]\n", inputStr);
    } else {
        char** resultStr = getPascalLiterals(inputStr, &size);
        if (resultStr == NULL || size == 0) {
            printf("Zero Pascal literals in your");

        } else {
            for (int i = 0; i < size; i++)
                printf("%d. %s\n", i + 1, resultStr[i]);
        }
        for (int i = 0; i < size; i++) {
            free(resultStr);
        }
        free(resultStr);
    }
    return 0;
}
