#define _USE_MATH_DEFINES
#include <cmath>
#include <iostream>
using namespace std;
double my_ln(double x)
{
    const double eps = 1e-6;
    const double lnln = M_LN2; //ln2 из math.h
    int k = 0;
    while (x > 2.0) // приведение аргумента к интервалу (0,2)
    {
        x /= 2.0;
        k++;
    }
    x -= 1.; // вычитается единица для разложения в точке (1+x)
    double s = 0;
    int n = 1;
    double an = x;
    while (fabs(an) > eps)
    {
        s += an;
        ++n;
        an *= -x * (n - 1) / n;
    }
    s += k * lnln;
    return s;
}
int main()
{
    double x;
    cout << "Enter x>0:";
    cin >> x;
    cin.get();
    cout << "S=" << my_ln(x) << " ln(x)=" << log(x) << endl;
    cin.get();
    return 0;
}