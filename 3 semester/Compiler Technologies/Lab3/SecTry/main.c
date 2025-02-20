#include <stdio.h>
#include <stdbool.h>

#define MAX 700

int lineno[MAX];
int column[MAX];

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
    IDLE
} lex;

const char *TypeStrings[] = { "NEXT", "SPACE", "STPROG", "ENDPROG", "PHP", "OPEN_BRACKET", "CLOSE_BRACKET", "OPEN_FIGURE", "CLOSE_FIGURE", "ECHO", "IF", "CONDITION", "ELSE", "WHILE", "LITTERAL", "SEMICOLON" };

int next = 0, count = 0;
int token[MAX];
int bestToken[MAX];
int error_line = 0;
int error_column = 0;
char* error_token = NULL;

void save_error_position() {
    error_line = lineno[next];
    error_column = column[next];
    error_token = TypeStrings[token[next]];
}

bool term(const lex expected) {

    if (token[next] != expected) {

        return false;
    }
    if ((error_line < lineno[next]) || (error_line == lineno[next] && error_column < column[next])) {
        save_error_position();
    }
    next++;
    return true;
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
        printf("Error at line %d, column %d after %s\n", error_line, error_column, error_token);
    }
    return res;
}

bool operator() {
    int save = next;
    if (echo()) {
        return true;
    }
    next = save;
    if (o_if()) {
        return true;
    }
    next = save;
    if (o_while()) {
        return true;
    }
    next = save;
    if (block()) {
        return true;
    }
    return false;
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
    if (!term(OPEN_FIGURE)) {
        res = false;
    }
    else {
        while (!current(CLOSE_FIGURE) && res) {
            if (!operator())
                res = false;
        }
        if (!term(CLOSE_FIGURE)) {
            res = false;
        }
    }

    return res;
}

void read() {
    int temp, line, col;
    char* path = "D:\\BSUIR\\Compiler Technologies\\Lab3\\SecTry\\init.txt";
    FILE *file = fopen(path, "r+t");
    fseek(file, 0, SEEK_SET);
    if (file == NULL) {
        perror("Ошибка при открытии файла");
    }
    while (fscanf(file, "%d %d %d", &temp, &line, &col) == 3) {
        if ((temp != SPACE) && (temp != NEXT)) {
            token[count] = temp;
            lineno[count] = line;
            column[count++] = col;
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
