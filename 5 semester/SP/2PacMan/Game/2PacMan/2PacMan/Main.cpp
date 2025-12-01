#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <string>
#include "Game.h"
#include "Network.h"

#pragma comment(lib, "msimg32.lib")  

enum GameState {
    MENU,
    GAME_LOCAL,
    NETWORK_SELECT,
    INPUT_IP,
    LOBBY_WAIT,
    ROLE_SELECT,
    READY_WAIT,
    GAME_NET,
    GAME_WIN,
    GAME_LOSE
};

std::string inputIP = "192.168.0.";

GameState currentState = MENU;

int myRole = 0;
bool amIReady = false;
bool remoteReady = false;

void StartNetworkGame() {
    InitGame();
    amIReady = false;
    remoteReady = false;
}

void DrawNetworkMenu(HDC hdc, int w, int h) {
    RECT rect = { 0, 0, w, h };
    HBRUSH hBr = CreateSolidBrush(RGB(20, 20, 20));
    FillRect(hdc, &rect, hBr);
    DeleteObject(hBr);

    SetBkMode(hdc, TRANSPARENT);
    SetTextColor(hdc, RGB(255, 255, 255));

    std::wstring text = L"";

    if (currentState == NETWORK_SELECT) {
        text = L"=== NETWORK MODE ===\n\n1. Host Game (Server)\n2. Join Game (Client)\n\nESC - Back";
    }
    else if (currentState == LOBBY_WAIT) {
        std::string myIP = GetLocalIPAddress();
        std::wstring wIP(myIP.begin(), myIP.end());
        text = L"LOBBY CREATED\n\nTell this IP to your friend:\n" + wIP +
            L"\n\nWaiting for connection...";
    }
    else if (currentState == INPUT_IP) {
        std::wstring wInput(inputIP.begin(), inputIP.end());
        text = L"ENTER SERVER IP ADDRESS:\n\n" + wInput +
            L"_\n\n(Type numbers and dots)\nPress ENTER to Connect\nESC to Back";
    }
    else if (currentState == ROLE_SELECT) {
        text = L"CONNECTED!\n\nChoose Role:\n[1] PACMAN\n[2] GHOST";
    }
    else if (currentState == READY_WAIT) {
        std::wstring roleStr = (myRole == 1) ? L"PACMAN" : L"GHOST";
        text = L"You are: " + roleStr + L"\n\n" +
            (amIReady ? L"YOU: READY\n" : L"YOU: Wait (Press R)\n") +
            (remoteReady ? L"OPP: READY" : L"OPP: Wait");
    }

    DrawTextW(hdc, text.c_str(), -1, &rect, DT_CENTER | DT_VCENTER);
}

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;

void DrawMenu(HDC hdc, int width, int height) {
    RECT rect = { 0, 0, width, height };
    HBRUSH hBrush = CreateSolidBrush(RGB(0, 0, 0));
    FillRect(hdc, &rect, hBrush);
    DeleteObject(hBrush);

    SetBkMode(hdc, TRANSPARENT);

    HFONT hFontTitle = CreateFont(48, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE, DEFAULT_CHARSET,
        OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
        DEFAULT_PITCH | FF_SWISS, L"Arial");
    HFONT hOldFont = (HFONT)SelectObject(hdc, hFontTitle);
    SetTextColor(hdc, RGB(255, 255, 0));

    RECT titleRect = { 0, 50, width, 150 };
    DrawTextW(hdc, L"PAC-MAN", -1, &titleRect, DT_CENTER | DT_VCENTER | DT_SINGLELINE);

    HFONT hFontItem = CreateFont(24, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, DEFAULT_CHARSET,
        OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
        DEFAULT_PITCH | FF_SWISS, L"Arial");
    SelectObject(hdc, hFontItem);
    SetTextColor(hdc, RGB(255, 255, 255));

    RECT itemRect = { 0, 200, width, 400 };
    std::wstring menuText = L"1. Local Game (1 PC)\n\n2. Network Game (TCP)";
    DrawTextW(hdc, menuText.c_str(), -1, &itemRect, DT_CENTER);

    SetTextColor(hdc, RGB(150, 150, 150));
    RECT footerRect = { 0, height - 50, width, height };
    DrawTextW(hdc, L"Press '1' or '2' to select", -1, &footerRect, DT_CENTER | DT_SINGLELINE);

    SelectObject(hdc, hOldFont);
    DeleteObject(hFontTitle);
    DeleteObject(hFontItem);
}

void DrawGamePlaceholder(HDC hdc, int width, int height, std::wstring text) {
    RECT rect = { 0, 0, width, height };
    FillRect(hdc, &rect, (HBRUSH)GetStockObject(DKGRAY_BRUSH));
    SetBkMode(hdc, TRANSPARENT);
    SetTextColor(hdc, RGB(255, 255, 255));
    DrawTextW(hdc, text.c_str(), -1, &rect, DT_CENTER | DT_VCENTER | DT_SINGLELINE);
}


LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    static HDC hdcMem;
    static HBITMAP hbmMem;
    static int clientW, clientH;

    switch (message) {
    case WM_CHAR:
        if (currentState == INPUT_IP) {
            if (wParam == VK_BACK) {
                if (!inputIP.empty()) inputIP.pop_back();
            }
            else if ((wParam >= '0' && wParam <= '9') || wParam == '.') {
                if (inputIP.length() < 15) {
                    inputIP += (char)wParam;
                }
            }
            InvalidateRect(hWnd, NULL, FALSE);
        }
        return 0;

    case WM_CREATE:
        InitWinsock();
        SetTimer(hWnd, 1, 30, NULL);
        return 0;

    case WM_SIZE:
    {
        RECT rc;
        GetClientRect(hWnd, &rc);
        clientW = rc.right - rc.left;
        clientH = rc.bottom - rc.top;
        if (hbmMem) DeleteObject(hbmMem);
        hbmMem = NULL;
    }
    return 0;

    case WM_TIMER:
    {
        if (currentState == LOBBY_WAIT) {
            SOCKET client = accept(connectSocket, NULL, NULL);
            if (client != INVALID_SOCKET) {
                closesocket(connectSocket);
                connectSocket = client;

                int flag = 1;
                setsockopt(connectSocket, IPPROTO_TCP, TCP_NODELAY, (char*)&flag, sizeof(int));

                isConnected = true;
                currentState = ROLE_SELECT;
                InvalidateRect(hWnd, NULL, FALSE);
            }
        }

        if (currentState == ROLE_SELECT || currentState == READY_WAIT) {
            GamePacket p;
            while (ReceiveGamePacket(p)) {
                if (p.type == PKT_INIT) {
                    if (currentState == ROLE_SELECT) {
                        if (p.role == 1) myRole = 2;
                        else myRole = 1;
                        currentState = READY_WAIT;
                        amIReady = false; remoteReady = false;
                        InvalidateRect(hWnd, NULL, FALSE);
                    }
                }
                if (p.type == PKT_READY) {
                    remoteReady = true;
                    if (amIReady && remoteReady) {
                        StartNetworkGame();
                        currentState = GAME_NET;
                        InvalidateRect(hWnd, NULL, FALSE);
                    }
                }
            }
        }

        if (currentState == GAME_NET) {
            Player* me = (myRole == 1) ? &pacman : &ghost;
            Player* enemy = (myRole == 1) ? &ghost : &pacman;

            UpdatePlayer(*me);
            me->targetX = me->pixelX;
            me->targetY = me->pixelY;

            if (enemy->freezeTimer > 0) enemy->freezeTimer--;

            UpdateRemotePlayer(*enemy);

            int eatenX = -1;
            int eatenY = -1;
            bool isPower = false;

            if (myRole == 1) {
                int cx = me->pixelX / CELL_SIZE;
                int cy = me->pixelY / CELL_SIZE;

                if (me->pixelX % CELL_SIZE == 0 && me->pixelY % CELL_SIZE == 0) {
                    int content = gameMap[cy][cx];

                    if (content == 0 || content == 2) {
                        gameMap[cy][cx] = 9;
                        me->score += 10;

                        eatenX = cx;
                        eatenY = cy;

                        if (content == 2) {
                            isPower = true;
                            enemy->freezeTimer = FREEZE_DURATION;
                        }
                    }
                }

                if (IsMapCleared()) {
                    currentState = GAME_WIN;
                    GamePacket p; p.type = PKT_GAME_OVER; p.winner = 1;
                    SendGamePacket(p);
                    InvalidateRect(hWnd, NULL, FALSE);
                    return 0;
                }
            }

            GamePacket outPkt;
            outPkt.type = PKT_GAME_DATA;
            outPkt.x = me->pixelX;
            outPkt.y = me->pixelY;
            outPkt.dirX = me->dirX;
            outPkt.dirY = me->dirY;
            outPkt.score = pacman.score;
            outPkt.lives = pacman.lives;
            outPkt.role = myRole;
            outPkt.eatenX = eatenX;
            outPkt.eatenY = eatenY;
            outPkt.powerPellet = isPower;

            SendGamePacket(outPkt);

            GamePacket inPkt;
            while (ReceiveGamePacket(inPkt)) {
                if (inPkt.type == PKT_GAME_DATA) {
                    enemy->targetX = inPkt.x;
                    enemy->targetY = inPkt.y;

                    enemy->dirX = inPkt.dirX;
                    enemy->dirY = inPkt.dirY;

                    if (myRole == 2) {
                        pacman.score = inPkt.score;
                        pacman.lives = inPkt.lives;
                        if (inPkt.eatenX != -1) gameMap[inPkt.eatenY][inPkt.eatenX] = 9;
                        if (inPkt.powerPellet) me->freezeTimer = FREEZE_DURATION;
                    }
                }
                else if (inPkt.type == PKT_GAME_OVER) {
                    if (inPkt.winner == myRole) currentState = GAME_WIN;
                    else currentState = GAME_LOSE;
                    InvalidateRect(hWnd, NULL, FALSE);
                    return 0;
                }
            }

            int dx = pacman.pixelX - ghost.pixelX;
            int dy = pacman.pixelY - ghost.pixelY;
            if ((dx * dx + dy * dy) < 900) {
                if (myRole == 1) {
                    pacman.lives--;

                    pacman.pixelX = 1 * CELL_SIZE; pacman.pixelY = 1 * CELL_SIZE;
                    pacman.dirX = 0; pacman.dirY = 0; pacman.nextDirX = 0; pacman.nextDirY = 0;
                    ghost.pixelX = 18 * CELL_SIZE; ghost.pixelY = 12 * CELL_SIZE;
                    ghost.dirX = 0; ghost.dirY = 0; ghost.nextDirX = 0; ghost.nextDirY = 0;

                    if (pacman.lives <= 0) {
                        currentState = GAME_LOSE;

                        GamePacket p;
                        p.type = PKT_GAME_OVER;
                        p.winner = 2;
                        SendGamePacket(p);
                    }
                }
            }
            InvalidateRect(hWnd, NULL, FALSE);
        }


        // 4. ЛОКАЛЬНАЯ ИГРА
        if (currentState == GAME_LOCAL) {
            // 1. Двигаем обоих игроков
            // Функция UpdatePlayer сама проверит стены и заморозку (freezeTimer)
            UpdatePlayer(pacman);
            UpdatePlayer(ghost);

            // 2. Проверяем взаимодействие Пакмана с картой (еда и таблетки)
            // Эта функция съест точку, добавит очки и ЗАМОРОЗИТ призрака, если это таблетка
            CheckMapInteraction(pacman, ghost);

            // 3. Проверка условия победы (если все точки съедены)
            if (IsMapCleared()) {
                currentState = GAME_WIN;
                InvalidateRect(hWnd, NULL, FALSE);
                return 0;
            }

            // 4. Проверка столкновения (Коллизия)
            // Проверяем, только если Призрак НЕ ЗАМОРОЖЕН
            if (ghost.freezeTimer == 0) {
                if (CheckLocalCollision()) {
                    // Если жизни кончились - Game Over
                    if (pacman.lives <= 0) {
                        currentState = GAME_LOSE;
                    }
                }
            }

            InvalidateRect(hWnd, NULL, FALSE);
        }
    }
    case WM_KEYDOWN:
        if (currentState == MENU) {
            if (wParam == '1') { InitGame(); currentState = GAME_LOCAL; }
            if (wParam == '2') { currentState = NETWORK_SELECT; }
            InvalidateRect(hWnd, NULL, FALSE);
        }
        else if (currentState == NETWORK_SELECT) {
            if (wParam == '1') {
                if (StartServer()) currentState = LOBBY_WAIT;
            }
            if (wParam == '2') {
                currentState = INPUT_IP;
                inputIP = "";
            }
            InvalidateRect(hWnd, NULL, FALSE);
        }
        else if (currentState == INPUT_IP) {
            if (wParam == VK_RETURN) {
                if (ConnectToServer(inputIP.c_str())) {
                    currentState = ROLE_SELECT;
                }
                else {
                    MessageBox(hWnd, L"Connection Failed!\nCheck IP and Firewall.", L"Error", MB_OK);
                }
            }
            if (wParam == VK_ESCAPE) currentState = NETWORK_SELECT;
        }
        else if (currentState == ROLE_SELECT) {
            if (wParam == '1') myRole = 1;
            if (wParam == '2') myRole = 2;

            if (myRole != 0) {
                GamePacket p;
                p.type = PKT_INIT;
                p.role = myRole;
                SendGamePacket(p);

                currentState = READY_WAIT;
                amIReady = false;
                remoteReady = false;

                InvalidateRect(hWnd, NULL, FALSE);
            }
        }
        else if (currentState == READY_WAIT) {
            if (wParam == 'R') {
                amIReady = true;
                GamePacket p; p.type = PKT_READY;
                SendGamePacket(p);
                if (amIReady && remoteReady) {
                    StartNetworkGame();
                    currentState = GAME_NET;
                }
                InvalidateRect(hWnd, NULL, FALSE);
            }
        }
        else if (currentState == GAME_NET) {
            Player* me = (myRole == 1) ? &pacman : &ghost;

            if (myRole == 1) {
                if (wParam == VK_UP) { me->nextDirX = 0; me->nextDirY = -1; }
                if (wParam == VK_DOWN) { me->nextDirX = 0; me->nextDirY = 1; }
                if (wParam == VK_LEFT) { me->nextDirX = -1; me->nextDirY = 0; }
                if (wParam == VK_RIGHT) { me->nextDirX = 1; me->nextDirY = 0; }
            }
            else {
                if (wParam == 'W') { me->nextDirX = 0; me->nextDirY = -1; }
                if (wParam == 'S') { me->nextDirX = 0; me->nextDirY = 1; }
                if (wParam == 'A') { me->nextDirX = -1; me->nextDirY = 0; }
                if (wParam == 'D') { me->nextDirX = 1; me->nextDirY = 0; }
            }
        }
        else if (currentState == GAME_LOCAL) {
            if (wParam == VK_UP) { pacman.nextDirX = 0; pacman.nextDirY = -1; }
            if (wParam == VK_DOWN) { pacman.nextDirX = 0; pacman.nextDirY = 1; }
            if (wParam == VK_LEFT) { pacman.nextDirX = -1; pacman.nextDirY = 0; }
            if (wParam == VK_RIGHT) { pacman.nextDirX = 1; pacman.nextDirY = 0; }

            if (wParam == 'W') { ghost.nextDirX = 0; ghost.nextDirY = -1; }
            if (wParam == 'S') { ghost.nextDirX = 0; ghost.nextDirY = 1; }
            if (wParam == 'A') { ghost.nextDirX = -1; ghost.nextDirY = 0; }
            if (wParam == 'D') { ghost.nextDirX = 1; ghost.nextDirY = 0; }

            if (wParam == VK_ESCAPE) {
                currentState = MENU;
                InvalidateRect(hWnd, NULL, FALSE);
            }
        }
        else if (currentState == GAME_WIN || currentState == GAME_LOSE) {
            if (wParam == VK_SPACE) {
                currentState = MENU;
                CleanupNetwork();
                InitWinsock();
                InvalidateRect(hWnd, NULL, FALSE);
            }
        }
        return 0;
case WM_PAINT:
{
    PAINTSTRUCT ps;
    HDC hdc = BeginPaint(hWnd, &ps);

    if (!hdcMem) hdcMem = CreateCompatibleDC(hdc);
    if (!hbmMem) hbmMem = CreateCompatibleBitmap(hdc, clientW, clientH);
    HBITMAP hbmOld = (HBITMAP)SelectObject(hdcMem, hbmMem);

    RECT r = { 0, 0, clientW, clientH };
    FillRect(hdcMem, &r, (HBRUSH)GetStockObject(BLACK_BRUSH));

    if (currentState == MENU) {
        DrawMenu(hdcMem, clientW, clientH);
    }
    else if (currentState == GAME_LOCAL || currentState == GAME_NET) {
        DrawMap(hdcMem);
        DrawPlayer(hdcMem, pacman);
        DrawPlayer(hdcMem, ghost);

        HFONT hFontScore = CreateFont(24, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE, DEFAULT_CHARSET,
            OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
            DEFAULT_PITCH | FF_SWISS, L"Verdana");
        HFONT hOldFont = (HFONT)SelectObject(hdcMem, hFontScore);

        SetBkMode(hdcMem, TRANSPARENT);
        SetTextColor(hdcMem, RGB(255, 255, 255));

        std::wstring scoreText = L"SCORE: " + std::to_wstring(pacman.score) +
            L"   LIVES: " + std::to_wstring(pacman.lives);

        if (currentState == GAME_NET) {
            scoreText += (myRole == 1 ? L"  (You: PACMAN)" : L"  (You: GHOST)");
        }

        TextOutW(hdcMem, 10, MAP_HEIGHT * CELL_SIZE + 10, scoreText.c_str(), scoreText.length());

        SelectObject(hdcMem, hOldFont);
        DeleteObject(hFontScore);
    }
    else if (currentState == GAME_WIN) {
        RECT r = { 0, 0, clientW, clientH };
        SetBkMode(hdcMem, TRANSPARENT);

        HBRUSH hBr = CreateSolidBrush(RGB(0, 50, 0));
        FillRect(hdcMem, &r, hBr); DeleteObject(hBr);

        SetTextColor(hdcMem, RGB(0, 255, 0));
        HFONT hBig = CreateFont(60, 0, 0, 0, FW_BOLD, 0, 0, 0, 0, 0, 0, 0, 0, L"Arial");
        SelectObject(hdcMem, hBig);
        DrawTextW(hdcMem, L"YOU WIN!", -1, &r, DT_CENTER | DT_VCENTER | DT_SINGLELINE);

        RECT r2 = { 0, clientH / 2 + 50, clientW, clientH };
        HFONT hSmall = CreateFont(20, 0, 0, 0, FW_NORMAL, 0, 0, 0, 0, 0, 0, 0, 0, L"Arial");
        SelectObject(hdcMem, hSmall);
        SetTextColor(hdcMem, RGB(200, 255, 200));
        DrawTextW(hdcMem, L"Press SPACE to return to Menu", -1, &r2, DT_CENTER);

        DeleteObject(hBig); DeleteObject(hSmall);
    }
    else if (currentState == GAME_LOSE) {
        RECT r = { 0, 0, clientW, clientH };
        SetBkMode(hdcMem, TRANSPARENT);

        HBRUSH hBr = CreateSolidBrush(RGB(50, 0, 0));
        FillRect(hdcMem, &r, hBr); DeleteObject(hBr);

        SetTextColor(hdcMem, RGB(255, 0, 0));
        HFONT hBig = CreateFont(60, 0, 0, 0, FW_BOLD, 0, 0, 0, 0, 0, 0, 0, 0, L"Arial");
        SelectObject(hdcMem, hBig);
        DrawTextW(hdcMem, L"GAME OVER", -1, &r, DT_CENTER | DT_VCENTER | DT_SINGLELINE);

        RECT r2 = { 0, clientH / 2 + 50, clientW, clientH };
        HFONT hSmall = CreateFont(20, 0, 0, 0, FW_NORMAL, 0, 0, 0, 0, 0, 0, 0, 0, L"Arial");
        SelectObject(hdcMem, hSmall);
        SetTextColor(hdcMem, RGB(255, 200, 200));
        DrawTextW(hdcMem, L"Press SPACE to return to Menu", -1, &r2, DT_CENTER);

        DeleteObject(hBig); DeleteObject(hSmall);
    }
    else {
        DrawNetworkMenu(hdcMem, clientW, clientH);
    }

    BitBlt(hdc, 0, 0, clientW, clientH, hdcMem, 0, 0, SRCCOPY);
    SelectObject(hdcMem, hbmOld);
    EndPaint(hWnd, &ps);
}
return 0;

case WM_DESTROY:
    CleanupNetwork();
    KillTimer(hWnd, 1);
    if (hdcMem) DeleteDC(hdcMem);
    if (hbmMem) DeleteObject(hbmMem);
    PostQuitMessage(0);
    return 0;
}
return DefWindowProc(hWnd, message, wParam, lParam);
}



int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nCmdShow) {
    WNDCLASSEXW wcex = { 0 };
    wcex.cbSize = sizeof(WNDCLASSEX);
    wcex.style = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc = WndProc;
    wcex.hInstance = hInstance;
    wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
    wcex.lpszClassName = L"PacmanGameClass";

    RegisterClassExW(&wcex);

    RECT winRect = { 0, 0, 600, 520 };
    AdjustWindowRect(&winRect, WS_OVERLAPPEDWINDOW, FALSE);

    int totalW = winRect.right - winRect.left;
    int totalH = winRect.bottom - winRect.top;

    HWND hWnd = CreateWindowW(L"PacmanGameClass", L"Pac-Man Coursework", WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, 0, totalW, totalH, nullptr, nullptr, hInstance, nullptr);
    if (!hWnd) return FALSE;

    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);

    MSG msg;
    while (GetMessage(&msg, nullptr, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return (int)msg.wParam;
}


