#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


const int size_26 = 6;
const int size_27 = 5;
const int size_3 = 7;

void task26() {
    printf("Task 26\n");

    int a[size_26][size_26];

    srand(time(0));
    for (int i = 0; i < size_26; i++) {
        for (int j = 0; j < size_26; j++) {
            a[i][j] = rand() % 100;
        }
    }

    for (int i = 0; i < size_26; i++) {
        for (int j = 0; j < size_26; j++) {
            printf("%d ", a[i][j]);
        }
        printf("\n");
    }


    for (int i = 0; i < size_26; i++) {
        int minElem = a[i][0];
        int maxElem = a[i][0];
        int tempMin = 0;
        int tempMax = 0;
        for (int j = 0; j < size_26; j++) {
            if (a[i][j] < minElem) {
                minElem = a[i][j];
                tempMin = j;
            }
            if (a[i][j] > maxElem) {
                maxElem = a[i][j];
                tempMax = j;
            }
        }
        a[i][tempMin]= maxElem;
        a[i][tempMax] = minElem;
    }

    printf("\n");
    for (int i = 0; i < size_26; i++) {
        for (int j = 0; j < size_26; j++) {
            printf("%d ", a[i][j]);
        }
        printf("\n");
    }
}
void task27 () {
    printf("Task 27\n");
    int b[size_27][size_27];
    srand(time(0));
    for (int i = 0; i < size_27; i++) {
        for (int j = 0; j < size_27; j++) {
            b[i][j] = rand() % 100;
        }
    }

    for (int i = 0; i < size_27; i++) {
        for (int j = 0; j < size_27; j++) {
            printf("%d ", b[i][j]);
        }
        printf("\n");
    }


    for (int j = 0; j < size_27; j++) {
        int minElem = b[0][j];
        int minInd = j;
        for (int i = 0; i < size_27; i++) {
            if (b[i][j] < minElem) {
                minElem = b[i][j];
                minInd = i;
            }
        }
        b[minInd][j] = b[size_27- 1-j][j];
        b[size_27- 1 -j][j] = minElem;
    }
    printf("\n");
    for (int i = 0; i < size_27; i++) {
        for (int j = 0; j < size_27; j++) {
            printf("%d ", b[i][j]);
        }
        printf("\n");
    }
}
void task3 (){
    printf("Task 3\n");
    int c[size_3][size_3];
    for (int i = 0; i < size_3; i++) {
        for (int j = 0; j < size_3; j++) {
            c[i][j] = rand() % 100;
        }
    }

    for (int i = 0; i < size_3; i++) {
        for (int j = 0; j < size_3; j++) {
            printf("%d ", c[i][j]);
        }
        printf("\n");
    }

    for (int i = 0; i < size_3; i++) {
        for (int j = 0; j < size_3; j++) {
            for (int k = j; k > 0 && c[i][k - 1] > c[i][k]; k--) {
                int temp = c[i][k-1];
                c[i][k-1] = c[i][k];
                c[i][k] = temp;
            }
        }
    }

    int sumArr [2][size_3];
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < size_3; j++) {
            sumArr[i][j] = 0;
        }
    }

    for (int i = 0; i < size_3; i++) {
        for (int j = 0; j < size_3; j++) {
            sumArr[0][i] = sumArr[0][i] + c[i][j];
            sumArr[1][i] = i ;
        }
    }

    printf("\n");
    for (int i = 0; i < size_3; i++) {
        for (int j = 0; j < size_3; j++) {
            printf("%d ", c[i][j]);
        }
        printf("  %d\n", sumArr[0][i]);
    }

    for (int i = size_3 - 1; i > 0; i--) {
        for (int j = i; j < size_3 && sumArr[0][j - 1] < sumArr[0][j]; j++) {
            int temp = sumArr[0][j - 1];
            int temp1 = sumArr[1][j - 1];
            sumArr[0][j - 1 ] = sumArr[0][j];
            sumArr[1][j - 1 ] = sumArr[1][j];
            sumArr[0][j] = temp;
            sumArr[1][j] = temp1;
        }
    }

    printf("\n");
    for (int i = 0; i < size_3; i++) {
        for (int j = 0; j < size_3; j++) {
            printf("%d ", c[sumArr[1][i]][j]);
        }

        printf("  %d \n", sumArr[0][i]);
    }
}
int** getMatrix(int *m) {
    int n = 0;
    printf("Enter the number of rows and columns of matrix:  ");

    scanf("%d", &n);

    srand(time(0));
    int **matrix = (int **) malloc(n * sizeof(int *));

    for (int i = 0; i < n; i++) {
        matrix[i] = (int*)malloc(n * sizeof(int));
    }

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            matrix[i][j] = rand() % 100;
        }
    }
    *m = n;
    return matrix;
}
void printMatrix (int** matrix, const int n) {
    printf("\n");
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            printf("%3d ", matrix[i][j]);
        }
        printf("\n");
    }
}
void task11 () {
    printf("Task 11_1\n");
    int n;
    int** matrix = getMatrix(&n);
    printMatrix(matrix, n);

    int minElem = matrix[0][1];

    for (int i = 0; i < n/2; i++) {
        for (int j = i + 1; j < n - i - 1; j++) {
            if (matrix[i][j] < minElem) {
                minElem = matrix[i][j];
            }
        }
    }

    for (int i = n/2; i < n; i++) {
        for (int j = n - i; j < i; j++) {
            if (matrix[i][j] < minElem) {
                minElem = matrix[i][j];
            }
        }
    }

    for (int i = 0; i < n; i++) {
        free(matrix[i]);
    }
    free(matrix);

    printf("\n%d\n", minElem);

}
void task11_2 () {
    printf("Task 11_2\n");
    int n;
    int** matrix = getMatrix(&n);

    printMatrix(matrix, n);

    int minElem = matrix[1][n - 1];
    for (int j = n - 1 ; j > n/2; j--) {
        for (int i = n - j; i < j - 1; i++) {
            if (matrix[i][j] < minElem) {
                minElem = matrix[i][j];
            }
        }
    }

    printf("\n%d\n", minElem);
    for (int i = 0; i < n; i++) {
        free(matrix[i]);
    }
    free(matrix);
}
void getString (char* str) {

    fgets(str, 20000, stdin);
    str[strcspn(str, "\n")] = 0;

}

void task14() {
    printf("Task 14\n");
    printf("Enter your text: ");
    char str[20000];
    getString(str);
    int count = 0;
    printf("Enter your word: ");
    char subString[100];
    getString(subString);

    int len = strlen(str) - strlen(subString);
    for (int i = 0; i < len + 1; i++) {
        int j;
        for (j = 0; str[i + j] != '\0'; j++) {
            if (str[i + j] != subString[j]) {
                break;
            }
        }
        if (j == strlen(subString)) {
            count++;
        }
    }
    printf("Count of words: %d", count);
}
void task23() {
    printf("Task 23\n");
    int m = 0;
    int n = 0;
    char strA[200];
    char strB[200];
    printf("Enter M: ");
    scanf("%d", &m);
    printf("Enter N: ");
    scanf("%d", &n);
    fflush(stdin);
    printf("Enter string A: ");
    getString(strA);
    printf("Enter string B: ");
    getString(strB);

    for (int i = 0; i < n; i++) {
        strA[m + i] = strB[i];
    }
    printf("Your string: %s\n", strA);
}

void removeChar (char* str, char c) {
    char newStr[200];
    int j = 0;
    for (int i = 0; i < strlen(str); i++) {
        if (str[i] != c) {
            newStr[j++] = str[i];
        }
    }
    newStr[j] = '\0';
    strcpy(str, newStr);
}

void task24() {
    printf("Task 24\n");
    //32
    //A(65) a(97)
    //I(73) i(105)
    printf("Enter string: ");
    char str[200];

    getString(str);

    for (int i = 0; i < strlen(str); i++) {
        if (str[i] >= 97 && str[i] <= 105) {
            str[i] = str[i] - 32;
        }
        if (str[i] < 65 || str[i] > 73) {
            removeChar(str, str[i]);
            i--;
        }
    }
    for (int j = 0; j < strlen(str); j++) {
        for (int k = j; k > 0 && str[k - 1] > str[k]; k--) {
            int temp = str[k-1];
            str[k-1] = str[k];
            str[k] = temp;
        }
    }
    printf("Your string: %s\n", str);
}

void removeCharByAdr(char* str, int adr) {
    int len = strlen(str);
    if (adr >= 0 && adr < len) {
        for (int i = adr; i < len; i++) {
            str[i] = str[i+1];
        }
    }
}

void insertChar(char* str, char ch, int index) {
    int len = strlen(str);

    char* newStr = (char*)malloc(len + 2);
    if (!newStr) {
        printf("Ошибка выделения памяти\n");
        return;
    }

    strncpy(newStr, str, index);
    newStr[index] = ch;
    strcpy(newStr + index + 1, str + index);
    strcpy(str, newStr);
    free(newStr);
}

void task27Str () {
    printf("Task 27\n");
    char str[1000];

    printf("Enter string: ");
    getString(str);
    char substr_ch[100];
    printf("Enter substring for change: ");
    getString(substr_ch);
    char substr[100];
    printf("Enter new substring: ");
    getString(substr);

    int count = 0;
    for (int i = 0; str[i] != '\0'; i++) {
        int j;
        for (j = 0; str[i + j] != '\0'; j++) {
            if (str[i + j] != substr_ch[j]) {
                break;
            }
        }
        if (j == strlen(substr_ch)) {
            count++;
            int n = 0;
            while (n < strlen(substr_ch)) {
                removeCharByAdr(str, i);
                n++;
            }
            n = 0;

            while (n < strlen(substr)) {
                insertChar(str, substr[n], i + n);


                n++;
            }
            insertChar(str, count + 48, i + n);
            i += n;
        }

    }
    printf(str);
}

int main(void)
{
   //task26();
   //task27();
   //task3();

   //task11();
   //task11_2();

   //task14();
   //task23();
   //task24();
   task27Str();


    return 0;
}
