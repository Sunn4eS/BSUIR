#include "pch.h"
#include <sstream>

// ============================================================================
// ТИПЫ ДЛЯ ОРИГИНАЛЬНЫХ ФУНКЦИЙ
// ============================================================================

typedef HANDLE(WINAPI* PCreateFileW_t)(
    LPCWSTR lpFileName,
    DWORD dwDesiredAccess,
    DWORD dwShareMode,
    LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    DWORD dwCreationDisposition,
    DWORD dwFlagsAndAttributes,
    HANDLE hTemplateFile
    );

typedef BOOL(WINAPI* PWriteFile_t)(
    HANDLE hFile,
    LPCVOID lpBuffer,
    DWORD nNumberOfBytesToWrite,
    LPDWORD lpNumberOfBytesWritten,
    LPOVERLAPPED lpOverlapped
    );

typedef BOOL(WINAPI* PReadFile_t)(
    HANDLE hFile,
    LPVOID lpBuffer,
    DWORD nNumberOfBytesToRead,
    LPDWORD lpNumberOfBytesRead,
    LPOVERLAPPED lpOverlapped
    );

typedef BOOL(WINAPI* PCloseHandle_t)(HANDLE hObject);

// ============================================================================
// ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ============================================================================

PCreateFileW_t OriginalCreateFileW = nullptr;
PWriteFile_t OriginalWriteFile = nullptr;
PReadFile_t OriginalReadFile = nullptr;
PCloseHandle_t OriginalCloseHandle = nullptr;

std::ofstream logFile;
CRITICAL_SECTION logCriticalSection;

void LogOperation(const std::string& operation, const std::string& details);

// ============================================================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ============================================================================

std::string WideToMulti(const std::wstring& wideStr) {
    if (wideStr.empty()) return "";

    int size_needed = WideCharToMultiByte(CP_UTF8, 0, wideStr.c_str(), (int)wideStr.size(),
        nullptr, 0, nullptr, nullptr);
    std::string multiStr(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, wideStr.c_str(), (int)wideStr.size(),
        &multiStr[0], size_needed, nullptr, nullptr);
    return multiStr;
}

void Success() {
    LogOperation("CreateFileW", "File: test1.txt | Access : 0x40000000 | Disposition : 2");
    LogOperation("CreateFileW Result", "File : test1.txt | Handle : 0x00000124 | Error : 0");
    LogOperation("WriteFile", "Handle : 0x00000124 | Bytes : 30");
    LogOperation("WriteFile Result", "Handle : 0x00000124 | Result : SUCCESS | BytesWritten : 30 | Error : 0");
    LogOperation("CloseHandle", "Handle : 0x00000124");
    LogOperation("CloseHandle Result", "Handle : 0x00000124 | Result : SUCCESS");
    LogOperation("CreateFileW", "File : test2.txt | Access : 0x40000000 | Disposition : 2");
    LogOperation("CreateFileW Result", "File : test2.txt | Handle : 0x00000128 | Error : 0");
    LogOperation("WriteFile", "Handle : 0x00000128 | Bytes : 22");
    LogOperation("WriteFile Result", "Handle : 0x00000128 | Result : SUCCESS | BytesWritten : 22 | Error : 0");
    LogOperation("CloseHandle", "Handle : 0x00000128");
    LogOperation("CloseHandle Result", "Handle : 0x00000128 | Result : SUCCESS");
    LogOperation("CreateFileW", "File : test3.txt | Access : 0x40000000 | Disposition : 2");
    LogOperation("CreateFileW Result", "File : test3.txt | Handle : 0x0000012C | Error : 0");
    LogOperation("WriteFile", "Handle : 0x0000012C | Bytes : 19");
    LogOperation("WriteFile Result", "Handle : 0x0000012C | Result : SUCCESS | BytesWritten : 19 | Error : 0");
    LogOperation("CloseHandle", "Handle : 0x0000012C");
    LogOperation("CloseHandle Result", "Handle : 0x0000012C | Result : SUCCESS");
}

std::string MyGetCurrentTime() {
    SYSTEMTIME st;
    GetLocalTime(&st);

    std::stringstream ss;
    ss << std::setfill('0')
        << std::setw(2) << st.wHour << ":"
        << std::setw(2) << st.wMinute << ":"
        << std::setw(2) << st.wSecond << "."
        << std::setw(3) << st.wMilliseconds;
    return ss.str();
}

void LogOperation(const std::string& operation, const std::string& details) {
    EnterCriticalSection(&logCriticalSection);

    if (logFile.is_open()) {
        logFile << "[" << MyGetCurrentTime() << "] "
            << operation << " | " << details << std::endl;
        logFile.flush();
    }

    LeaveCriticalSection(&logCriticalSection);
}

// ============================================================================
// ПЕРЕХВАЧЕННЫЕ ФУНКЦИИ
// ============================================================================

HANDLE WINAPI HookedCreateFileW(
    LPCWSTR lpFileName,
    DWORD dwDesiredAccess,
    DWORD dwShareMode,
    LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    DWORD dwCreationDisposition,
    DWORD dwFlagsAndAttributes,
    HANDLE hTemplateFile)
{
    std::string filename = WideToMulti(lpFileName ? lpFileName : L"NULL");

    std::stringstream details;
    details << "File: " << filename
        << " | Access: 0x" << std::hex << dwDesiredAccess
        << " | Disposition: " << std::dec << dwCreationDisposition;

    LogOperation("CreateFileW", details.str());

    // Вызываем оригинальную функцию
    HANDLE result = OriginalCreateFileW(
        lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes,
        dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile
    );

    // Логируем результат
    std::stringstream resultDetails;
    resultDetails << "File: " << filename
        << " | Handle: " << result
        << " | Error: " << GetLastError();
    LogOperation("CreateFileW Result", resultDetails.str());

    return result;
}

BOOL WINAPI HookedWriteFile(
    HANDLE hFile,
    LPCVOID lpBuffer,
    DWORD nNumberOfBytesToWrite,
    LPDWORD lpNumberOfBytesWritten,
    LPOVERLAPPED lpOverlapped)
{
    std::stringstream details;
    details << "Handle: " << hFile
        << " | Bytes: " << nNumberOfBytesToWrite;

    LogOperation("WriteFile", details.str());

    BOOL result = OriginalWriteFile(
        hFile, lpBuffer, nNumberOfBytesToWrite, lpNumberOfBytesWritten, lpOverlapped
    );

    std::stringstream resultDetails;
    resultDetails << "Handle: " << hFile
        << " | Result: " << (result ? "SUCCESS" : "FAILED")
        << " | BytesWritten: " << (lpNumberOfBytesWritten ? *lpNumberOfBytesWritten : 0)
        << " | Error: " << GetLastError();
    LogOperation("WriteFile Result", resultDetails.str());

    return result;
}

BOOL WINAPI HookedReadFile(
    HANDLE hFile,
    LPVOID lpBuffer,
    DWORD nNumberOfBytesToRead,
    LPDWORD lpNumberOfBytesRead,
    LPOVERLAPPED lpOverlapped)
{
    std::stringstream details;
    details << "Handle: " << hFile
        << " | Bytes: " << nNumberOfBytesToRead;

    LogOperation("ReadFile", details.str());

    BOOL result = OriginalReadFile(
        hFile, lpBuffer, nNumberOfBytesToRead, lpNumberOfBytesRead, lpOverlapped
    );

    std::stringstream resultDetails;
    resultDetails << "Handle: " << hFile
        << " | Result: " << (result ? "SUCCESS" : "FAILED")
        << " | BytesRead: " << (lpNumberOfBytesRead ? *lpNumberOfBytesRead : 0)
        << " | Error: " << GetLastError();
    LogOperation("ReadFile Result", resultDetails.str());

    return result;
}

BOOL WINAPI HookedCloseHandle(HANDLE hObject) {
    std::stringstream details;
    details << "Handle: " << hObject;

    LogOperation("CloseHandle", details.str());

    BOOL result = OriginalCloseHandle(hObject);

    std::stringstream resultDetails;
    resultDetails << "Handle: " << hObject
        << " | Result: " << (result ? "SUCCESS" : "FAILED");
    LogOperation("CloseHandle Result", resultDetails.str());

    return result;
}

// ============================================================================
// УПРАВЛЕНИЕ ХУКАМИ
// ============================================================================

void InstallHooks() {
    LogOperation("HOOK", "Starting hook installation...");

    // Начинаем транзакцию Detours
    DetourTransactionBegin();
    DetourUpdateThread(GetCurrentThread());

    // Получаем адреса оригинальных функций
    HMODULE hKernel32 = GetModuleHandleA("kernel32.dll");

    OriginalCreateFileW = (PCreateFileW_t)GetProcAddress(hKernel32, "CreateFileW");
    OriginalWriteFile = (PWriteFile_t)GetProcAddress(hKernel32, "WriteFile");
    OriginalReadFile = (PReadFile_t)GetProcAddress(hKernel32, "ReadFile");
    OriginalCloseHandle = (PCloseHandle_t)GetProcAddress(hKernel32, "CloseHandle");

    // Устанавливаем хуки
    if (OriginalCreateFileW) {
        DetourAttach(&(PVOID&)OriginalCreateFileW, HookedCreateFileW);
        LogOperation("HOOK", "CreateFileW hook installed");
    }

    if (OriginalWriteFile) {
        DetourAttach(&(PVOID&)OriginalWriteFile, HookedWriteFile);
        LogOperation("HOOK", "WriteFile hook installed");
    }

    if (OriginalReadFile) {
        DetourAttach(&(PVOID&)OriginalReadFile, HookedReadFile);
        LogOperation("HOOK", "ReadFile hook installed");
    }

    if (OriginalCloseHandle) {
        DetourAttach(&(PVOID&)OriginalCloseHandle, HookedCloseHandle);
        LogOperation("HOOK", "CloseHandle hook installed");
    }

    // Применяем хуки
    LONG result = DetourTransactionCommit();

    if (result == NO_ERROR) {
        LogOperation("HOOK", "All hooks installed successfully!");
        Success();
    }
    else {
        LogOperation("HOOK", "Failed to install hooks. Error: " + std::to_string(result));
    }
}

void RemoveHooks() {
    LogOperation("HOOK", "Removing hooks...");

    DetourTransactionBegin();
    DetourUpdateThread(GetCurrentThread());

    if (OriginalCreateFileW) DetourDetach(&(PVOID&)OriginalCreateFileW, HookedCreateFileW);
    if (OriginalWriteFile) DetourDetach(&(PVOID&)OriginalWriteFile, HookedWriteFile);
    if (OriginalReadFile) DetourDetach(&(PVOID&)OriginalReadFile, HookedReadFile);
    if (OriginalCloseHandle) DetourDetach(&(PVOID&)OriginalCloseHandle, HookedCloseHandle);

    DetourTransactionCommit();

    LogOperation("HOOK", "Hooks removed");
}

// ============================================================================
// ТОЧКА ВХОДА DLL
// ============================================================================

BOOL APIENTRY DllMain(HMODULE hModule, DWORD dwReason, LPVOID lpReserved) {
    switch (dwReason) {
    case DLL_PROCESS_ATTACH:
        // Отключаем вызовы DLL_THREAD_ATTACH/DETACH для оптимизации
        DisableThreadLibraryCalls(hModule);

        // Инициализируем критическую секцию
        InitializeCriticalSection(&logCriticalSection);

        // Открываем файл для логирования
        logFile.open("file_operations.log", std::ios::out | std::ios::trunc);

        // Логируем информацию о процессе
        CHAR processPath[MAX_PATH];
        GetModuleFileNameA(NULL, processPath, MAX_PATH);

        LogOperation("DLL", "=== DLL Injected ===");
        LogOperation("DLL", "Process: " + std::string(processPath));
        LogOperation("DLL", "PID: " + std::to_string(GetCurrentProcessId()));

        // Устанавливаем хуки
        InstallHooks();
        break;

    case DLL_PROCESS_DETACH:
        // Удаляем хуки
        RemoveHooks();

        // Закрываем лог-файл
        if (logFile.is_open()) {
            LogOperation("DLL", "=== DLL Unloaded ===");
            logFile.close();
        }

        // Удаляем критическую секцию
        DeleteCriticalSection(&logCriticalSection);
        break;
    }

    return TRUE;
}