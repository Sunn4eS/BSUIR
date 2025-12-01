#include "Game.h"
#include <math.h>

int gameMap[MAP_HEIGHT][MAP_WIDTH] = {
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,2,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,2,0,1}, 
    {1,0,1,1,1,0,1,1,0,1,0,1,1,0,1,1,1,1,0,1},
    {1,0,1,1,1,0,1,1,0,1,0,1,1,0,1,1,1,1,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,1,1,0,1,0,1,1,1,1,1,1,0,1,0,1,1,0,1},
    {1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,1},
    {1,1,1,1,0,1,1,1,0,1,0,1,1,1,1,0,1,1,1,1},
    {1,0,0,0,0,1,0,0,0,2,0,0,0,1,0,0,0,0,0,1}, 
    {1,0,1,1,0,1,0,1,1,9,9,1,1,0,1,0,1,1,0,1},
    {1,0,0,0,0,0,0,1,9,9,9,9,1,0,0,0,0,0,0,1},
    {1,0,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
};

Player pacman;
Player ghost;

void InitGame() {
    pacman.gridX = 1; pacman.gridY = 1;
    pacman.pixelX = 1 * CELL_SIZE; pacman.pixelY = 1 * CELL_SIZE;
    pacman.dirX = 0; pacman.dirY = 0;
    pacman.nextDirX = 0; pacman.nextDirY = 0;
    pacman.lives = 3; pacman.score = 0;
    pacman.color = RGB(255, 255, 0);
    pacman.freezeTimer = 0; 
    pacman.targetX = pacman.pixelX; 
    pacman.targetY = pacman.pixelY;

    ghost.gridX = 18; ghost.gridY = 12;
    ghost.pixelX = 18 * CELL_SIZE; ghost.pixelY = 12 * CELL_SIZE;
    ghost.dirX = 0; ghost.dirY = 0;
    ghost.lives = 0; ghost.score = 0;
    ghost.color = RGB(255, 0, 0);
    ghost.freezeTimer = 0; 
    ghost.targetX = ghost.pixelX; 
    ghost.targetY = ghost.pixelY;

    for (int y = 0; y < MAP_HEIGHT; y++)
        for (int x = 0; x < MAP_WIDTH; x++)
            if (gameMap[y][x] == 9 && y != 10) gameMap[y][x] = 0;

    gameMap[1][1] = 2;
    gameMap[1][17] = 2;
    gameMap[8][9] = 2;
}
bool CanMove(int x, int y) {
    if (x < 0 || x >= MAP_WIDTH || y < 0 || y >= MAP_HEIGHT) return false;
    return gameMap[y][x] != 1;
}

void UpdatePlayer(Player& p) {

    if (p.freezeTimer > 0) {
        p.freezeTimer--;
        return; 
    }
    if (p.mouthClosing) {
        p.mouthOpen -= 5;
        if (p.mouthOpen <= 0) { p.mouthOpen = 0; p.mouthClosing = false; }
    }
    else {
        p.mouthOpen += 5;
        if (p.mouthOpen >= 45) { p.mouthOpen = 45; p.mouthClosing = true; }
    }

    bool alignedX = (p.pixelX % CELL_SIZE == 0);
    bool alignedY = (p.pixelY % CELL_SIZE == 0);

    if (alignedX && alignedY) {
        p.gridX = p.pixelX / CELL_SIZE;
        p.gridY = p.pixelY / CELL_SIZE;

        if (p.nextDirX != 0 || p.nextDirY != 0) {
            if (CanMove(p.gridX + p.nextDirX, p.gridY + p.nextDirY)) {
                p.dirX = p.nextDirX;
                p.dirY = p.nextDirY;
                p.nextDirX = 0;
                p.nextDirY = 0;
            }
        }

        if (!CanMove(p.gridX + p.dirX, p.gridY + p.dirY)) {
            p.dirX = 0;
            p.dirY = 0;
            return;
        }

        if (p.color == RGB(255, 255, 0)) {
            if (gameMap[p.gridY][p.gridX] == 0) {
                gameMap[p.gridY][p.gridX] = 9;
                p.score += 10;
            }
        }
    }

    p.pixelX += p.dirX * MOVE_SPEED;
    p.pixelY += p.dirY * MOVE_SPEED;
}

void UpdatePacman() {
    UpdatePlayer(pacman);
}
void UpdateGhost() {
    UpdatePlayer(ghost);
}

bool CheckLocalCollision() {
    int dx = pacman.pixelX - ghost.pixelX;
    int dy = pacman.pixelY - ghost.pixelY;
    if (sqrt(dx * dx + dy * dy) < CELL_SIZE) {
        pacman.lives--;
        pacman.pixelX = 1 * CELL_SIZE; pacman.pixelY = 1 * CELL_SIZE;
        pacman.dirX = 0; pacman.dirY = 0;

        ghost.pixelX = 18 * CELL_SIZE; ghost.pixelY = 12 * CELL_SIZE;
        ghost.dirX = 0; ghost.dirY = 0;
        return true;
    }
    return false;
}

void DrawMap(HDC hdc) {
    HBRUSH hWall = CreateSolidBrush(RGB(0, 0, 150));
    HBRUSH hDot = CreateSolidBrush(RGB(255, 200, 200));
    HBRUSH hPower = CreateSolidBrush(RGB(255, 50, 255));  
    HBRUSH hOld = (HBRUSH)SelectObject(hdc, hWall);

    for (int y = 0; y < MAP_HEIGHT; y++) {
        for (int x = 0; x < MAP_WIDTH; x++) {
            RECT r = { x * CELL_SIZE, y * CELL_SIZE, (x + 1) * CELL_SIZE, (y + 1) * CELL_SIZE };
            if (gameMap[y][x] == 1) {
                SelectObject(hdc, hWall);
                Rectangle(hdc, r.left, r.top, r.right, r.bottom);
            }
            else if (gameMap[y][x] == 0) {
                SelectObject(hdc, hDot);
                Ellipse(hdc, r.left + 12, r.top + 12, r.right - 12, r.bottom - 12);
            }
            else if (gameMap[y][x] == 2) {
                SelectObject(hdc, hPower);
                Ellipse(hdc, r.left + 5, r.top + 5, r.right - 5, r.bottom - 5);
            }
        }
    }
    SelectObject(hdc, hOld);
    DeleteObject(hWall);
    DeleteObject(hDot);
    DeleteObject(hPower);
}
void DrawPlayer(HDC hdc, Player& p) {
    COLORREF drawColor = p.color;

    if (p.freezeTimer > 0) {
        if ((p.freezeTimer / 15) % 2 == 0)
            drawColor = RGB(50, 50, 255); 
        else
            drawColor = RGB(0, 0, 150);    
    }

    HBRUSH hBrush = CreateSolidBrush(drawColor);
    HBRUSH hOldBrush = (HBRUSH)SelectObject(hdc, hBrush);

    HPEN hPen = CreatePen(PS_NULL, 0, 0);
    HPEN hOldPen = (HPEN)SelectObject(hdc, hPen);

    int x = p.pixelX;
    int y = p.pixelY;
    int s = CELL_SIZE;

    if (p.color == RGB(255, 255, 0)) { 
        int cx = x + s / 2;
        int cy = y + s / 2;
        if (p.dirX == 0 && p.dirY == 0) {
            Pie(hdc, x, y, x + s, y + s, x + s, cy - 5, x + s, cy + 5);
        }
        else {
            double angle = 0;
            if (p.dirX == 1) angle = 0;
            if (p.dirX == -1) angle = 3.14159;
            if (p.dirY == 1) angle = 1.5707;
            if (p.dirY == -1) angle = 4.7123;
            double openRad = (p.mouthOpen) * (3.14159 / 180.0);
            int x1 = cx + (int)(cos(angle - openRad) * s);
            int y1 = cy + (int)(sin(angle - openRad) * s);
            int x2 = cx + (int)(cos(angle + openRad) * s);
            int y2 = cy + (int)(sin(angle + openRad) * s);
            Pie(hdc, x, y, x + s, y + s, x1, y1, x2, y2);
        }
    }
    else {
        Ellipse(hdc, x, y, x + s, y + s);
    }

    SelectObject(hdc, hOldPen);
    SelectObject(hdc, hOldBrush);
    DeleteObject(hPen);
    DeleteObject(hBrush);
}
bool IsMapCleared() {
    for (int y = 0; y < MAP_HEIGHT; y++) {
        for (int x = 0; x < MAP_WIDTH; x++) {
            if (gameMap[y][x] == 0) { 
                return false; 
            }
        }
    }
    return true; 
}

void UpdateRemotePlayer(Player& p) {
    float smoothFactor = 0.3f;

    int dx = p.targetX - p.pixelX;
    int dy = p.targetY - p.pixelY;

    if (abs(dx) > 100 || abs(dy) > 100) {
        p.pixelX = p.targetX;
        p.pixelY = p.targetY;
    }
    else {
        
        if (abs(dx) > 0) p.pixelX += (int)(dx * smoothFactor);
        if (abs(dy) > 0) p.pixelY += (int)(dy * smoothFactor);

        if (abs(p.targetX - p.pixelX) < 2) p.pixelX = p.targetX;
        if (abs(p.targetY - p.pixelY) < 2) p.pixelY = p.targetY;
    }

    
    if (p.mouthClosing) {
        p.mouthOpen -= 5;
        if (p.mouthOpen <= 0) { p.mouthOpen = 0; p.mouthClosing = false; }
    }
    else {
        p.mouthOpen += 5;
        if (p.mouthOpen >= 45) { p.mouthOpen = 45; p.mouthClosing = true; }
    }
}
void CheckMapInteraction(Player& me, Player& enemy) {
    int centerX = me.pixelX + CELL_SIZE / 2;
    int centerY = me.pixelY + CELL_SIZE / 2;

    int gridX = centerX / CELL_SIZE;
    int gridY = centerY / CELL_SIZE;

    if (gridX < 0 || gridX >= MAP_WIDTH || gridY < 0 || gridY >= MAP_HEIGHT) {
        return;
    }

    int content = gameMap[gridY][gridX];

    if (content == 9 || content == 1) {
        return;
    }

    int cellCenterX = gridX * CELL_SIZE + CELL_SIZE / 2;
    int cellCenterY = gridY * CELL_SIZE + CELL_SIZE / 2;

    int distance = abs(centerX - cellCenterX) + abs(centerY - cellCenterY);

    if (distance < 10) {
        if (content == 0) {
            gameMap[gridY][gridX] = 9;
            me.score += 10;
        }
        else if (content == 2) {
            gameMap[gridY][gridX] = 9;
            me.score += 50;
            enemy.freezeTimer = FREEZE_DURATION;
        }
    }
}