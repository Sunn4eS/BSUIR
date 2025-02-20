#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

#define RIGHT 'R'
#define LEFT 'L'
#define ROOT '+'
#define TRUE 1
#define FALSE 0
#define MAX_CHOICE 8
#define MIN_CHOICE 1

void setColor(int textColor, int bgColor) {
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    SetConsoleTextAttribute(hConsole, (bgColor << 4) | textColor);
}

enum chooseAction {
    addToTree = 1,
    drawTree,
    ARBTr,
    RABTr,
    ABRTr,
    firmwareF,
    delete,
    exitProg,


};

struct TreeNode {
    int data;
    struct TreeNode *left;
    struct TreeNode *right;
    struct TreeNode* next;
    int isFirmware;
};
struct TreeNode* y = NULL;

struct TreeNode* createNode(const int data) {
    struct TreeNode* node = (struct TreeNode*)malloc(sizeof(struct TreeNode));
    node->data = data;
    node->left = NULL;
    node->right = NULL;
    node->next = NULL;
    return node;
}

struct TreeNode* findLeaf(struct TreeNode* root, const int data) {
    if ((root == NULL) || (root->data == data)) {
        return root;
    } else if (root->data > data) {
        return findLeaf(root->left, data);

    } else {
        return findLeaf(root->right, data);
    }

}

struct TreeNode* insert(struct TreeNode* root, int data) {
    if (root == NULL) {
        root = createNode(data);
    } else {
        if (data < root->data){
            root->left = insert(root->left, data);
        } else {
            root->right = insert(root->right, data);
        }
    }
    return root;
}

void ARB(const struct TreeNode* root) {
    if (root == NULL) {
        setColor(7, 0);
        printf("%d ", 0);
        return;
    }
    setColor(7, 0);
    printf("%d ", root->data);
    ARB(root->left);


    setColor(3, 0);
    printf("%d ", root->data);


    ARB(root->right);
    setColor(7, 0);
    printf("%d ", root->data);

}

void RAB( const struct TreeNode* root) {
    if (root == NULL) {
        setColor(7, 0);
        printf("%d ", 0);
        return;
    }
    setColor(3, 0);
    printf("%d ", root->data);

    RAB(root->left);
    setColor(7, 0);
    printf("%d ", root->data);

    RAB(root->right);
    setColor(7, 0);
    printf("%d ", root->data);

}
void ABR(const struct TreeNode* root) {
    if (root == NULL) {
        setColor(7, 0);
        printf("%d ", 0);
        return;
    }

    setColor(7, 0);
    printf("%d ", root->data);
    ABR(root->left);

    setColor(7, 0);
    printf("%d ", root->data);
    ABR(root->right);

    setColor(3, 0);
    printf("%d ", root->data);
}


void printTree(const struct TreeNode* root,const int level,const char side) {
    if (root == NULL) {
        return;
    }
    if (root->right != NULL) {
        printTree(root->right, level+1, RIGHT);
    }
    for (int i = 0; i < level; i++) {
        printf("  ");
    }
        printf("(%c)%d", side, root->data);
    if (root->next != NULL) {
        printf("(%d)", root->next->data);
    }printf("\n");
    if (root->left != NULL) {
        printTree(root->left, level+1, LEFT);
    }

}

void findElement(struct TreeNode* root, struct TreeNode** parent, struct TreeNode** target, const int data) {
    *target = root;
    *parent = NULL;
    while ((*target != NULL) && ((*target)->data != data)) {
        *parent = target;
        if (data < (*target)->data) {
            *target = (*target)->left;
        } else {
            *target = (*target)->right;
        }
    }
}

struct TreeNode* deleteNode(struct TreeNode* root) {
    struct TreeNode* parent = NULL;
    struct TreeNode* target = NULL;
    int data;
    printf("Enter data fo deleting: ");
    scanf("%d", &data);
    findElement(root, &parent, &target, data);
    if (target == NULL) {
        return;
    }
    if ((target->left != NULL) && (target->right != NULL)) {
        struct TreeNode* minParent = target;
        struct TreeNode* min = target->right;
        while (min->left != NULL) {
            minParent = min;
            min = min->left;
        }
        target->data = min->data;

        if (minParent == target) {
            minParent->right = min->right;
        } else {
            minParent->left = min->right;
        }
        free(min);
    } else {
        struct TreeNode* child = NULL;
        if (target->left != NULL) {
            child = target->left;
        } else {
            child = target->right;
        }
        if (parent == NULL) {
            root = child;
        } else if (target == parent->left) {
            parent->left = child;
        } else {
            parent->right = child;
        }
        free(target);
    }
}

enum chooseAction getAction() {
    int action = 0;
    int isNotCorrect = TRUE;
    char buff = '1';
    do {
        printf("Please enter an action: ");
        scanf("%d", &action);
        isNotCorrect = ((action < MIN_CHOICE || action > MAX_CHOICE) && action != exitProg) || (buff = getchar()) != '\n';
        if (isNotCorrect) {
            printf("Error, enter again\n\n");
            while ((buff = getchar()) != '\n' && buff != EOF);
        }
    } while(isNotCorrect);
    return action;
}

struct TreeNode* getNewLeaf(struct TreeNode* root) {
    int newLeaf = 0;
    printf("Enter new leaf value: ");
    scanf("%d", &newLeaf);
    printf("\n");
    if (root == NULL) {
        root = createNode(newLeaf);
    } else if (findLeaf(root, newLeaf) == NULL) {
        root = insert(root, newLeaf);
    } else {
        printf("The new leaf is already exist\n");
    }
    return root;
}

struct TreeNode* copyTree(struct TreeNode* root) {
    if (root == NULL) {
        return NULL;
    }
    struct TreeNode* newNode = createNode(root->data);

    newNode->left = copyTree(root->left);
    newNode->right = copyTree(root->right);

    return newNode;
}

struct TreeNode* binaryFirmware(struct TreeNode* curr, struct TreeNode* prev) {
    if (curr == NULL) {
        return prev;
    }
    prev = binaryFirmware(curr->left, NULL);
    if (prev != NULL) {
        prev->next = curr;
    }
    prev = binaryFirmware(curr->right, curr);
    return prev;
}

void firmwareTree(struct TreeNode* root) {
    struct TreeNode* last = binaryFirmware(root, NULL);
    root->isFirmware = TRUE;
    last->next = root;
}



void printMenu (struct TreeNode* root) {

    enum chooseAction action;
    do {
        printf("1. Add new leaf\n ");
        printf("2. Draw tree\n ");
        printf("3. ARB\n ");
        printf("4. RAB\n ");
        printf("5. ABR\n ");
        printf("6. Firmaware\n ");
        printf("7. Delete element\n ");
        printf("8. Exit\n ");
        action = getAction();
        switch (action) {
            case addToTree:
                root = getNewLeaf(root);
                break;
            case drawTree:
                printTree(root, 0, ROOT);
                break;
            case ARBTr: //лево корень право
                ARB(root);
                printf("\n");
                setColor(7,0);
                break;
            case RABTr: //Корень лево право
                RAB(root);
                printf("\n");
                setColor(7,0);
                break;
            case ABRTr: //лево право корень
                ABR(root);
                printf("\n");
                setColor(7,0);
                break;
            case firmwareF:
                firmwareTree(root);

                break;
            case delete:
                deleteNode(root);
                printf("\n");

        }
    } while (action != exitProg);
}

int main(void)
{
    struct TreeNode* root = NULL;
    root = insert(root, 23);
    insert(root, 45);
    insert(root, 34);
    insert(root, 12);
    insert(root, 15);
    insert(root, 6);
    insert(root, 56);
    printMenu(root);
    return 0;
}
