#pragma once
#include <windows.h>
#include <queue>
#include <functional>
#include <vector>
#include <mutex>
#include <condition_variable>

class ThreadPool {
public:
    ThreadPool(size_t threadCount);
    ~ThreadPool();

    void Enqueue(std::function<void()> task);

private:
    static DWORD WINAPI ThreadProc(LPVOID lpParam);

    void WorkerLoop();

    std::vector<HANDLE> threads;
    std::queue<std::function<void()>> tasks;
    std::mutex queueMutex;
    std::condition_variable_any cv;
    bool stop;
};
