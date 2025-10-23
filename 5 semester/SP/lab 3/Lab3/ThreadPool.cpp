#include "ThreadPool.h"

ThreadPool::ThreadPool(size_t threadCount) : stop(false) {
    for (size_t i = 0; i < threadCount; ++i) {
        HANDLE hThread = CreateThread(
            nullptr, 0, ThreadProc, this, 0, nullptr
        );
        if (hThread) {
            threads.push_back(hThread);
        }
    }
}

ThreadPool::~ThreadPool() {
    {
        std::lock_guard<std::mutex> lock(queueMutex);
        stop = true;
    }
    cv.notify_all();

    for (HANDLE hThread : threads) {
        WaitForSingleObject(hThread, INFINITE);
        CloseHandle(hThread);
    }
}

void ThreadPool::Enqueue(std::function<void()> task) {
    {
        std::lock_guard<std::mutex> lock(queueMutex);
        tasks.push(task);
    }
    cv.notify_one();
}

DWORD WINAPI ThreadPool::ThreadProc(LPVOID lpParam) {
    ThreadPool* pool = static_cast<ThreadPool*>(lpParam);
    pool->WorkerLoop();
    return 0;
}

void ThreadPool::WorkerLoop() {
    while (true) {
        std::function<void()> task;
        {
            std::unique_lock<std::mutex> lock(queueMutex);
            cv.wait(lock, [this] { return stop || !tasks.empty(); });

            if (stop && tasks.empty())
                return;

            task = std::move(tasks.front());
            tasks.pop();
        }
        task();
    }
}
