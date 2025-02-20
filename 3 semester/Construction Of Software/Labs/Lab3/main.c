#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct applicant {
    char lastName[20];
    char town[20];
    float avg;
};

void insertionSort(struct applicant* persons, int count) {
    for (int i = 1; i < count; i++) {
        struct applicant key = persons[i];
        int j = i - 1;
        while (j >= 0 && strcmp(persons[j].lastName, key.lastName) > 0) {
            persons[j + 1] = persons[j];
            j--;
        }
        persons[j + 1] = key;
    }
}



int main(void)
{
    struct applicant person[9];
    strcpy(person[0].lastName, "Beliaev");
    strcpy(person[0].town, "Minsk");
    person[0].avg = 8.3;
    strcpy(person[1].lastName,"Brazhalovich");
    strcpy(person[1].town,"Shchuchin");
    person[1].avg = 8.5;
    strcpy(person[2].lastName,"Gasuk");
    strcpy(person[2].town,"Kobrin");
    person[2].avg = 7.2;
    strcpy(person[3].lastName,"Zakhvey");
    strcpy(person[3].town,"Sloboda");
    person[3].avg = 9.3;
    strcpy(person[4].lastName,"Galuha");
    strcpy(person[4].town,"Stolin");
    person[4].avg = 9.5;
    strcpy(person[5].lastName,"Leshok");
    strcpy(person[5].town,"Minsk");
    person[5].avg = 8.9;
    strcpy(person[6].lastName,"Auchko");
    strcpy(person[6].town,"Minsk");
    person[6].avg = 9.1;
    strcpy(person[7].lastName,"Lazuta");
    strcpy(person[7].town,"Minsk");
    person[7].avg = 8.4;
    strcpy(person[8].lastName,"Kozko");
    strcpy(person[8].town,"Minsk");
    person[8].avg = 6.8;

    insertionSort(person, 9);
    int count = 0;
    for (int i = 0; i < 9; i++) {
       // printf("Last Name: %s| Town: %s| Mark: %.2f\n", person[i].lastName, person[i].town, person[i].avg);
        if (strcmp(person[i].town, "Minsk") == 0) {
            if (person[i].avg > 7.0) {
                printf("Last Name: %s| Town: %s| Mark: %.2f\n", person[i].lastName, person[i].town, person[i].avg);
                count++;
            }
        }
    }

    printf("Number of Applicants: %d\n", count);
    return 0;
}
