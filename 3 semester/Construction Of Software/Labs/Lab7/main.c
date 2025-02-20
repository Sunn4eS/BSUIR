#include <stdio.h>
#include <string.h>

struct Student {
    int groupNumber;
    char surname[20];
    int marks[5];
};

void readFromFile (struct Student *students, int *count) {
    const char* path = "C:\\Users\\User\\Desktop\\inputStudents.txt";
    FILE *fileRead = fopen(path, "r");
    if (fileRead == NULL) {
        printf("File could not be opened\n");
    } else {
        int index = 0;
        while ((fscanf(fileRead, "%d %s %d %d %d %d %d" , &students[index].groupNumber, &students[index].surname, &students[index].marks[0], &students[index].marks[1], &students[index].marks[2], &students[index].marks[3], &students[index].marks[4])) == 7) {
            index++;
        }
        *count = index;
    }
    fclose(fileRead);
}

float findAvg (struct Student *students) {
    float avg = (students->marks[0] + students->marks[1] + students->marks[2] + students->marks[3] + students->marks[4]) / 5.0;
    return avg;
}

void writeToFile (struct Student *students, int count) {
    const char* path = "C:\\Users\\User\\Desktop\\outputStudents.txt";
    FILE *fileWrite = fopen(path, "w");
    if (fileWrite == NULL) {
        printf("File could not be opened\n");
    } else {
        for (int i = 0; i < count; i++) {
            if (findAvg(&students[i]) > 8) {
                char* surname = students[i].surname;
                fwrite(surname, sizeof(char), strlen(surname), fileWrite);
                fwrite("\n", sizeof(char), 1, fileWrite);
            }
        }
    }
    fclose(fileWrite);
}

int main(void)
{
    struct Student students[10];
    int count = 0;
    readFromFile(students, &count);
    writeToFile(students, count);
    return 0;
}
