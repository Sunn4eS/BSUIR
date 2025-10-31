#pragma once

#include <future>
#include <queue>

class ThreadPool
{
public:
    ThreadPool(size_t threadCount);
    template<class F, class... Args>
    std::future<typename std::result_of<F(Args...)>::type> addTask(F f, Args... args);
    ~ThreadPool();
private: 

    std::vector<std::thread> workers;
    std::queue<std::function<void()> > tasks;

    std::mutex queueMutex;
    std::condition_variable condition;
    bool stop;

    void workerThread();
};

template<class F, class ...Args>
inline std::future<typename std::result_of<F(Args...)>::type> ThreadPool::addTask(F f, Args ...args)
{
    typedef typename std::result_of<F(Args...)>::type return_type;

    auto boundedTask = std::bind(f, args...);

    std::shared_ptr<std::packaged_task<return_type()>> task(new std::packaged_task<return_type()>(boundedTask));

    std::future<return_type> result = task->get_future();

    {
        std::unique_lock<std::mutex> lock(queueMutex);
        if (stop) {
            throw std::runtime_error("ThreadPool has been stopped");
        }
        tasks.push(std::function<void()>([task]() { (*task)(); }));
    }

    condition.notify_one();
    return result;
}
