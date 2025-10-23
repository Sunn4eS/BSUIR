#include <windows.h>
#include <iostream>
#include <string>
#include <cstdio>

#define SHARED_MEM_NAME L"PhoneBookSharedMemory"
#define MUTEX_NAME L"PhoneBookMutex"
#define MAX_RECORDS 1000

#pragma data_seg(".shared")
HANDLE hMapFile = nullptr;
LPVOID pBuffer = nullptr;
#pragma data_seg()
#pragma comment(linker, "/SECTION:.shared,RWS")

struct Record {
    char phone[20];
    char lastName[50];
    char firstName[50];
    char middleName[50];
    char street[50];
    char house[10];
    char building[10];
    char apartment[10];
};

struct SharedData {
    int count;
    Record records[MAX_RECORDS];
};

extern "C" {
    __declspec(dllexport) bool InitializeDatabase(const char* filename);
    __declspec(dllexport) void SearchRecords(const char* field, const char* value, void (*callback)(const char*));
}

bool InitializeDatabase(const char* filename) {
    HANDLE hMutex = CreateMutexW(nullptr, FALSE, MUTEX_NAME);
    WaitForSingleObject(hMutex, INFINITE);

    hMapFile = CreateFileMappingW(INVALID_HANDLE_VALUE, nullptr, PAGE_READWRITE, 0, sizeof(SharedData), SHARED_MEM_NAME);
    if (!hMapFile) {
        ReleaseMutex(hMutex);
        return false;
    }

    pBuffer = MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(SharedData));
    if (!pBuffer) {
        CloseHandle(hMapFile);
        ReleaseMutex(hMutex);
        return false;
    }

    SharedData* data = new(pBuffer) SharedData();
    data->count = 0;

    FILE* file;
    if (fopen_s(&file, filename, "r") != 0) {
        ReleaseMutex(hMutex);
        return false;
    }

    char line[256];
    while (fgets(line, sizeof(line), file) && data->count < MAX_RECORDS) {
        Record r;
        if (sscanf_s(line, "%19[^,],%49[^,],%49[^,],%49[^,],%49[^,],%9[^,],%9[^,],%9[^,]",
            r.phone, (unsigned)_countof(r.phone),
            r.lastName, (unsigned)_countof(r.lastName),
            r.firstName, (unsigned)_countof(r.firstName),
            r.middleName, (unsigned)_countof(r.middleName),
            r.street, (unsigned)_countof(r.street),
            r.house, (unsigned)_countof(r.house),
            r.building, (unsigned)_countof(r.building),
            r.apartment, (unsigned)_countof(r.apartment)) == 8) {
            data->records[data->count] = r;
            data->count++;
        }
    }
    fclose(file);
    ReleaseMutex(hMutex);
    return true;
}

void SearchRecords(const char* field, const char* value, void (*callback)(const char*)) {
    HANDLE hMutex = OpenMutexW(MUTEX_ALL_ACCESS, FALSE, MUTEX_NAME);
    if (!hMutex) return;

    WaitForSingleObject(hMutex, INFINITE);

    SharedData* data = reinterpret_cast<SharedData*>(pBuffer);
    for (int i = 0; i < data->count; i++) {
        const Record& r = data->records[i];
        const char* fieldValue = nullptr;

        if (strcmp(field, "phone") == 0) fieldValue = r.phone;
        else if (strcmp(field, "lastName") == 0) fieldValue = r.lastName;
        else if (strcmp(field, "firstName") == 0) fieldValue = r.firstName;
        else if (strcmp(field, "middleName") == 0) fieldValue = r.middleName;
        else if (strcmp(field, "street") == 0) fieldValue = r.street;
        else if (strcmp(field, "house") == 0) fieldValue = r.house;
        else if (strcmp(field, "building") == 0) fieldValue = r.building;
        else if (strcmp(field, "apartment") == 0) fieldValue = r.apartment;

        if (fieldValue && strstr(fieldValue, value)) {
            char result[256];
            sprintf_s(result, sizeof(result), "%s, %s, %s, %s, %s, %s, %s, %s",
                r.phone, r.lastName, r.firstName, r.middleName,
                r.street, r.house, r.building, r.apartment);
            callback(result);
        }
    }
    ReleaseMutex(hMutex);
    CloseHandle(hMutex);
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
    case DLL_PROCESS_DETACH:
        if (pBuffer) UnmapViewOfFile(pBuffer);
        if (hMapFile) CloseHandle(hMapFile);
        break;
    }
    return TRUE;
}