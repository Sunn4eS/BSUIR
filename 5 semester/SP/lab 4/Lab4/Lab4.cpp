#include "Lab4.h"
#include <fstream>

#define MAX_LOADSTRING 100

HINSTANCE hInst;
WCHAR szWindowClass[] = TEXT("Lab4Class");
WCHAR szTitle[] = L"Lab4";

ATOM                MyRegisterClass(HINSTANCE hInstance);
BOOL                InitInstance(HINSTANCE, int);
LRESULT CALLBACK    WndProc(HWND, UINT, WPARAM, LPARAM);

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPWSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    MyRegisterClass(hInstance);

    if (!InitInstance (hInstance, nCmdShow))
    {
        return FALSE;
    }

    MSG msg;

    while (GetMessage(&msg, nullptr, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return (int) msg.wParam;
}


ATOM MyRegisterClass(HINSTANCE hInstance)
{
    WNDCLASSEXW wcex = { 0 };

    wcex.cbSize = sizeof(WNDCLASSEX);

    wcex.style          = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc    = WndProc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = hInstance;
    wcex.hCursor        = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
    //wcex.lpszMenuName   = MAKEINTRESOURCEW(IDC_LAB4);
    wcex.lpszClassName  = szWindowClass;

    return RegisterClassExW(&wcex);
}

BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   hInst = hInstance;

   HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, CW_USEDEFAULT, 800, 600, nullptr, nullptr, hInstance, nullptr);

   if (!hWnd)
   {
      return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}

void InitControls(HWND hWnd) {
    g_hSearchValue = CreateWindowW(WC_EDITW, L"",
        WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL,
        20, 20, 200, 25, hWnd, (HMENU)IDC_SEARCH_VALUE,
        GetModuleHandle(NULL), NULL);

    g_hSearchButton = CreateWindowW(WC_BUTTON, TEXT("Поиск"),
        WS_CHILD | WS_VISIBLE | WS_BORDER,
        230, 20, 100, 25, hWnd, (HMENU)IDC_SEARCH_BUTTON,
        GetModuleHandle(NULL), NULL);
    g_hFieldCombo = CreateWindowW(WC_COMBOBOXW, L"",
        CBS_DROPDOWNLIST | WS_CHILD | WS_VISIBLE | WS_TABSTOP,
        340, 20, 150, 200, hWnd, (HMENU)IDC_FIELD_COMBO,
        GetModuleHandle(NULL), NULL);

    for (int i = 0; i < sizeof(comboFields) / sizeof(comboFields[0]); i++) {
        SendMessageW(g_hFieldCombo, CB_ADDSTRING, 0, (LPARAM)comboFields[i].displayName);
    }
    SendMessageW(g_hFieldCombo, CB_SETCURSEL, 0, 0);

    g_hResultsList = CreateWindowW(WC_LISTVIEWW, L"",
        WS_CHILD | WS_VISIBLE | LVS_REPORT | LVS_SINGLESEL | WS_BORDER,
        20, 60, 680, 300, hWnd, (HMENU)IDC_RESULTS_LIST,
        GetModuleHandle(NULL), NULL);

    LVCOLUMNW lvc;
    lvc.mask = LVCF_FMT | LVCF_WIDTH | LVCF_TEXT | LVCF_SUBITEM;

    int widths[] = { 100, 100, 100, 80, 120, 50, 50, 50 };

    for (int i = 0; i < sizeof(comboFields) / sizeof(comboFields[0]); i++) {
        lvc.iSubItem = i;
        lvc.pszText = (LPWSTR)comboFields[i].displayName;
        lvc.cx = widths[i];
        lvc.fmt = LVCFMT_LEFT;
        ListView_InsertColumn(g_hResultsList, i, &lvc);
    }
}

BOOL LoadDB(HWND hWnd) {
    hm_db = LoadLibraryW(L"PhoneDB.dll");
    if (!hm_db) {
        MessageBoxW(hWnd, L"Не удалось загрузить DLL!", L"Ошибка", MB_ICONERROR);
        return false;
    }

    DBFOpen = (DBFOPEN)GetProcAddress(hm_db, "open");
    DBFClsoe = (DBFCLOSE)GetProcAddress(hm_db, "close");
    DBFSearch = (DBFSEARCH)GetProcAddress(hm_db, "search_by_query");

    if (!DBFOpen || !DBFClsoe || !DBFSearch) {
        MessageBoxW(hWnd, L"Не удалось найти функции в DLL!", L"Ошибка", MB_ICONERROR);
        FreeLibrary(hm_db);
        hm_db = nullptr;
        return false;
    }

    return true;
}

void RenderListItems() {
    ListView_DeleteAllItems(g_hResultsList);
    for (int i = 0; i < resultInfo.size; i++) {
        const PhoneRecord& r = resultInfo.records[i];

        const char* fields[8] = {
            r.lastName,
            r.firstName,
            r.middleName,
            r.phone,
            r.street,
            r.house,
            r.building,
            r.apartment
        };

        wchar_t wfield[256];

        MultiByteToWideChar(1251, 0, fields[0], -1, wfield, 256);
        LVITEMW lvi = { 0 };
        lvi.mask = LVIF_TEXT;
        lvi.iItem = (int)i;
        lvi.iSubItem = 0;
        lvi.pszText = wfield;
        ListView_InsertItem(g_hResultsList, &lvi);

        for (int j = 1; j < 8; j++) {
            if (fields[j]) {
                MultiByteToWideChar(1251, 0, fields[j], -1, wfield, 256);
                ListView_SetItemText(g_hResultsList, (int)i, j, wfield);
            }
            else {
                ListView_SetItemText(g_hResultsList, (int)i, j, (LPWSTR)L"");
            }
        }
    }
}

void SaveResultsToFile(const char* fileName) {
    std::ofstream out(fileName, std::ios::out | std::ios::trunc);
    if (!out.is_open()) return;

    for (int i = 0; i < resultInfo.size; i++) {
        const PhoneRecord& r = resultInfo.records[i];

        out << r.lastName << ","
            << r.firstName << ","
            << r.middleName << ","
            << r.phone << ","
            << r.street << ","
            << r.house << ","
            << r.building << ","
            << r.apartment << "\n";
    }
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)
    {
    case WM_CREATE: {
        InitControls(hWnd);
        if (!(LoadDB(hWnd) && DBFOpen("phonebook.txt"))) {
            MessageBoxW(hWnd, L"Ошибка инициализации базы данных!", L"Ошибка", MB_ICONERROR);
            FreeLibrary(hm_db);
            hm_db = nullptr;
            PostQuitMessage(0);
        }
        else {
            resultInfo.records = DBFSearch(PhoneRecordAttr::FirstName, "", &resultInfo.size);
            RenderListItems();
        }
    }
        break;
    case WM_COMMAND:
        {
            int wmId = LOWORD(wParam);
            int code = HIWORD(wParam);
            switch (wmId)
            {
            case IDC_SEARCH_BUTTON: {
                if (code == BN_CLICKED) {
                    int selIndex = (int)SendMessageW(g_hFieldCombo, CB_GETCURSEL, 0, 0);
                    PhoneRecordAttr curPhoneRecordAttr;

                    wchar_t value[100];
                    GetWindowTextW(g_hSearchValue, value, 100);

                    char valueW[100];
                    WideCharToMultiByte(CP_ACP, 0, value, -1, valueW, 100, NULL, NULL);

                    if (selIndex >= 0 && selIndex < sizeof(comboFields) / sizeof(comboFields[0])) {
                        curPhoneRecordAttr = comboFields[selIndex].value;
                        resultInfo.records = DBFSearch(curPhoneRecordAttr, valueW, &resultInfo.size);
                        RenderListItems();
                        SaveResultsToFile("results.txt");
                    }
                }
            }
                break;
            default:
                break;
            }
        }
        break;
    case WM_DESTROY:
        if (hm_db) {
            if (DBFClsoe) {
                DBFClsoe();
            }
            FreeLibrary(hm_db);
        }
        PostQuitMessage(0);
        break;
    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}