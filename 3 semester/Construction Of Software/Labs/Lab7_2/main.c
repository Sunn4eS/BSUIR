#include <stdio.h>
#include <string.h>

void copyEvenFromFile () {
    const char* path_i = "C:\\Users\\User\\Desktop\\inputNumbers.txt";
    const char* path_o = "C:\\Users\\User\\Desktop\\outputNumbers.txt";

    FILE *fileRead = fopen(path_i, "r");
    FILE *fileWrite = fopen(path_o, "w");
    if (fileRead == NULL || fileWrite == NULL) {
        printf("File could not be opened\n");
    } else {
        int number;
        while (fscanf(fileRead, "%d", &number) == 1) {
            if (number % 2 != 0) {
                fprintf(fileWrite, "%d ", number);
            }
        };
    }
    fclose(fileRead);
    fclose(fileWrite);
}




int main(void)
{
    copyEvenFromFile();
    return 0;
}
