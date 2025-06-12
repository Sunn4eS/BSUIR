using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace OpenKey
{
    public class Checker
    {
        private const int MIN_P = 2;
        private const int MAX_P = int.MaxValue;
        private const int MIN_X = 2;
        private const int MIN_K = 2;

        public bool IsValidP(string pStr) 
        {
            int p;
            if (!int.TryParse(pStr, out p)) 
            {
                ShowError($"Некорректное значение P! Введите простое число от {MIN_P} до {MAX_P}!");
                return false;   
            }

            if ((p < MIN_P) || (p > int.MaxValue))
            {
                ShowError($"Некорректное значение P! Введите простое число от {MIN_P} до {MAX_P}!");
                return false;
            }

            if (!MathTools.IsPrime(p)) 
            {
                ShowError($"Некорректное значение P! P должно быть простым!");
                return false;
            }

            return true;
        }
        public bool IsValidK(string kStr, int p)
        {
            int MAX_K = p - 2;

            int k;
            if (!int.TryParse(kStr, out k))
            {
                ShowError($"Некорректное значение K! Введите целое число от {MIN_K} до {MAX_K}!");
                return false;
            }

            if ((k < MIN_K) || (k > MAX_K))
            {
                ShowError($"Некорректное значение K! Введите целое число от {MIN_K} до {MAX_K}!");
                return false;
            }

            if (!MathTools.IsRelativelyPrime(k, p - 1))
            {
                ShowError($"Некорректное значение K! K должно быть взаимопростым с p - 1 ({p - 1})!");
                return false;
            }

            return true;
        }

        public bool IsValidX(string xStr, int p)
        {
            int MAX_X = p - 2;

            int x;
            if (!int.TryParse(xStr, out x))
            {
                ShowError($"Некорректное значение X! Введите целое число от {MIN_X} до {MAX_X}!");
                return false;
            }

            if ((x < MIN_X) || (x > MAX_X))
            {
                ShowError($"Некорректное значение X! Введите целое число от {MIN_X} до {MAX_X}!");
                return false;
            }

            return true;
        }

        public bool IsValidSelectedG(int selectedIndex) 
        {
            if (selectedIndex < 0)
            {
                ShowError($"Не выбрано значение G! Выберите G!!");
                return false;
            }

            return true;
        }

        public bool IsValidSourceData(byte[] data) 
        {
            if (data == null)
            {
                ShowError($"Исходный файл не выбран!");
                return false;
            }

            return true;
        }



        private void ShowError(string message) 
        {
            MessageBox.Show(message, "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }


    }
}
