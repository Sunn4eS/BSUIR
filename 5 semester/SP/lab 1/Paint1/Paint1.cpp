#include <windows.h>
#include <vector>
#include <string>

enum class Action { Open = 1001, Save, Clear};
enum class Tool { Line = 101, Polyline, Rectangle, Ellipse, Polygon, Text, Print, Brush };

struct Shape {
    Tool type;
    std::vector<POINT> points;
    std::wstring text;
};

const int MARGIN = 10;
const int BUTTON_WIDTH = 120, BUTTON_HEIGHT = 30;
const int CANVAS_X_START = 2 * MARGIN + BUTTON_WIDTH, CANVAS_Y_START = 1 * MARGIN;


HWND hwnd;

HBITMAP hBufferBitmap = NULL;
HDC hBufferDC = NULL;

int canvasWidth, canvasHeight;

Tool currentTool = Tool::Brush;
bool isDrawing = false;
std::vector<POINT> currentPoints;
std::wstring currentText;

std::vector<Shape> shapes;

float zoomFactor = 1.0f;
int panX = 0, panY = 0;

HENHMETAFILE loadedEmf = NULL;


LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
void createButtons(HINSTANCE hInstance, HWND hwnd);
void createActionButtons(HINSTANCE hInstance, HWND hwnd);
void createToolButtons(HINSTANCE hInstance, HWND hwnd);
void DrawBitMap();
void ClearCanvas(HWND hwnd);
void DrawShape(HDC hdc, Shape shape);
void AddPoint(int x, int y);
void AddShape();
int transformX(int x);
int transformY(int y);
void LoadFromEMF(const std::wstring& filename);
void SaveToEMF(const std::wstring& filename);
void DrawEMFWithTransform(HDC hdc, HENHMETAFILE emf, float zoom, int panX, int panY);
void Print(HWND hwnd, RECT region);


int CALLBACK wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow)
{
    const wchar_t CLASS_NAME[] = L"Paint";

    WNDCLASS wc = { };

    wc.lpfnWndProc = WindowProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = CLASS_NAME;

    RegisterClass(&wc);

    hwnd = CreateWindowEx(
        0,
        CLASS_NAME,
        L"Paint",
        WS_OVERLAPPEDWINDOW,

        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,

        NULL,
        NULL,
        hInstance,
        NULL
    );

    createButtons(hInstance, hwnd);

    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);

    MSG msg = { };
    while (GetMessage(&msg, NULL, 0, 0) > 0)
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return 0;
}

void createButtons(HINSTANCE hInstance, HWND hwnd)
{
    createActionButtons(hInstance, hwnd);
    createToolButtons(hInstance, hwnd);
}

void createActionButtons(HINSTANCE hInstance, HWND hwnd)
{
    CreateWindow(L"BUTTON", L"Открыть",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        MARGIN, 1 * MARGIN + 0 * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT, hwnd, (HMENU)Action::Open,
        hInstance, NULL);

    CreateWindow(L"BUTTON", L"Сохранить",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        MARGIN, 2 * MARGIN + 1 * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT, hwnd, (HMENU)Action::Save,
        hInstance, NULL);

    CreateWindow(L"BUTTON", L"Очистить",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        MARGIN, 2 * MARGIN + 2 * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT, hwnd, (HMENU)Action::Clear,
        hInstance, NULL);

}

void createToolButtons(HINSTANCE hInstance, HWND hwnd)
{
    CreateWindow(L"BUTTON", L"Линия",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        MARGIN, 3 * MARGIN + 3 * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT, hwnd, (HMENU)Tool::Line,
        hInstance, NULL);

    CreateWindow(L"BUTTON", L"Ломанная",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        MARGIN, 4 * MARGIN + 4 * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT, hwnd, (HMENU)Tool::Polyline,
        hInstance, NULL);

    CreateWindow(L"BUTTON", L"Прямоугольник",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        MARGIN, 5 * MARGIN + 5 * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT, hwnd, (HMENU)Tool::Rectangle,
        hInstance, NULL);

    CreateWindow(L"BUTTON", L"Эллипс",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        MARGIN, 6 * MARGIN + 6 * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT, hwnd, (HMENU)Tool::Ellipse,
        hInstance, NULL);

    CreateWindow(L"BUTTON", L"Многоугольник",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        MARGIN, 7 * MARGIN + 7 * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT, hwnd, (HMENU)Tool::Polygon,
        hInstance, NULL);


    CreateWindow(L"BUTTON", L"Текст",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        MARGIN, 8 * MARGIN + 8 * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT, hwnd, (HMENU)Tool::Text,
        hInstance, NULL);

    CreateWindow(L"BUTTON", L"Печать",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        MARGIN, 9 * MARGIN + 9 * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT, hwnd, (HMENU)Tool::Print,
        hInstance, NULL);
}

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    switch (uMsg)
    {
    case WM_COMMAND:
    {
        switch (wParam)
        {
        case (WPARAM)Tool::Line:
        case (WPARAM)Tool::Polyline:
        case (WPARAM)Tool::Rectangle:
        case (WPARAM)Tool::Ellipse:
        case (WPARAM)Tool::Polygon:
        case (WPARAM)Tool::Text:
        case (WPARAM)Tool::Print:
        case (WPARAM)Tool::Brush:
            if (wParam == (WPARAM)currentTool)
                currentTool = Tool::Brush;
            else
                currentTool = (Tool)wParam;
            break;
        case (WPARAM)Action::Open:
            LoadFromEMF(L"drawing.emf");
            break;
        case (WPARAM)Action::Save:
            SaveToEMF(L"drawing.emf");
            break;
        case (WPARAM)Action::Clear:
            ClearCanvas(hwnd);
            break;
        }
    }
    return 0;

    case WM_SIZE:
    {
        DrawBitMap();
    }
    return 0;

    case WM_LBUTTONDOWN:
    {
        int x = LOWORD(lParam), y = HIWORD(lParam);

        if (x > CANVAS_X_START && y > CANVAS_Y_START)
        {
            if (isDrawing)
            {
                AddPoint(x, y);

                switch (currentTool)
                {
                case Tool::Line:
                case Tool::Rectangle:
                case Tool::Ellipse:
                case Tool::Text:
                {
                    isDrawing = false;

                    AddShape();

                    DrawBitMap();
                    InvalidateRect(hwnd, NULL, FALSE);
                }
                break;
                case Tool::Print:
                {
                    isDrawing = false;

                    // Преобразуем координаты выбранной области
                    int x1 = currentPoints[0].x;
                    int y1 = currentPoints[0].y;
                    int x2 = currentPoints[1].x;
                    int y2 = currentPoints[1].y;

                    // Создаем RECT с правильными координатами
                    RECT selectedRect = {
                        min(x1, x2),// + CANVAS_X_START,
                        min(y1, y2),// + CANVAS_Y_START,
                        max(x1, x2),// + CANVAS_X_START,
                        max(y1, y2)// + CANVAS_Y_START
                    };


                    currentPoints.clear();
                    currentText.clear();

                    HDC hdc = GetDC(hwnd);

                    DrawBitMap();

                    BitBlt(hdc, CANVAS_X_START, CANVAS_Y_START, canvasWidth, canvasHeight, hBufferDC, 0, 0, SRCCOPY);

                    ReleaseDC(hwnd, hdc);

                    Print(hwnd, selectedRect);
                }
                break;

                default:
                    break;
                }
            }
            else
            {
                isDrawing = true;

                AddPoint(x, y);

                SetFocus(hwnd);
            }
        }
    }
    return 0;

    case WM_RBUTTONDOWN:
    {
        int x = LOWORD(lParam), y = HIWORD(lParam);

        if (isDrawing && x > CANVAS_X_START && y > CANVAS_Y_START)
        {
            switch (currentTool)
            {
            case Tool::Polyline:
            case Tool::Polygon:
            {
                AddPoint(x, y);

                isDrawing = false;

                AddShape();

                DrawBitMap();
                InvalidateRect(hwnd, NULL, FALSE);
            }
            break;
            default:
                break;
            }
        }
    }
    return 0;

    case WM_LBUTTONUP:
    {
        int x = LOWORD(lParam), y = HIWORD(lParam);
        if (isDrawing && x > CANVAS_X_START && y > CANVAS_Y_START)
        {
            switch (currentTool)
            {
            case Tool::Brush:
            {
                AddPoint(x, y);
                isDrawing = false;
                AddShape();

                DrawBitMap();
                InvalidateRect(hwnd, NULL, FALSE);
            }
            break;
            default:
                break;
            }
        }
    }
    return 0;

    case WM_MOUSEMOVE:
    {
        int x = LOWORD(lParam), y = HIWORD(lParam);

        if (isDrawing && x > CANVAS_X_START && y > CANVAS_Y_START)
        {
            switch (wParam)
            {
            case MK_LBUTTON:
            {
                if (currentTool == Tool::Brush)
                {
                    HDC hdc = GetDC(hwnd);
                    HPEN hPen = CreatePen(PS_SOLID, 2, RGB(0, 0, 0));
                    SelectObject(hdc, hPen);

                    Shape tempShape = { currentTool, currentPoints, currentText };

                    MoveToEx(hdc, currentPoints.back().x, currentPoints.back().y, NULL);
                    LineTo(hdc, x, y);

                    AddPoint(x, y);

                    ReleaseDC(hwnd, hdc);
                    DeleteObject(hPen);
                }
            }
            break;
            default:
            {
                HDC hdc = GetDC(hwnd);

                DrawBitMap();


                AddPoint(x, y);
                Shape tempShape = { currentTool, currentPoints, currentText };
                DrawShape(hBufferDC, tempShape);
                currentPoints.pop_back();

                BitBlt(hdc, CANVAS_X_START, CANVAS_Y_START, canvasWidth, canvasHeight, hBufferDC, 0, 0, SRCCOPY);

                ReleaseDC(hwnd, hdc);
            }
            break;
            }

        }
    }
    return 0;

    case WM_CHAR:
    {
        if (isDrawing)
        {
            HDC hdc = GetDC(hwnd);

            DrawBitMap();

            currentText = currentText + static_cast<TCHAR>(wParam);
            Shape tempShape = { currentTool, currentPoints, currentText };
            DrawShape(hBufferDC, tempShape);

            BitBlt(hdc, CANVAS_X_START, CANVAS_Y_START, canvasWidth, canvasHeight, hBufferDC, 0, 0, SRCCOPY);

            ReleaseDC(hwnd, hdc);
        }
    }
    return 0;

    case WM_MOUSEWHEEL:
    {
        short delta = GET_WHEEL_DELTA_WPARAM(wParam);
        auto key = GET_KEYSTATE_WPARAM(wParam);

        if (key == MK_CONTROL)
        {
            float zoomStep = 0.1f;
            zoomFactor += (delta > 0 ? zoomStep : -zoomStep);
            zoomFactor = max(0.1f, min(zoomFactor, 10.0f));
        }
        else
        {
            int panStep = 20;
            if (key == MK_SHIFT)
                panX += (delta > 0 ? panStep : -panStep);
            else
                panY += (delta > 0 ? panStep : -panStep);
        }

        DrawBitMap();
        InvalidateRect(hwnd, NULL, FALSE);
    }
    return 0;

    case WM_PAINT:
    {
        PAINTSTRUCT ps;
        HDC hdc = BeginPaint(hwnd, &ps);

        DrawBitMap();
        BitBlt(hdc, CANVAS_X_START, CANVAS_Y_START, canvasWidth, canvasHeight, hBufferDC, 0, 0, SRCCOPY);

        EndPaint(hwnd, &ps);
    }
    return 0;

    case WM_DESTROY:
    {
        PostQuitMessage(0);
    }
    return 0;

    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

void ClearCanvas(HWND hwnd)
{
    
    shapes.clear();


    currentPoints.clear();
    currentText.clear();
    isDrawing = false;

     DrawBitMap();

    InvalidateRect(hwnd, NULL, TRUE);
}


void DrawBitMap() {
    if (hBufferBitmap) {
        DeleteObject(hBufferBitmap);
    }
    if (hBufferDC) {
        DeleteDC(hBufferDC);
    }

    RECT clientRect;
    GetClientRect(hwnd, &clientRect);
    canvasWidth = clientRect.right - clientRect.left - CANVAS_X_START;
    canvasHeight = clientRect.bottom - clientRect.top - CANVAS_Y_START;

    HDC hdc = GetDC(hwnd);

    hBufferDC = CreateCompatibleDC(hdc);
    hBufferBitmap = CreateCompatibleBitmap(hdc, canvasWidth, canvasHeight);

    SelectObject(hBufferDC, hBufferBitmap);

    RECT rect = { 0, 0, canvasWidth, canvasHeight };
    HBRUSH hBrush = CreateSolidBrush(RGB(255, 255, 255));
    FillRect(hBufferDC, &rect, hBrush);
    DeleteObject(hBrush);

    if (loadedEmf)
    {
        DrawEMFWithTransform(hBufferDC, loadedEmf, zoomFactor, panX, panY);
    }

    for (const auto& shape : shapes) {
        DrawShape(hBufferDC, shape);
    }

    ReleaseDC(hwnd, hdc);
}

void DrawShape(HDC hdc, Shape shape) {
    HPEN hPen;
    if (shape.type == Tool::Print)
    {
        hPen = CreatePen(PS_SOLID, 2, RGB(255, 0, 0));
    }
    else
    {
        hPen = CreatePen(PS_SOLID, 2, RGB(0, 0, 0));
    }
    HGDIOBJ hOldPen = SelectObject(hdc, hPen);
    HGDIOBJ hOldBrush = SelectObject(hdc, GetStockObject(NULL_BRUSH));

    switch (shape.type) {
    case Tool::Line:
        MoveToEx(hdc, transformX(shape.points[0].x), transformY(shape.points[0].y), NULL);
        LineTo(hdc, transformX(shape.points[1].x), transformY(shape.points[1].y));
        break;

    case Tool::Polyline:
    case Tool::Brush:
        for (int i = 0; i < shape.points.size() - 1; i++)
        {
            MoveToEx(hdc, transformX(shape.points[i].x), transformY(shape.points[i].y), NULL);
            LineTo(hdc, transformX(shape.points[i + 1].x), transformY(shape.points[i + 1].y));
        }
        break;

    case Tool::Rectangle:
        Rectangle(hdc, transformX(shape.points[0].x), transformY(shape.points[0].y),
            transformX(shape.points[1].x), transformY(shape.points[1].y));
        break;


    case Tool::Ellipse:
        Ellipse(hdc, transformX(shape.points[0].x), transformY(shape.points[0].y),
            transformX(shape.points[1].x), transformY(shape.points[1].y));
        break;

    case Tool::Polygon:
        for (int i = 0; i < shape.points.size() - 1; i++)
        {
            MoveToEx(hdc, transformX(shape.points[i].x), transformY(shape.points[i].y), NULL);
            LineTo(hdc, transformX(shape.points[i + 1].x), transformY(shape.points[i + 1].y));
        }
        MoveToEx(hdc, transformX(shape.points[shape.points.size() - 1].x), transformY(shape.points[shape.points.size() - 1].y), NULL);
        LineTo(hdc, transformX(shape.points[0].x), transformY(shape.points[0].y));
        break;
    case Tool::Text:
        TextOut(hdc, transformX(shape.points[0].x), transformY(shape.points[0].y),
            shape.text.c_str(), shape.text.length());
        break;
    case Tool::Print:
        Rectangle(hdc, transformX(shape.points[0].x), transformY(shape.points[0].y),
            transformX(shape.points[1].x), transformY(shape.points[1].y));
        break;
    }

    SelectObject(hdc, hOldPen);
    SelectObject(hdc, hOldBrush);
    DeleteObject(hPen);
}

void AddPoint(int x, int y)
{
    currentPoints.push_back({ x, y });
}

void AddShape()
{
    shapes.push_back({ currentTool, currentPoints, currentText });

    currentPoints.clear();
    currentText.clear();
}

int transformX(int x) { return static_cast<int>((x - CANVAS_X_START) * zoomFactor + panX); }

int transformY(int y) { return static_cast<int>((y - CANVAS_Y_START) * zoomFactor + panY); }

void LoadFromEMF(const std::wstring& filename)
{
    loadedEmf = GetEnhMetaFile(L"file.emf");
    InvalidateRect(hwnd, NULL, FALSE);
}

void SaveToEMF(const std::wstring& filename)
{
    HDC hdcRef = GetDC(hwnd);

    RECT rect;

    int iWidthMM = GetDeviceCaps(hdcRef, HORZSIZE);
    int iHeightMM = GetDeviceCaps(hdcRef, VERTSIZE);
    int iWidthPels = GetDeviceCaps(hdcRef, HORZRES);
    int iHeightPels = GetDeviceCaps(hdcRef, VERTRES);

    rect.left = (0 * iWidthMM * 100) / iWidthPels;
    rect.top = (0 * iHeightMM * 100) / iHeightPels;
    rect.right = ((canvasWidth + CANVAS_X_START - 300) * iWidthMM * 100) / iWidthPels;
    rect.bottom = ((canvasHeight + CANVAS_Y_START - 140) * iHeightMM * 100) / iHeightPels;

    HDC hEnhMetaFile = CreateEnhMetaFile(hdcRef, L"file.emf", &rect, L"My Drawing");
    ReleaseDC(NULL, hdcRef);

    for (const auto& shape : shapes)
    {
        DrawShape(hEnhMetaFile, shape);
    }

    HENHMETAFILE hMetaFileResult = CloseEnhMetaFile(hEnhMetaFile);

    DeleteEnhMetaFile(hMetaFileResult);
}

void DrawEMFWithTransform(HDC hdc, HENHMETAFILE emf, float zoom, int panX, int panY)
{
    XFORM xform;
    xform.eM11 = zoom;
    xform.eM12 = 0.0f;
    xform.eM21 = 0.0f;
    xform.eM22 = zoom;
    xform.eDx = static_cast<FLOAT>(panX);
    xform.eDy = static_cast<FLOAT>(panY);

    SaveDC(hdc);

    SetGraphicsMode(hdc, GM_ADVANCED);
    SetWorldTransform(hdc, &xform);

    RECT rect = { 0, 0, canvasWidth, canvasHeight };
    PlayEnhMetaFile(hdc, emf, &rect);

    RestoreDC(hdc, -1);
}

void Print(HWND hwnd, RECT region)
{
    HDC hdcWindow = GetDC(hwnd);

    HDC hdcMem = CreateCompatibleDC(hdcWindow);
    HBITMAP hBitmap = CreateCompatibleBitmap(hdcWindow, region.right - region.left, region.bottom - region.top);
    SelectObject(hdcMem, hBitmap);

    BitBlt(hdcMem, 0, 0, region.right - region.left, region.bottom - region.top,
        hdcWindow, region.left, region.top, SRCCOPY);

    PRINTDLG pd = { sizeof(pd) };
    pd.Flags = PD_RETURNDC;

    if (PrintDlg(&pd))
    {
        HDC hPrinterDC = pd.hDC;

        DOCINFO di = { sizeof(DOCINFO) };
        di.lpszDocName = L"Window Area Print";

        if (StartDocW(hPrinterDC, &di) > 0)
        {
            if (StartPage(hPrinterDC) > 0)
            {
                int printWidth = GetDeviceCaps(hPrinterDC, HORZRES);
                int printHeight = GetDeviceCaps(hPrinterDC, VERTRES);


                float scaleX = (float)printWidth / (region.right - region.left);
                float scaleY = (float)printHeight / (region.bottom - region.top);
                float scale = min(scaleX, scaleY);

                int outputWidth = (int)((region.right - region.left) * scale);
                int outputHeight = (int)((region.bottom - region.top) * scale);
                int xOffset = (printWidth - outputWidth) / 2;
                int yOffset = (printHeight - outputHeight) / 2;

                SetStretchBltMode(hPrinterDC, HALFTONE);

                StretchBlt(hPrinterDC, xOffset, yOffset, outputWidth, outputHeight,
                    hdcMem, 0, 0, region.right - region.left, region.bottom - region.top, SRCCOPY);

                EndPage(hPrinterDC);
            }
            EndDoc(hPrinterDC);
        }
        DeleteDC(hPrinterDC);
    }

    DeleteObject(hBitmap);
    DeleteDC(hdcMem);
    ReleaseDC(hwnd, hdcWindow);
}
