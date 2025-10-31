#ifndef SIMPLE_DETOURS_H
#define SIMPLE_DETOURS_H

#ifdef __cplusplus
extern "C" {
#endif

	// Простые макросы без зависимостей
#define DETOUR_TRACE(x) 
#define DETOUR_BREAK() 
#define DETOUR_TRAMPOLINE(p1, p2)

// Прототипы функций
	LONG WINAPI DetourTransactionBegin();
	LONG WINAPI DetourUpdateThread(HANDLE hThread);
	LONG WINAPI DetourAttach(PVOID* ppPointer, PVOID pDetour);
	LONG WINAPI DetourDetach(PVOID* ppPointer, PVOID pDetour);
	LONG WINAPI DetourTransactionCommit();
	LONG WINAPI DetourTransactionAbort();

#ifdef __cplusplus
}
#endif

#endif // SIMPLE_DETOURS_H