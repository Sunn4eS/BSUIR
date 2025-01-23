#include <stdio.h>
#include <stdlib.h>


struct Node {
    int data;
    struct Node* next;
};
struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->next = NULL;
    return newNode;
}


void append(struct Node** head_ref, int new_data) {
    struct Node* newNode = createNode(new_data);
    struct Node* last = *head_ref;

    if (*head_ref == NULL) {
        *head_ref = newNode;
        return;
    }

    while (last->next != NULL) {
        last = last->next;
    }

    last->next = newNode;
}
void insertEvenAfterOdd(struct Node** head_ref) {
    struct Node* current = *head_ref;
    struct Node* lastEven = NULL;

      while (current != NULL) {
        if (current->data % 2 == 0) {
            lastEven = current;
        }
        current = current->next;
    }

    if (lastEven == NULL) {
        printf("There is no even elements.\n");
        return;
    }

    current = *head_ref;

    while (current != NULL) {
        if (current->data % 2 != 0) {
            struct Node* temp = createNode(lastEven->data);
            temp->next = current->next;
            current->next = temp;
            current = temp->next;
        } else {
            current = current->next;
        }
    }
}

void printList(struct Node* node) {
    while (node != NULL) {
        printf("%d -> ", node->data);
        node = node->next;
    }
    printf("NULL\n");
}

int main() {
    struct Node* head = NULL;
    int choice;
    do {

        printf("1. Add Element\n");
        printf("2. Add last even Element\n");
        printf("3. Exit\n");
        scanf("%d", &choice);
        switch (choice) {
            case 1:
                printf("Enter element : ");
                int data;
                scanf("%d", &data);
                append(&head, data);
                printList(head);
                break;
            case 2:
                printf("Updated list: ");
                insertEvenAfterOdd(&head);
                printList(head);
                break;
            case 3:
                exit(0);

        }

    } while (choice != 3);


    return 0;
}

