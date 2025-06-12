using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenKey
{
    public static class MathTools
    {
        public static long FastExp(long foundation, long degree, long n)
        
        {
            long currFoundation = foundation;
            long currDegree = degree;
            long result = 1;

            while (currDegree != 0)
            {
                while (currDegree % 2 == 0)
                {
                    currDegree /= 2;
                    currFoundation = (currFoundation * currFoundation) % n;
                }

                currDegree--;
                result = (result * currFoundation) % n;
            }

            return result;
        }

        public static long FastPowMul(long foundation, long degree, long multiplier, long p)
        {
            if (degree < 0)
            {
                // Находим модульное обратное foundation^(-degree) mod p
                long invFoundation = ModInverse(foundation, p);
                foundation = invFoundation;
                degree = -degree;
            }

            // Теперь степень положительная — используем стандартный алгоритм
            long powResult = FastExp(foundation, degree, p);
            //long modMultiplier = multiplier % p;
            return (multiplier * powResult) % p;
        }


        public static bool IsPrime(int n)
        {
            if (n == 1) return false;

            bool isPrime = true;
            for (int i = 2; i <= Math.Sqrt(n); i++)
            {
                if (n % i == 0)
                {
                    isPrime = false;
                    break;
                }
            }
            return isPrime;
        }

        public static bool IsRelativelyPrime(int a, int b)
        {
            //Если НОД == 1 - то взаимопростые
            while (b != 0)
            {
                int remainder = a % b;
                a = b;
                b = remainder;
            }
            return a == 1;
        }

        public static long ModInverse(long a, long p)
        {
            if (p == 1)
                return 0;

            long x, y;
            long g = ExtendedGcd(a, p, out x, out y);

            if (g != 1)
                throw new ArgumentException("Обратный элемент не существует: a и p не взаимно просты.");

            return (x % p + p) % p; // Убеждаемся, что результат положительный
        }

        private static long ExtendedGcd(long a, long b, out long x, out long y)
        {
            if (b == 0)
            {
                x = 1;
                y = 0;
                return a;
            }

            long x1, y1;
            long gcd = ExtendedGcd(b, a % b, out x1, out y1);

            x = y1;
            y = x1 - (a / b) * y1;

            return gcd;
        }
    }
}
