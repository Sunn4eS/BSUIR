//
// Created by root on 17.10.2024.
//

#include <stdlib.h>
#include "BinaryTree.h"

#include <stdio.h>

struct node node_create(const int data, struct node* parent) {
    return (struct node){data, NULL,NULL, parent, NULL};;
}

binaryTree binaryTree_create() {
    return (binaryTree){NULL, 0};
}

int binaryTree_add(binaryTree *tree, int data) {
    if (tree->root == NULL) {
        tree->root = (struct node*)malloc(sizeof(struct node));
        *tree->root = node_create(data, NULL);
    } else {
        private_binaryTree_insertNode(tree->root, data);
    }
    return 1;
}

void private_binaryTree_insertNode(struct node* curr, int data) {
    if (data > curr->data) {
        if (curr->right == NULL) {
            curr->right = (struct node*)malloc(sizeof(struct node));
            *curr->right = node_create(data, curr);
        } else {
            private_binaryTree_insertNode(curr->right, data);
        }
    } else if (data < curr->data) {
        if (curr->left == NULL) {
            curr->left = (struct node*)malloc(sizeof(struct node));
            *curr->left = node_create(data, curr);
        } else {
            private_binaryTree_insertNode(curr->left, data);
        }
    }
}

struct node* private_binaryTree_findMinL(struct node* curr) {
    if (curr->left == NULL) {
        return curr;
    } else {
        return private_binaryTree_findMinL(curr->left);
    }
}

int private_binaryTree_deleteNode(struct node* curr, int data) {
    if (curr->data == data) {
        if (curr->right == NULL && curr->left == NULL) {
            struct node* parent = curr->parent;
            if (curr == parent->left) {
                free(parent->left);
                parent->left = NULL;
            } else {
                free(parent->right);
                parent->right = NULL;
            }
            return 1;
        }
        if (curr->left == NULL && curr->right != NULL) {
            if (curr == curr->parent->left) {
                curr->parent->left = curr->right;
                free(curr);
            } else {
                curr->parent->right = curr->right;
                free(curr);
            }
            return 1;
        }
        if (curr->left != NULL && curr->right == NULL) {
            if (curr == curr->parent->left) {
                curr->parent->left = curr->left;
                free(curr);
            } else {
                curr->parent->right = curr->left;
                free(curr);
            }
            return 1;
        }
        if (curr->left != NULL && curr->right != NULL) {
            struct node* temp = private_binaryTree_findMinL(curr->right);
            curr->data = temp->data;
            private_binaryTree_deleteNode(curr->right, temp->data);
            return 1;
        }
    }
    if (data < curr->data) {
        if (curr->left != NULL) {
            return private_binaryTree_deleteNode(curr->left, data);
        } else {
            return 0;
        }
    } else {
        if (curr->right != NULL) {
            return private_binaryTree_deleteNode(curr->right, data);
        } else {
            return 0;
        }
    }
}

int private_binaryTree_deleteRoot(binaryTree* tree) {
    if (tree->root->right != NULL) {
        struct node* temp = private_binaryTree_findMinL(tree->root->right);
        tree->root->data = temp->data;
        private_binaryTree_deleteNode(tree->root->right, temp->data);
        return 1;
    }
    if (tree->root->left != NULL) {
        struct node* temp = tree->root->left;
        free(tree->root);
        tree->root = temp;
        tree->root->parent = NULL;
        return 1;
    }
    free(tree->root);
    tree->root = NULL;
    return 1;
}

int binaryTree_delete(binaryTree *tree, int data) {
    if (tree->root == NULL) {
        return 0;
    }
    if (tree->root->data == data) {
        return private_binaryTree_deleteRoot(tree);
    }
    int isDeleted = private_binaryTree_deleteNode(tree->root, data);
    if (tree->isFirmware) {
        binaryTree_firmware(tree);
    }
    return isDeleted;
}

void private_binaryTree_inOrder(struct node* curr) {
    if (curr == NULL) {
        printf(" | NULL ");
        return;
    }
    printf("| %d ", curr->data);
    private_binaryTree_inOrder(curr->left);
    printf("| (%d) ", curr->data);
    private_binaryTree_inOrder(curr->right);
    printf("| %d ", curr->data);
}
void private_binaryTree_preOrder(struct node* curr) {
    if (curr == NULL) {
        printf(" | NULL ");
        return;
    }
    printf("| (%d) ", curr->data);
    private_binaryTree_preOrder(curr->left);
    printf("| %d ", curr->data);
    private_binaryTree_preOrder(curr->right);
    printf("| %d ", curr->data);
}
void private_binaryTree_postOrder(struct node* curr) {
    if (curr == NULL) {
        printf(" | NULL ");
        return;
    }
    printf("| %d ", curr->data);
    private_binaryTree_postOrder(curr->left);
    printf("| %d ", curr->data);
    private_binaryTree_postOrder(curr->right);
    printf("| (%d) ", curr->data);
}

void binaryTree_printWithOrder(binaryTree *tree, enum printType type) {
    if (type == inOrder) {
        private_binaryTree_inOrder(tree->root);
    } else if (type == preOrder) {
        private_binaryTree_preOrder(tree->root);
    } else {
        private_binaryTree_postOrder(tree->root);
    }
    printf("\n\n");
}

void private_binaryTree_printNode(struct node* curr, int lvl) {
    if (curr == NULL) {
        return;
    }
    int coof = 5;
    int size = coof + lvl*coof;



    private_binaryTree_printNode(curr->right, lvl + 1);


   // if (curr->right != NULL) {
        for (int i = 0; i < size-1; i++) {
            printf(" ");
        }
        printf("|");
    //}
    for (int i = 0; i < coof-1; i++) {
        printf("-");
    }

    printf("%d", curr->data);
    if (curr->next != NULL) {
        printf("(%d)", curr->next->data);
    }printf("\n");
    private_binaryTree_printNode(curr->left, lvl + 1);
}

void binaryTree_print(binaryTree* tree) {
    private_binaryTree_printNode(tree->root, 0);
}

struct node* private_binaryTree_firmwareNode(struct node* curr, struct node* prev) {
    if (curr == NULL) {
        return prev;
    }
    prev = private_binaryTree_firmwareNode(curr->left, NULL);

    if (prev != NULL) {
        prev->next = curr;
    }

    prev = private_binaryTree_firmwareNode(curr->right, curr);
    return prev;
}

void binaryTree_firmware(binaryTree* tree) {
    struct node* lastNode = private_binaryTree_firmwareNode(tree->root, NULL);
    tree->isFirmware = 1;
    lastNode->next = tree->root;
}