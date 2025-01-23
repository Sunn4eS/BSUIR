#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#define _CRT_SECURE_NO_WARNINGS

void cangeStr(char c, char* str) {
    int len = strlen(str);
    int index = 0;
    char* newStr = (char*)malloc(2 * len * sizeof(char));
    if (newStr != NULL) {
        for (int i = 0; str[i] != '\0'; i++) {
            if (str[i] == c) {
                newStr[index] = str[i];
                index++;
            }
            newStr[index] = str[i];
            index++;
        }
        newStr[index] = '\0'; // Завершаем строку нулевым символом
        printf("%s\n", newStr);
        free(newStr); // Освобождаем память
    }
}

int main() {
    char str[100];
    char c;

    printf("Введите строку: ");
    fgets(str, sizeof(str), stdin);
    str[strcspn(str, "\n")] = '\0'; // Удаляем символ новой строки, если он есть

    printf("Введите символ для дублирования: ");
    scanf("%c", &c);

    cangeStr(c, str);

    return 0;
}
