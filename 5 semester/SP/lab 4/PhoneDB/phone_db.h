#pragma once
#ifdef _WIN32
#ifdef BUILD_DB_DLL
#define DBAPI __declspec(dllexport)
#else
#define DBAPI __declspec(dllimport)
#endif
#else
#define DBAPI
#endif

struct PhoneRecord {
    char lastName[50];
    char firstName[50];
    char middleName[50];
    char phone[20];
    char street[50];
    char house[10];
    char building[10];
    char apartment[10];
};

enum PhoneRecordAttr {
    LastName,
    FirstName,
    MiddleName,
    Phone,
    Street,
    House,
    Building,
    Apartment
};

extern "C" {
    DBAPI bool open(const char* path);
    DBAPI void close();

    DBAPI PhoneRecord* search_by_query(const PhoneRecordAttr field, const char* query, int* outCount);
}

