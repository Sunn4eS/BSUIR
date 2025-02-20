#include <stdio.h>
#include <stdbool.h>

#define MAX 500

bool operator();
bool echo();
bool o_if();
bool o_while();
bool block();

typedef enum Types {
    NEXT = 0,
    SPACE,
    STPROG,
    ENDPROG,
    PHP,
    OPEN_BRACKET,
    CLOSE_BRACKET,
    OPEN_FIGURE,
    CLOSE_FIGURE,
    ECHO,
    IF,
    CONDITION,
    ELSE,
    WHILE,
    LITTERAL,
    SEMICOLON,

} lex;

const char *TypeStrings[] = { "NEXT", "SPACE", "STPROG", "ENDPROG", "PHP", "OPEN_BRACKET", "CLOSE_BRACKET", "OPEN_FIGURE", "CLOSE_FIGURE", "ECHO", "IF", "CONDITION", "ELSE", "WHILE", "LITTERAL", "SEMICOLON" };

int next = 0, count = 0;
int token[MAX];

bool term(const lex expected) {
    return token[next++] == expected;
}
bool current(const lex expected) {
    return token[next] == expected;
}

bool start() {
    bool res = true;
    if (!term(STPROG))
        res = false;
    if (!term(PHP))
        res = false;
    while (!current(ENDPROG) && res) {
        if (!operator())
            res = false;
    }
    if (!term(ENDPROG)) {
        res = false;
    }
    if (!res) {
        printf("Error after %s\n",TypeStrings[token[next]]);
    }
    return res;
}

bool operator() {
    int save = next;
    return (next = save, echo()) ||
           (next = save, o_if()) ||
           (next = save, o_while()) ||
           (next = save, block());
}

bool echo() {
    return term(ECHO) &&
           term(LITTERAL) &&
           term(SEMICOLON);
}

bool o_if() {
    int save = next;
    return (next = save, term(IF) && term(OPEN_BRACKET) && term(CONDITION) && term (CLOSE_BRACKET) && block() && term(ELSE) && block()) ||
           (next = save, term(IF) && term(OPEN_BRACKET) && term(CONDITION) && term (CLOSE_BRACKET) && block());
}

bool o_while() {
    int save = next;
    return (next = save, term(WHILE) && term(OPEN_BRACKET) && term(CONDITION) && term (CLOSE_BRACKET) && block());
}

bool block() {
    bool res = true;
    if (!term(OPEN_FIGURE))
        res = false;
    while (!current(CLOSE_FIGURE) && res) {
        if (!operator())
            res = false;
    }

    if (!term(CLOSE_FIGURE))
        res = false;
    return res;
}

void read() {
    int temp;
    char* path = "D:\\BSUIR\\Compiler Technologies\\Lab3\\out.txt";
    FILE *file = fopen(path, "r+t");
    fseek(file, 0, SEEK_SET);
    if (file == NULL) {
        perror("Ошибка при открытии файла");
    }
    while (fscanf(file, "%d", &temp) == 1) {
        if ((temp != SPACE) && (temp != NEXT)) {
            token[count++] = temp;
        }
    }
    fclose(file);
}

int main(void)
{
    read();
    printf(start() ? "Accept\n" : "Reject\n");
    return 0;
}
