#include <windows.h>
#include <commctrl.h>
#include <string>
#include <vector>

#pragma comment(lib, "comctl32.lib")
#pragma comment(linker, "\"/manifestdependency:type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

// Идентификаторы элементов управления
#define IDC_SEARCH_FIELD 101
#define IDC_SEARCH_VALUE 102
#define IDC_SEARCH_BUTTON 103 
#define IDC_RESULTS_LIST 104
#define IDC_FIELD_COMBO 105

typedef bool(*InitializeDatabaseFunc)(const char*);
typedef void(*SearchRecordsFunc)(const char*, const char*, void (*)(const char*));

HWND g_hWnd;
HWND g_hSearchField, g_hSearchValue, g_hSearchButton, g_hResultsList, g_hFieldCombo;
HMODULE g_hDll = nullptr;
InitializeDatabaseFunc g_initDb = nullptr;
SearchRecordsFunc g_search = nullptr;
std::vector<std::string> g_searchResults;

const int WINDOW_WIDTH = 800;
const int WINDOW_HEIGHT = 600;
const int CONTROL_HEIGHT = 25;
const int PADDING = 10;
const int COMBO_WIDTH = 150;

void SearchCallback(const char* record) {
    g_searchResults.push_back(record);
}

void InitControls(HWND hWnd) {
    RECT rc;
    GetClientRect(hWnd, &rc);
    int clientWidth = rc.right - rc.left;
    int clientHeight = rc.bottom - rc.top;

    int bottomY = clientHeight - PADDING - CONTROL_HEIGHT;

    g_hFieldCombo = CreateWindowW(WC_COMBOBOXW, L"",
        CBS_DROPDOWNLIST | WS_CHILD | WS_VISIBLE | WS_TABSTOP,
        PADDING, bottomY, COMBO_WIDTH, 200, hWnd, (HMENU)IDC_FIELD_COMBO,
        GetModuleHandle(NULL), NULL);

    const wchar_t* fields[] = {
        L"phone", L"lastName", L"firstName",
        L"middleName", L"street", L"house",
        L"building", L"apartment"
    };

    for (int i = 0; i < sizeof(fields) / sizeof(fields[0]); i++) {
        SendMessageW(g_hFieldCombo, CB_ADDSTRING, 0, (LPARAM)fields[i]);
    }
    SendMessageW(g_hFieldCombo, CB_SETCURSEL, 0, 0);

    int searchValueX = PADDING + COMBO_WIDTH + PADDING;
    int searchValueWidth = clientWidth - searchValueX - PADDING;

    g_hSearchValue = CreateWindowW(WC_EDITW, L"",
        WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL,
        searchValueX, bottomY, searchValueWidth, CONTROL_HEIGHT, hWnd, (HMENU)IDC_SEARCH_VALUE,
        GetModuleHandle(NULL), NULL);

    g_hSearchButton = CreateWindowW(WC_BUTTONW, L"Поиск",
        WS_CHILD | BS_PUSHBUTTON,
        0, 0, 0, 0, hWnd, (HMENU)IDC_SEARCH_BUTTON,
        GetModuleHandle(NULL), NULL);
    ShowWindow(g_hSearchButton, SW_HIDE);

    int resultsHeight = bottomY - 2 * PADDING;

    g_hResultsList = CreateWindowW(WC_LISTVIEWW, L"",
        WS_CHILD | WS_VISIBLE | LVS_REPORT | LVS_SINGLESEL | WS_BORDER,
        PADDING, PADDING, clientWidth - 2 * PADDING, resultsHeight, hWnd, (HMENU)IDC_RESULTS_LIST,
        GetModuleHandle(NULL), NULL);

    LVCOLUMNW lvc;
    lvc.mask = LVCF_FMT | LVCF_WIDTH | LVCF_TEXT | LVCF_SUBITEM;

    const wchar_t* columns[] = { L"Телефон", L"Фамилия", L"Имя", L"Отчество",
                                 L"Улица", L"Дом", L"Корпус", L"Квартира" };
    int totalWidth = clientWidth - 2 * PADDING;
    int baseWidth = totalWidth / 8;
    int widths[] = { baseWidth + 20, baseWidth + 30, baseWidth + 30, baseWidth + 30,
                     baseWidth + 40, baseWidth - 20, baseWidth - 20, baseWidth - 20 };

    int sumWidths = 0;
    for (int w : widths) sumWidths += w;
    if (sumWidths < totalWidth) widths[0] += (totalWidth - sumWidths);


    for (int i = 0; i < 8; i++) {
        lvc.iSubItem = i;
        lvc.pszText = (LPWSTR)columns[i];
        lvc.cx = widths[i];
        lvc.fmt = LVCFMT_LEFT;
        ListView_InsertColumn(g_hResultsList, i, &lvc);
    }
}

bool LoadDllFunctions() {
    g_hDll = LoadLibraryW(L"PhoneBookDLL.dll");
    if (!g_hDll) {
        MessageBoxW(g_hWnd, L"Не удалось загрузить DLL!", L"Ошибка", MB_ICONERROR);
        return false;
    }

    g_initDb = (InitializeDatabaseFunc)GetProcAddress(g_hDll, "InitializeDatabase");
    g_search = (SearchRecordsFunc)GetProcAddress(g_hDll, "SearchRecords");

    if (!g_initDb || !g_search) {
        MessageBoxW(g_hWnd, L"Не удалось найти функции в DLL!", L"Ошибка", MB_ICONERROR);
        FreeLibrary(g_hDll);
        g_hDll = nullptr;
        return false;
    }

    if (!g_initDb("phonebook.txt")) {
        MessageBoxW(g_hWnd, L"Ошибка инициализации базы данных!", L"Ошибка", MB_ICONERROR);
        FreeLibrary(g_hDll);
        g_hDll = nullptr;
        return false;
    }

    return true;
}

void HandleSearch() {
    wchar_t field[50];
    int sel = SendMessageW(g_hFieldCombo, CB_GETCURSEL, 0, 0);
    SendMessageW(g_hFieldCombo, CB_GETLBTEXT, sel, (LPARAM)field);

    wchar_t value[100];
    GetWindowTextW(g_hSearchValue, value, 100);

    char fieldA[50], valueA[100];
    WideCharToMultiByte(1251, 0, field, -1, fieldA, 50, NULL, NULL);
    WideCharToMultiByte(1251, 0, value, -1, valueA, 100, NULL, NULL);

    ListView_DeleteAllItems(g_hResultsList);
    g_searchResults.clear();

    g_search(fieldA, valueA, SearchCallback);

    for (size_t i = 0; i < g_searchResults.size(); i++) {
        wchar_t resultW[256];
        MultiByteToWideChar(1251, 0, g_searchResults[i].c_str(), -1, resultW, 256);

        wchar_t* context = nullptr;
        wchar_t* token = nullptr;
        wchar_t* fields[8] = { 0 };
        int fieldIndex = 0;

        wchar_t copy[256];
        wcscpy_s(copy, 256, resultW);

        token = wcstok_s(copy, L",", &context);
        while (token != nullptr && fieldIndex < 8) {
            while (*token == L' ') token++;
            fields[fieldIndex++] = token;
            token = wcstok_s(nullptr, L",", &context);
        }

        LVITEMW lvi = { 0 };
        lvi.mask = LVIF_TEXT;
        lvi.iItem = (int)i;
        lvi.iSubItem = 0;
        lvi.pszText = fields[0];
        ListView_InsertItem(g_hResultsList, &lvi);

        for (int j = 1; j < 8; j++) {
            if (fields[j]) {
                ListView_SetItemText(g_hResultsList, (int)i, j, (LPWSTR)fields[j]);
            }
            else {
                ListView_SetItemText(g_hResultsList, (int)i, j, (LPWSTR)L"");
            }
        }
    }
}
void PerformInitialSearch() {
    SetWindowTextW(g_hSearchValue, L"");
    HandleSearch();
}

void ResizeControls(HWND hWnd) {
    RECT rc;
    GetClientRect(hWnd, &rc);
    int clientWidth = rc.right - rc.left;
    int clientHeight = rc.bottom - rc.top;

    int bottomY = clientHeight - PADDING - CONTROL_HEIGHT;

    MoveWindow(g_hFieldCombo, PADDING, bottomY, COMBO_WIDTH, CONTROL_HEIGHT, TRUE);

    int searchValueX = PADDING + COMBO_WIDTH + PADDING;
    int searchValueWidth = clientWidth - searchValueX - PADDING;
    MoveWindow(g_hSearchValue, searchValueX, bottomY, searchValueWidth, CONTROL_HEIGHT, TRUE);

    int resultsHeight = bottomY - 2 * PADDING;
    MoveWindow(g_hResultsList, PADDING, PADDING, clientWidth - 2 * PADDING, resultsHeight, TRUE);

    int totalWidth = clientWidth - 2 * PADDING;
    int baseWidth = totalWidth / 8;
    int widths[] = { baseWidth + 20, baseWidth + 30, baseWidth + 30, baseWidth + 30,
                     baseWidth + 40, baseWidth - 20, baseWidth - 20, baseWidth - 20 };
    int sumWidths = 0;
    for (int w : widths) sumWidths += w;
    if (sumWidths < totalWidth) widths[0] += (totalWidth - sumWidths);

    for (int i = 0; i < 8; i++) {
        ListView_SetColumnWidth(g_hResultsList, i, widths[i]);
    }
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
    case WM_CREATE:
        InitControls(hWnd);
        if (LoadDllFunctions()) {
            PerformInitialSearch();
        }
        else {
            PostQuitMessage(0);
        }
        break;

    case WM_COMMAND:
        if (LOWORD(wParam) == IDC_SEARCH_VALUE && HIWORD(wParam) == EN_CHANGE) {
            HandleSearch();
        }
        else if (LOWORD(wParam) == IDC_FIELD_COMBO && HIWORD(wParam) == CBN_SELCHANGE) {
            HandleSearch();
        }
        break;

    case WM_SIZE:
        ResizeControls(hWnd);
        break;

    case WM_DESTROY:
        if (g_hDll) {
            FreeLibrary(g_hDll);
        }
        PostQuitMessage(0);
        break;

    default:
        return DefWindowProcW(hWnd, msg, wParam, lParam);
    }
    return 0;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    INITCOMMONCONTROLSEX icc;
    icc.dwSize = sizeof(icc);
    icc.dwICC = ICC_LISTVIEW_CLASSES | ICC_STANDARD_CLASSES;
    InitCommonControlsEx(&icc);

    WNDCLASSEXW wc = { 0 };
    wc.cbSize = sizeof(WNDCLASSEXW);
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = WndProc;
    wc.hInstance = hInstance;
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    wc.lpszClassName = L"PhoneBookApp";

    if (!RegisterClassExW(&wc)) {
        MessageBoxW(NULL, L"Ошибка регистрации класса окна!", L"Ошибка", MB_ICONERROR);
        return 1;
    }   

    g_hWnd = CreateWindowW(L"PhoneBookApp", L"Телефонный справочник",
        WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, WINDOW_WIDTH, WINDOW_HEIGHT,
        NULL, NULL, hInstance, NULL);

    if (!g_hWnd) {
        MessageBoxW(NULL, L"Ошибка создания окна!", L"Ошибка", MB_ICONERROR);
        return 1;
    }

    ShowWindow(g_hWnd, nCmdShow);
    UpdateWindow(g_hWnd);

    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return (int)msg.wParam;
}