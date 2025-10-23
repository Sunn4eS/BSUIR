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

// Прототипы функций DLL
typedef bool(*InitializeDatabaseFunc)(const char*);
typedef void(*SearchRecordsFunc)(const char*, const char*, void (*)(const char*));

// Глобальные переменные
HWND g_hWnd;
HWND g_hSearchField, g_hSearchValue, g_hSearchButton, g_hResultsList, g_hFieldCombo;
HMODULE g_hDll = nullptr;
InitializeDatabaseFunc g_initDb = nullptr;
SearchRecordsFunc g_search = nullptr;
std::vector<std::string> g_searchResults;

// Функция обратного вызова для поиска
void SearchCallback(const char* record) {
    g_searchResults.push_back(record);
}

// Функция инициализации элементов управления
void InitControls(HWND hWnd) {
    // Комбобокс для выбора поля поиска
    g_hFieldCombo = CreateWindowW(WC_COMBOBOXW, L"",
        CBS_DROPDOWNLIST | WS_CHILD | WS_VISIBLE | WS_TABSTOP,
        20, 20, 150, 200, hWnd, (HMENU)IDC_FIELD_COMBO,
        GetModuleHandle(NULL), NULL);

    // Добавляем поля для поиска
    const wchar_t* fields[] = {
        L"phone", L"lastName", L"firstName",
        L"middleName", L"street", L"house",
        L"building", L"apartment"
    };

    for (int i = 0; i < sizeof(fields) / sizeof(fields[0]); i++) {
        SendMessageW(g_hFieldCombo, CB_ADDSTRING, 0, (LPARAM)fields[i]);
    }
    SendMessageW(g_hFieldCombo, CB_SETCURSEL, 0, 0);

    // Поле для ввода значения поиска
    g_hSearchValue = CreateWindowW(WC_EDITW, L"",
        WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL,
        180, 20, 200, 25, hWnd, (HMENU)IDC_SEARCH_VALUE,
        GetModuleHandle(NULL), NULL);

    // Кнопка поиска (теперь скрыта, так как поиск автоматический)
    g_hSearchButton = CreateWindowW(WC_BUTTONW, L"Поиск",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        390, 20, 80, 25, hWnd, (HMENU)IDC_SEARCH_BUTTON,
        GetModuleHandle(NULL), NULL);
    ShowWindow(g_hSearchButton, SW_HIDE); // Скрываем кнопку

    // Список результатов
    g_hResultsList = CreateWindowW(WC_LISTVIEWW, L"",
        WS_CHILD | WS_VISIBLE | LVS_REPORT | LVS_SINGLESEL | WS_BORDER,
        20, 60, 450, 300, hWnd, (HMENU)IDC_RESULTS_LIST,
        GetModuleHandle(NULL), NULL);

    // Настраиваем колонки списка
    LVCOLUMNW lvc;
    lvc.mask = LVCF_FMT | LVCF_WIDTH | LVCF_TEXT | LVCF_SUBITEM;

    const wchar_t* columns[] = { L"Телефон", L"Фамилия", L"Имя", L"Отчество",
                               L"Улица", L"Дом", L"Корпус", L"Квартира" };
    int widths[] = { 80, 100, 100, 100, 120, 50, 50, 50 };

    for (int i = 0; i < 8; i++) {
        lvc.iSubItem = i;
        lvc.pszText = (LPWSTR)columns[i];
        lvc.cx = widths[i];
        lvc.fmt = LVCFMT_LEFT;
        ListView_InsertColumn(g_hResultsList, i, &lvc);
    }
}

// Функция загрузки DLL и получения функций
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

// Функция обработки поиска
void HandleSearch() {
    // Получаем выбранное поле поиска
    wchar_t field[50];
    int sel = SendMessageW(g_hFieldCombo, CB_GETCURSEL, 0, 0);
    SendMessageW(g_hFieldCombo, CB_GETLBTEXT, sel, (LPARAM)field);

    // Получаем значение для поиска
    wchar_t value[100];
    GetWindowTextW(g_hSearchValue, value, 100);

    // Конвертируем в многобайтовую строку (Windows-1251)
    char fieldA[50], valueA[100];
    WideCharToMultiByte(1251, 0, field, -1, fieldA, 50, NULL, NULL);
    WideCharToMultiByte(1251, 0, value, -1, valueA, 100, NULL, NULL);

    // Очищаем предыдущие результаты
    ListView_DeleteAllItems(g_hResultsList);
    g_searchResults.clear();

    // Выполняем поиск (при пустом значении выводятся все записи)
    g_search(fieldA, valueA, SearchCallback);

    // Добавляем результаты в список
    for (size_t i = 0; i < g_searchResults.size(); i++) {
        // Конвертируем результат обратно в Unicode
        wchar_t resultW[256];
        MultiByteToWideChar(1251, 0, g_searchResults[i].c_str(), -1, resultW, 256);

        // Разбираем строку на поля с использованием безопасной версии
        wchar_t* context = nullptr;
        wchar_t* token = nullptr;
        wchar_t* fields[8] = { 0 };
        int fieldIndex = 0;

        // Создаем копию строки для токенизации
        wchar_t copy[256];
        wcscpy_s(copy, 256, resultW);

        token = wcstok_s(copy, L",", &context);
        while (token != nullptr && fieldIndex < 8) {
            // Убираем пробелы в начале строки
            while (*token == L' ') token++;
            fields[fieldIndex++] = token;
            token = wcstok_s(nullptr, L",", &context);
        }

        // Добавляем элемент в список
        LVITEMW lvi = { 0 };
        lvi.mask = LVIF_TEXT;
        lvi.iItem = (int)i;
        lvi.iSubItem = 0;
        lvi.pszText = fields[0];
        ListView_InsertItem(g_hResultsList, &lvi);

        // Добавляем подэлементы
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

// Функция для выполнения начального поиска (все записи)
void PerformInitialSearch() {
    // Устанавливаем пустое значение в поле поиска
    SetWindowTextW(g_hSearchValue, L"");
    // Выполняем поиск (при пустом значении выводятся все записи)
    HandleSearch();
}

// Оконная процедура
LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
    case WM_CREATE:
        InitControls(hWnd);
        if (LoadDllFunctions()) {
            // После успешной загрузки DLL выполняем начальный поиск
            PerformInitialSearch();
        }
        else {
            PostQuitMessage(0);
        }
        break;

    case WM_COMMAND:
        if (LOWORD(wParam) == IDC_SEARCH_VALUE && HIWORD(wParam) == EN_CHANGE) {
            // Поиск при каждом изменении текста
            HandleSearch();
        }
        else if (LOWORD(wParam) == IDC_FIELD_COMBO && HIWORD(wParam) == CBN_SELCHANGE) {
            // Поиск при изменении выбранного поля
            HandleSearch();
        }
        break;

    case WM_SIZE:
    {
        RECT rc;
        GetClientRect(hWnd, &rc);
        MoveWindow(g_hResultsList, 20, 60, rc.right - 40, rc.bottom - 80, TRUE);
    }
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

// Точка входа
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    // Инициализация common controls
    INITCOMMONCONTROLSEX icc;
    icc.dwSize = sizeof(icc);
    icc.dwICC = ICC_LISTVIEW_CLASSES | ICC_STANDARD_CLASSES;
    InitCommonControlsEx(&icc);

    // Регистрируем класс окна
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

    // Создаем главное окно
    g_hWnd = CreateWindowW(L"PhoneBookApp", L"Телефонный справочник Минска",
        WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 600, 500,
        NULL, NULL, hInstance, NULL);

    if (!g_hWnd) {
        MessageBoxW(NULL, L"Ошибка создания окна!", L"Ошибка", MB_ICONERROR);
        return 1;
    }

    // Отображаем окно
    ShowWindow(g_hWnd, nCmdShow);
    UpdateWindow(g_hWnd);

    // Цикл сообщений
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return (int)msg.wParam;
}