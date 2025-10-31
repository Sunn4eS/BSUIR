#include "pch.h"
#include "ThreadPool.h"

ThreadPool::ThreadPool(size_t threadCount) : stop(false) {
    for (size_t i = 0; i < threadCount; ++i) {
        workers.push_back(std::thread(&ThreadPool::workerThread, this));
    }
}

ThreadPool::~ThreadPool()
{
    {
        std::unique_lock<std::mutex> lock(queueMutex);
        stop = true;
    }
    condition.notify_all();

    for (size_t i = 0; i < workers.size(); ++i) {
        if (workers[i].joinable()) {
            workers[i].join();
        }
    }
}

void ThreadPool::workerThread()
{
    while (true) {
        std::function<void()> task;

        {
            std::unique_lock<std::mutex> lock(queueMutex);
            condition.wait(lock, [this]() {
                return stop || !tasks.empty();
                });

            if (stop && tasks.empty()) {
                return;
            }

            task = tasks.front();
            tasks.pop();
        }

        task();
    }
}