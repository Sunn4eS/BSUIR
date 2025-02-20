#include <stdio.h>
#include <stdlib.h>
#include "BinaryTree.h"

int mainMenu() {
    printf("===================================================\n");
    printf ("1) Добавить\n");
    printf ("2) Удалить\n");
    printf ("3) Вывод обхода\n");
    printf ("4) Прошивка\n");
    printf ("5) Выход\n");
    printf("===================================================\n");
    int choice;
    scanf("%d", &choice);
    if (choice > 4 || choice < 1) {
        return 0;
    }
    return choice;
}
int printMenu() {
    printf("===================================================\n");
    printf ("1) Прямой\n");
    printf ("2) Симметричный\n");
    printf ("3) Обратный\n");
    printf("===================================================\n");
    int choice;
    scanf("%d", &choice);
    if (choice > 3 || choice < 1) {
        return 0;
    }
    return choice;
}

int main() {
    int choice;
    binaryTree tree = binaryTree_create();
    do {
        binaryTree_print(&tree);
        choice = mainMenu();
        int data;
        switch (choice) {
            case 1:
                printf("Введите значение узла: ");
            scanf("%d", &data);
            binaryTree_add(&tree, data);
            break;
            case 2:
                printf("Введите значение узла: ");
            scanf("%d", &data);
            binaryTree_delete(&tree, data);
            break;
            case 3:
                int choice = printMenu();
            enum printType ogo = choice;
            binaryTree_printWithOrder(&tree, ogo);
            break;
            case 4:
                binaryTree_firmware(&tree);
            break;
        }
    } while (choice != 0);
    return 0;
}
