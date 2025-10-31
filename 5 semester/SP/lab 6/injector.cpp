// injector.cpp
#include <windows.h>
#include <stdio.h>
#include <tlhelp32.h>
#include <string>
#include <iostream>

bool InjectDLL(DWORD processId, const char* dllPath) {
    HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, processId);
    if (!hProcess) {
        std::cout << "Failed to open process. Error: " << GetLastError() << std::endl;
        return false;
    }

    // Выделяем память в целевом процессе
    LPVOID pRemoteMemory = VirtualAllocEx(hProcess, NULL, strlen(dllPath) + 1,
        MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (!pRemoteMemory) {
        std::cout << "Failed to allocate memory. Error: " << GetLastError() << std::endl;
        CloseHandle(hProcess);
        return false;
    }

    // Записываем путь к DLL
    if (!WriteProcessMemory(hProcess, pRemoteMemory, dllPath, strlen(dllPath) + 1, NULL)) {
        std::cout << "Failed to write memory. Error: " << GetLastError() << std::endl;
        VirtualFreeEx(hProcess, pRemoteMemory, 0, MEM_RELEASE);
        CloseHandle(hProcess);
        return false;
    }

    // Создаем удаленный поток
    HMODULE hKernel32 = GetModuleHandleA("kernel32.dll");
    LPTHREAD_START_ROUTINE pLoadLibrary = (LPTHREAD_START_ROUTINE)GetProcAddress(hKernel32, "LoadLibraryA");

    HANDLE hRemoteThread = CreateRemoteThread(hProcess, NULL, 0, pLoadLibrary, pRemoteMemory, 0, NULL);
    if (!hRemoteThread) {
        std::cout << "Failed to create remote thread. Error: " << GetLastError() << std::endl;
        VirtualFreeEx(hProcess, pRemoteMemory, 0, MEM_RELEASE);
        CloseHandle(hProcess);
        return false;
    }

    // Ждем завершения
    WaitForSingleObject(hRemoteThread, INFINITE);

    // Освобождаем ресурсы
    CloseHandle(hRemoteThread);
    VirtualFreeEx(hProcess, pRemoteMemory, 0, MEM_RELEASE);
    CloseHandle(hProcess);

    std::cout << "DLL injected successfully!" << std::endl;
    return true;
}

int main() {
    const char* dllPath = "HookDll.dll"; // Убедитесь, что DLL в той же папке

    // Запускаем тестовое приложение
    STARTUPINFO si = { sizeof(si) };
    PROCESS_INFORMATION pi;

    if (!CreateProcessW(
        L"TestApp.exe",  // Ваше тестовое приложение
        NULL, NULL, NULL, FALSE,
        CREATE_SUSPENDED, NULL, NULL, &si, &pi)) {
        std::cout << "Failed to create process. Error: " << GetLastError() << std::endl;
        return 1;
    }

    std::cout << "Process created with PID: " << pi.dwProcessId << std::endl;

    // Инжектируем DLL
    if (!InjectDLL(pi.dwProcessId, dllPath)) {
        TerminateProcess(pi.hProcess, 0);
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
        return 1;
    }

    // Возобновляем выполнение
    ResumeThread(pi.hThread);

    // Ждем завершения
    WaitForSingleObject(pi.hProcess, INFINITE);

    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    std::cout << "Application completed." << std::endl;
    return 0;
}