#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char surname[20];
    char branch[20];
    int salary;
    struct Person *next;
} Person;

Person* createPerson(char *surname, char *branch, int salary) {
    Person *newPerson = (Person *)malloc(sizeof(Person));
    if (newPerson != NULL) {
        strcpy(newPerson->surname, surname);
        strcpy(newPerson->branch, branch);
        newPerson->salary = salary;
        newPerson->next = NULL;
        return newPerson;
    } else {
        printf("Not enough space\n");
    }
}

void addPerson(struct Person **head, char *surname, char *branch, int salary) {
    Person *newPerson = createPerson(surname, branch, salary);
    if (*head == NULL) {

        *head = newPerson;
    } else {
        Person *temp = *head;
        while (temp->next != NULL) {
            temp = temp->next;
        }
        temp->next = newPerson;
    }
}

void readFromFile (struct Person **persons) {
    const char* path = "C:\\Users\\User\\Desktop\\input.txt";
    FILE *fileRead = fopen(path, "r");
    if (fileRead == NULL) {
        printf("File could not be opened\n");
    } else {
        char surname[20];
        char branch[20];
        int salary;
        while (fscanf(fileRead, "%s %s %d", surname, branch, &salary)==3) {
            addPerson(persons, surname, branch, salary);
        }
    }
    fclose(fileRead);
}
void writeToConsole (struct Person **persons) {
    Person *temp = *(persons);
    while (temp != NULL) {
        printf("%s ", temp->surname);
        printf("%s ", temp->branch);
        printf("%d\n", temp->salary);
        temp = temp->next;
    }
}



void writeToFile (struct Person **persons) {
    const char* path = "C:\\Users\\User\\Desktop\\input.txt";
    FILE *fileWrite = fopen(path, "w");
    if (fileWrite == NULL) {
        printf("File could not be opened\n");
    } else {
        Person *temp = *persons;
        while (temp != NULL) {
            char* surname = temp->surname;
            fwrite(surname, sizeof(char), strlen(surname), fileWrite);
            fwrite(" ", sizeof(char), 1, fileWrite);
            char* branch = temp->branch;
            fwrite(branch, sizeof(char), strlen(branch), fileWrite);
            fwrite(" ", sizeof(char), 1, fileWrite);
            int salary = temp->salary;
            fprintf(fileWrite, "%d", salary);
            fwrite("\n", sizeof(char), 1, fileWrite);
            temp = temp->next;
        }
    }
}

void deletePerson (struct Person **persons, char* surname) {
    Person *temp = *persons;
    Person *prev = NULL;
    if (strcmp(surname, temp->surname) == 0) {
        *persons = temp->next;
        free(temp);
    } else {
        while (temp != NULL && strcmp(surname, temp->surname) != 0) {
            prev = temp;
            temp = temp->next;
        }
        prev->next = temp->next;
        free(temp);
    }
}

void editSurname (struct Person **persons, char* surname) {
    Person *temp = *persons;
    while (temp != NULL) {
        if (strcmp(temp->surname, surname) == 0) {
            printf("Enter new Surname: ");
            scanf("%s", temp->surname);
            break;
        }
        temp = temp->next;
    }
}

void editBranch (struct Person **persons, char* surname) {
    Person *temp = *persons;
    while (temp != NULL) {
        if (strcmp(temp->surname, surname) == 0) {
            printf("Enter new branch: ");
            scanf("%s", temp->branch);
            break;
        }
        temp = temp->next;
    }
}

void editSalary (struct Person **persons, char* surname) {
    Person *temp = *persons;
    while (temp != NULL) {
        if (strcmp(temp->surname, surname) == 0) {
            printf("Enter new salary: ");
            scanf("%d", temp->salary);
            break;
        }
        temp = temp->next;
    }
}

void calculateSalary(struct Person **persons, char* branch) {
    Person *temp = *persons;
    int sum = 0;
    float avg = 0.0;
    int counter = 0;

    while (temp != NULL) {
        if (strcmp(temp->branch, branch) == 0) {
            counter++;
            sum += temp->salary;
        }
        temp = temp->next;
    }
    printf("The average salary is: %.2f\n", (float)sum / counter);
    printf("The sum of salary is: %d\n", sum);
}


int main(void)
{
    Person *head = NULL;
    int choice;
    do {
        readFromFile(&head);
        writeToConsole(&head);
        printf("1. Add Person\n");
        printf("2. Delete Person\n");
        printf("3. Edit Person\n");
        printf("4. Exit\n");
        printf("5. Sum and average in branch\n ");

        scanf("%d", &choice);
        switch (choice) {
            case 1:
                printf("Enter your surname: ");
                char surname[20];
                scanf("%s", surname);
                printf("Enter your branch: ");
                char branch[20];
                scanf("%s", branch);
                printf("Enter your salary: ");
                int salary;
                scanf("%d", &salary);
                addPerson(&head, surname, branch, salary);
                writeToFile(&head);

                break;
            case 2:
                printf("Enter your surname: ");
                scanf("%s", surname);
                deletePerson(&head, surname);
                break;
            case 3:

                printf("Enter your surname: ");
                scanf("%s", surname);
                printf("What you want to edit:\n");
                printf("1. Edit Surname\n");
                printf("2. Edit Branch\n");
                printf("3. Edit Salary\n");
                printf("4. Exit\n");
                int choice_e;
                scanf("%d", &choice_e);
                switch (choice_e) {
                    case 1:
                        editSurname(&head, surname);
                        writeToFile(&head);
                        break;
                    case 2:
                        editBranch(&head, surname);
                        writeToFile(&head);
                    break;
                    case 3:
                        editSalary(&head, surname);
                        writeToFile(&head);
                        break;
                }
                break;
            case 5:
                printf("Enter branch: ");
                scanf("%s", branch);
                calculateSalary(&head, branch);
                break;
        }
        writeToFile(&head);
    } while (choice != 4);
    return 0;
}
