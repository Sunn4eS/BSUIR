//
// Created by root on 17.10.2024.
//

#ifndef BINARYTREE_H
#define BINARYTREE_H

enum printType {
    preOrder = 1, // прямой
    inOrder = 2, // симметричный
    postOrder= 3 // обратный
};

struct node{
    int data;
    struct node* left;
    struct node* right;
    struct node* parent;
    struct node* next;
};

struct node node_create(int data, struct node*);

typedef struct {
    struct node* root;
    int isFirmware;
} binaryTree;

binaryTree binaryTree_create();
//public
int binaryTree_add(binaryTree *tree, int data);
int binaryTree_delete(binaryTree *tree, int data);
void binaryTree_printWithOrder(binaryTree *tree, enum printType);
void binaryTree_print(binaryTree*);
void binaryTree_firmware(binaryTree*);

struct node* private_binaryTree_findMinL(struct node*);

int private_binaryTree_deleteRoot(binaryTree* tree);
int private_binaryTree_deleteNode(struct node*, int);

void private_binaryTree_insertNode(struct node*, int);

void private_binaryTree_inOrder(struct node* curr);
void private_binaryTree_preOrder(struct node* curr);
void private_binaryTree_postOrder(struct node* curr);

void private_binaryTree_printNode(struct node* curr, int lvl);

#endif //BINARYTREE_H
