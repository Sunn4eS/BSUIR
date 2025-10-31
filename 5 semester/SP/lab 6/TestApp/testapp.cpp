// testapp.cpp
#include <windows.h>
#include <fstream>
#include <iostream>

int main() {
    std::cout << "Test application started!" << std::endl;
    
    // 1. CreateFile/WriteFile
    HANDLE hFile = CreateFile(L"test1.txt", GENERIC_WRITE, 0, NULL,
        CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile != INVALID_HANDLE_VALUE) {
        const char* data = "Hello via CreateFile/WriteFile!";
        DWORD bytesWritten;
        WriteFile(hFile, data, (DWORD)strlen(data), &bytesWritten, NULL);
        CloseHandle(hFile);
        std::cout << "Created test1.txt" << std::endl;
    }
    
    // 2. CRT fopen/fwrite
    FILE* file;
    fopen_s(&file, "test2.txt", "wb");
    if (file) {
        const char* data = "Hello via fopen/fwrite!";
        fwrite(data, 1, strlen(data), file);
        fclose(file);
        std::cout << "Created test2.txt" << std::endl;
    }
    
    // 3. C++ ofstream
    std::ofstream ofs("test3.txt");
    if (ofs) {
        ofs << "Hello via ofstream!" << std::endl;
        ofs.close();
        std::cout << "Created test3.txt" << std::endl;
    }
    
    std::cout << "Test application finished!" << std::endl;
    return 0;
}