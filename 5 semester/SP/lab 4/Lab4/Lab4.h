#pragma once

#include "framework.h"
#include "../PhoneDB/phone_db.h"

#define IDC_SEARCH_FIELD 101
#define IDC_SEARCH_VALUE 102
#define IDC_SEARCH_BUTTON 103
#define IDC_RESULTS_LIST 104
#define IDC_FIELD_COMBO 105

typedef bool(*DBFOPEN)(const char*);
typedef void(*DBFCLOSE)();
typedef PhoneRecord*(*DBFSEARCH)(const PhoneRecordAttr, const char*, int*);

HWND g_hSearchField, g_hSearchValue, g_hSearchButton, g_hResultsList, g_hFieldCombo;

HMODULE hm_db = nullptr;
DBFOPEN DBFOpen = nullptr;
DBFCLOSE DBFClsoe = nullptr;
DBFSEARCH DBFSearch = nullptr;

struct ResultInfo {
    PhoneRecord* records;
    int size;
};

struct ComboItem {
    const WCHAR* displayName;
    const PhoneRecordAttr value;
};

ComboItem comboFields[] = {

    { L"Фамилия", PhoneRecordAttr::LastName },
    { L"Имя", PhoneRecordAttr::FirstName },
    { L"Очество", PhoneRecordAttr::MiddleName },
    { L"Телефон", PhoneRecordAttr::Phone},
    { L"Улица", PhoneRecordAttr::Street },
    { L"Дом", PhoneRecordAttr::House },
    { L"Корпус", PhoneRecordAttr::Building },
    { L"Квартира", PhoneRecordAttr::Apartment }
};

ResultInfo resultInfo;