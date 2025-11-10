#define UNICODE
#include <windows.h>
#include <tlhelp32.h>
#include <string>
#include <iostream>

static const wchar_t* kProcessXName = L"Paint1.exe";               // процесс X
static const wchar_t* kProcessYPath = L"C:\\Users\\sasha\\BSUIR\\5 semester\\SP\\lab 5\\Lab3_4.exe"; // Y


// Поиск PID процесса по имени
DWORD FindProcessPidByName(const wchar_t* name) {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return 0;

    PROCESSENTRY32W pe = { sizeof(pe) };
    DWORD foundPid = 0;
    if (Process32FirstW(snap, &pe)) {
        do {
            if (_wcsicmp(pe.szExeFile, name) == 0) {
                foundPid = pe.th32ProcessID;
                break;
            }
        } while (Process32NextW(snap, &pe));
    }
    CloseHandle(snap);
    return foundPid;
}

int wmain() {
    std::wcout << L"Мониторинг процесса " << kProcessXName << L"..." << std::endl;

    HANDLE hX = nullptr; // дескриптор X
    HANDLE hY = nullptr; // дескриптор Y

    while (true) {
        if (!hX) {
            // ищем X
            DWORD pid = FindProcessPidByName(kProcessXName);
            if (pid) {
                hX = OpenProcess(SYNCHRONIZE, FALSE, pid);
                if (hX) {

                    // запускаем Y
                    STARTUPINFOW si = { sizeof(si) };
                    PROCESS_INFORMATION pi = {};
                    if (CreateProcessW(
                        kProcessYPath, nullptr, nullptr, nullptr, FALSE,
                        0, nullptr, nullptr, &si, &pi))
                    {
                        hY = pi.hProcess;
                        CloseHandle(pi.hThread);
                    }
                }
            }
        }
        else {
            // ждём завершения X
            DWORD wait = WaitForSingleObject(hX, 500);
            if (wait == WAIT_OBJECT_0) {

                // закрываем Y
                if (hY) {
                    TerminateProcess(hY, 0);
                    CloseHandle(hY);
                    hY = nullptr;
                }

                CloseHandle(hX);
                hX = nullptr;
            }
        }

        Sleep(200); // чтобы не грузить процессор
    }

    return 0;
}
