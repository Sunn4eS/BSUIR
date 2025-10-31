#include "pch.h"
#include "phone_db.h"
#include <fstream>
#include <sstream>
#include <vector>
#include <mutex>
#include "ThreadPool.h"

#define SHARED_MEM_NAME L"PHONE_DB_SHARED_MEMORY"
#define MAX_RECORDS 1000

HANDLE hMapFile = nullptr;
LPVOID pBuffer = nullptr;

struct SharedData {
    int count;
    PhoneRecord records[MAX_RECORDS];
};

bool initData(const char* path) {
    SharedData* data = new(pBuffer) SharedData();
    data->count = 0;

    std::ifstream in(path);
    if (!in.is_open()) return false;

    std::string line;
    while (std::getline(in, line) && data->count < MAX_RECORDS) {
        std::stringstream ss(line);
        std::string field;
        PhoneRecord r;

        auto copyField = [](const std::string& src, char* dst, size_t size) {
            strncpy_s(dst, size, src.c_str(), _TRUNCATE);
        };

        std::getline(ss, field, ',');
        copyField(field, r.lastName, sizeof(r.lastName));

        std::getline(ss, field, ',');
        copyField(field, r.firstName, sizeof(r.firstName));

        std::getline(ss, field, ',');
        copyField(field, r.middleName, sizeof(r.middleName));

        std::getline(ss, field, ',');
        copyField(field, r.phone, sizeof(r.phone));

        std::getline(ss, field, ',');
        copyField(field, r.street, sizeof(r.street));

        std::getline(ss, field, ',');
        copyField(field, r.house, sizeof(r.house));

        std::getline(ss, field, ',');
        copyField(field, r.building, sizeof(r.building));

        std::getline(ss, field, ',');
        copyField(field, r.apartment, sizeof(r.apartment));

        data->records[data->count++] = r;
    }

    return true;
}

bool open(const char* path)
{
    hMapFile = CreateFileMappingW(INVALID_HANDLE_VALUE, nullptr, PAGE_READWRITE, 0, sizeof(SharedData), SHARED_MEM_NAME);
    if (!hMapFile) {
        return false;
    }

    bool isCreated = (GetLastError() == ERROR_ALREADY_EXISTS);

    pBuffer = MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(SharedData));
    if (!pBuffer) {
        CloseHandle(hMapFile);
        return false;
    }

    return isCreated ? true : initData(path);
}

void close()
{
    if (pBuffer) UnmapViewOfFile(pBuffer);
    if (hMapFile) CloseHandle(hMapFile);
}

//PhoneRecord* search_by_query(const PhoneRecordAttr field, const char* query, int* outCount)
//{
//    if (!pBuffer || !query || !outCount) return nullptr;
//
//    SharedData* data = reinterpret_cast<SharedData*>(pBuffer);
//
//    static PhoneRecord results[MAX_RECORDS];
//    int count = 0;
//
//    for (int i = 0; i < data->count; i++) {
//        const PhoneRecord& r = data->records[i];
//        const char* fieldValue = nullptr;
//
//        switch (field) {
//        case LastName:   fieldValue = r.lastName; break;
//        case FirstName:  fieldValue = r.firstName; break;
//        case MiddleName: fieldValue = r.middleName; break;
//        case Phone:      fieldValue = r.phone; break;
//        case Street:     fieldValue = r.street; break;
//        case House:      fieldValue = r.house; break;
//        case Building:   fieldValue = r.building; break;
//        case Apartment:  fieldValue = r.apartment; break;
//        default: fieldValue = nullptr; break;
//        }
//
//        if (fieldValue && strstr(fieldValue, query)) {
//            if (count < MAX_RECORDS) {
//                results[count++] = r;
//            }
//        }
//    }
//
//    *outCount = count;
//    return count > 0 ? results : nullptr;
//}

PhoneRecord* search_by_query(const PhoneRecordAttr field, const char* query, int* outCount) {
    if (!pBuffer || !query || !outCount) return nullptr;

    SharedData* data = reinterpret_cast<SharedData*>(pBuffer);
    const int totalRecords = data->count;

    if (totalRecords == 0) {
        *outCount = 0;
        return nullptr;
    }

    std::vector<PhoneRecord> results;
    std::mutex resultsMutex;

    ThreadPool pool(max(std::thread::hardware_concurrency() / 2, 1));

    const int chunkSize = 100; // можно настроить
    std::vector<std::future<void>> futures;

    for (int start = 0; start < totalRecords; start += chunkSize) {
        
        int end = min(start + chunkSize, totalRecords);

        futures.push_back(pool.addTask([&, start, end]() {
            std::vector<PhoneRecord> localResults;

            for (int i = start; i < end; ++i) {
                const PhoneRecord& r = data->records[i];
                const char* fieldValue = nullptr;

                switch (field) {
                case LastName:   fieldValue = r.lastName; break;
                case FirstName:  fieldValue = r.firstName; break;
                case MiddleName: fieldValue = r.middleName; break;
                case Phone:      fieldValue = r.phone; break;
                case Street:     fieldValue = r.street; break;
                case House:      fieldValue = r.house; break;
                case Building:   fieldValue = r.building; break;
                case Apartment:  fieldValue = r.apartment; break;
                }

                if (fieldValue && strstr(fieldValue, query)) {
                    localResults.push_back(r);
                }
            }

            if (!localResults.empty()) {
                std::lock_guard<std::mutex> lock(resultsMutex);
                results.insert(results.end(), localResults.begin(), localResults.end());
            }
            }));
    }

    for (auto& f : futures) f.get();

    if (results.empty()) {
        *outCount = 0;
        return nullptr;
    }

    PhoneRecord* outArray = new PhoneRecord[results.size()];
    std::copy(results.begin(), results.end(), outArray);
    *outCount = static_cast<int>(results.size());

    return outArray;
}