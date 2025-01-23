#include <iostream>
#include <vector>
using namespace std;

vector<int> MultiplyByTwo(vector<int>& num) {
    int buf = 0;
    for (int i = 0; i < num.size(); i++) {
        num[i] = num[i] * 2 + buf;
        buf = num[i] / 10;
        num[i] = num[i] % 10;
    }

    if (buf > 0) {
        num.push_back(buf);
    }

    return num;
}

vector<int> PowerOfTwo(int deg) {
    vector<int> num(1, 1);

    for (int i = 1; i <= deg; i++) {
        MultiplyByTwo(num);
    }

    return num;
}

void PrintBigInt(const vector<int>& num) {
    for (int i = num.size() - 1; i >= 0; i--) {
        cout << num[i];
    }
    cout << endl;
}

int main() {
    int deg;
    cin >> deg;

    vector<int> resNum = PowerOfTwo(deg);
    PrintBigInt(resNum);

    return 0;
}