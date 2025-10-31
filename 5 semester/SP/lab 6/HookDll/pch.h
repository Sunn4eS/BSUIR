#ifndef PCH_H
#define PCH_H

// Добавляйте сюда заголовочные файлы для предкомпиляции
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <fstream>
#include <string>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <vector>

// Используем нашу простую версию Detours
#include "simple_detours.h"

#endif // PCH_H