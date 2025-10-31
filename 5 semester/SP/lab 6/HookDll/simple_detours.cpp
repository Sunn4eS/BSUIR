#include "pch.h"
#include "simple_detours.h"

#include <vector>

// ============================================================================
// УПРОЩЕННАЯ РЕАЛИЗАЦИЯ DETOURS
// ============================================================================

static CRITICAL_SECTION g_detourCs;
static BOOL g_detourInitialized = FALSE;

struct HOOK_INFO {
    PVOID* ppOriginal;
    PVOID pDetour;
    PVOID pTrampoline;
};

static std::vector<HOOK_INFO> g_hooks;

void InitializeDetours() {
    if (!g_detourInitialized) {
        InitializeCriticalSection(&g_detourCs);
        g_detourInitialized = TRUE;
    }
}

LONG WINAPI DetourTransactionBegin() {
    InitializeDetours();
    return NO_ERROR;
}

LONG WINAPI DetourUpdateThread(HANDLE hThread) {
    // В упрощенной версии просто возвращаем успех
    return NO_ERROR;
}

LONG WINAPI DetourAttach(PVOID* ppPointer, PVOID pDetour) {
    if (ppPointer == NULL || pDetour == NULL) {
        return ERROR_INVALID_PARAMETER;
    }

    EnterCriticalSection(&g_detourCs);

    // Сохраняем информацию о хуке
    HOOK_INFO hook;
    hook.ppOriginal = ppPointer;
    hook.pDetour = pDetour;
    hook.pTrampoline = *ppPointer; // Сохраняем оригинальный адрес

    // Подменяем указатель на нашу функцию
    DWORD oldProtect;
    if (VirtualProtect(ppPointer, sizeof(PVOID), PAGE_READWRITE, &oldProtect)) {
        *ppPointer = pDetour;
        VirtualProtect(ppPointer, sizeof(PVOID), oldProtect, &oldProtect);
    }

    g_hooks.push_back(hook);

    LeaveCriticalSection(&g_detourCs);
    return NO_ERROR;
}

LONG WINAPI DetourDetach(PVOID* ppPointer, PVOID pDetour) {
    EnterCriticalSection(&g_detourCs);

    for (auto it = g_hooks.begin(); it != g_hooks.end(); ++it) {
        if (it->ppOriginal == ppPointer && it->pDetour == pDetour) {
            // Восстанавливаем оригинальный указатель
            DWORD oldProtect;
            if (VirtualProtect(ppPointer, sizeof(PVOID), PAGE_READWRITE, &oldProtect)) {
                *ppPointer = it->pTrampoline;
                VirtualProtect(ppPointer, sizeof(PVOID), oldProtect, &oldProtect);
            }

            // Удаляем хук из вектора
            g_hooks.erase(it);

            LeaveCriticalSection(&g_detourCs);
            return NO_ERROR;
        }
    }

    LeaveCriticalSection(&g_detourCs);
    return ERROR_NOT_FOUND;
}

LONG WINAPI DetourTransactionCommit() {
    // В упрощенной версии все уже сделано в DetourAttach
    return NO_ERROR;
}

LONG WINAPI DetourTransactionAbort() {
    // В упрощенной версии не реализовано откатывание транзакций
    return NO_ERROR;
}