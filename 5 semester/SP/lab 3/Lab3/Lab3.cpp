#include "ThreadPool.h"
#include <iostream>

void PrintMessage(const std::string& msg) {
    std::cout << msg + "\n";
    Sleep(1000);
}

int main() {
    ThreadPool pool(4);

    pool.Enqueue([] { PrintMessage("1"); });
    pool.Enqueue([] { PrintMessage("2"); });
    pool.Enqueue([] { PrintMessage("3"); });
    pool.Enqueue([] { PrintMessage("4"); });
    pool.Enqueue([] { PrintMessage("5"); });
    pool.Enqueue([] { PrintMessage("6"); });
    pool.Enqueue([] { PrintMessage("7"); });
    pool.Enqueue([] { PrintMessage("8"); });
    pool.Enqueue([] { PrintMessage("9"); });
    pool.Enqueue([] { PrintMessage("10"); });
    pool.Enqueue([] { PrintMessage("11"); });
    pool.Enqueue([] { PrintMessage("12"); });

    Sleep(4000); 
    return 0;
}
