#pragma once
#include <windows.h>

#define CELL_SIZE 30
#define MAP_WIDTH 20
#define MAP_HEIGHT 15

#define MOVE_SPEED 5 
#define FREEZE_DURATION 150  

struct Player {
    int gridX, gridY;
    int pixelX, pixelY;

    int targetX, targetY;

    int dirX, dirY;
    int nextDirX, nextDirY;
    int score;
    int lives;
    COLORREF color;

    int mouthOpen;
    bool mouthClosing;

    int freezeTimer;
};

extern int gameMap[MAP_HEIGHT][MAP_WIDTH];
extern Player pacman;
extern Player ghost;

void InitGame();
void DrawMap(HDC hdc);
void DrawPlayer(HDC hdc, Player& p);
void UpdatePlayer(Player& p);
bool CheckLocalCollision();
extern bool CanMove(int x, int y);
extern bool IsMapCleared();
void UpdateRemotePlayer(Player& p);
void CheckMapInteraction(Player& me, Player& enemy);