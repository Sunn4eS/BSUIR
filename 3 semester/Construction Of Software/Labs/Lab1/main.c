#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <windows.h>
#include <math.h>


float square(float x) {
    return x * x;
}

float _18a (int n) {
    float sum = 0;
    for (int i = 1; i <= n; i++) {
        sum = sum + 1.0/i;
    }
    return sum;
}

float _18b (int n) {
    float sum = 0;
    for (int i = 1; i <= n; i++) {
        sum = sum + 1.0 / square(2 * i + 1);
    }
    return sum;
}

float factorial(const int fact) {
    if (fact <= 1) {
        return 1;
    } else {
        return fact * factorial(fact - 1);
    }

}

    float _13 () {
        float sum = (1 + sin(0.1));
        float n = 0.2;
        while (n <= 10) {
            sum = sum * (1 + sin(n));
            n = n + 0.1;
        }

        return sum;
    }

float _28 (int n, int k) {
    float res = 0;

    res = (factorial(n) + factorial(k))/factorial(n + k);
    return res;
}

float _30 () {
    float res = 0;
    float arr [10];

    for (int i = 0; i < 10; i++) {
        printf("Введите %d элемент массива: ", i + 1);
        scanf("%f\n", &arr[i]);
    }
    float min_num = arr[0];
    float max_num = arr[0];

    for (int i = 0; i < 10; i++) {
        if (arr[i] < min_num)
            min_num = arr[i];
        if (arr[i] > max_num)
            max_num = arr[i];
    }
    res = max_num - min_num;
    return res;
}

void _23 (int n) {
    int sumPos = 0;
    int countNeg = 0;
    int *arr = (int *)malloc(sizeof(int) * n);
    for (int i = 0; i < n; i++) {
        printf("Введите элемент массива %d: ", i + 1);
        scanf("%d", &arr[i]);
        if (arr[i] < 0) {
            countNeg++;
        } else {
            sumPos += arr[i];
        }
    }
    printf("Сумма положительных элементов равна = %d\n", sumPos);
    printf("Кол-во отрицательных элементов равна = %d", countNeg);
}
int main(void) {
    SetConsoleOutputCP(CP_UTF8);
    printf("Лабораторная 1\n");
    int n = 0;
    int k = 0;
    float res = 0;


 //   printf("Введите число n:  ");
 //   scanf("%d", &n);

 //   printf("Введите число k:  ");
 //   scanf("%d", &k);

  //  res = _18a(n);
  //  res = _18b(n);
  //  res = _13();
  //  res = _28(n, k);
  //  res = _30();
  //  _23(n);

 //   printf("%e", res);


    _getch();
    return 0;

}

