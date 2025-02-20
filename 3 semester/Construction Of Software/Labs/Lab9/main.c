#include <stdio.h>
#include <stdlib.h>


struct StackNode {
    int data;
    struct StackNode* next;
};

struct StackNode* createNode(int data) {
    struct StackNode* newNode = (struct StackNode*)malloc(sizeof(struct StackNode));
    newNode->data = data;
    newNode->next = NULL;
    return newNode;
}

int isEmpty(struct StackNode* root) {
    return !root;
}

void push(struct StackNode** root, int data) {
    struct StackNode* newNode = createNode(data);
    newNode->next = *root;
    *root = newNode;
}

int pop(struct StackNode** root) {
    if (isEmpty(*root))
        return -1;
    struct StackNode* temp = *root;
    *root = (*root)->next;
    int popped = temp->data;
    free(temp);
    return popped;
}

void mergeStacks(struct StackNode** stack1, struct StackNode** stack2, struct StackNode** mergedStack) {
    struct StackNode *tempStack1 = NULL, *tempStack2 = NULL;

    while (!isEmpty(*stack1)) {
        push(&tempStack1, pop(stack1));
    }
    while (!isEmpty(*stack2)) {
        push(&tempStack2, pop(stack2));
    }

    while (!isEmpty(tempStack1) && !isEmpty(tempStack2)) {
        if (tempStack1->data < tempStack2->data) {
            push(mergedStack, pop(&tempStack1));
        } else {
            push(mergedStack, pop(&tempStack2));
        }
    }

    while (!isEmpty(tempStack1)) {
        push(mergedStack, pop(&tempStack1));
    }

    while (!isEmpty(tempStack2)) {
        push(mergedStack, pop(&tempStack2));
    }
}

void printStack(struct StackNode* root) {
    while (root) {
        printf("%d -> ", root->data);
        root = root->next;
    }
    printf("NULL\n");
}

int main() {
    struct StackNode* stack1 = NULL;
    struct StackNode* stack2 = NULL;
    struct StackNode* mergedStack = NULL;

    push(&stack1, 1);
    push(&stack1, 3);
    push(&stack1, 5);
    push(&stack1, 7);
    push(&stack1, 9);

    push(&stack2, 2);
    push(&stack2, 4);
    push(&stack2, 5);
    push(&stack2, 6);

    printf("First Stack: ");
    printStack(stack1);

    printf("Second Stack: ");
    printStack(stack2);

    mergeStacks(&stack1, &stack2, &mergedStack);

    printf("Merged Stack: ");
    printStack(mergedStack);

    return 0;
}
