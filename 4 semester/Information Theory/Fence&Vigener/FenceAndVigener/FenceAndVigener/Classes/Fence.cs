using System.Text;

namespace FenceAndVigener.Classes;

public class Fence
{
    public static int GetKey(string key)
    {
        string input = string.Join("", key.Where(char.IsDigit));
        bool IsNumber = int.TryParse(input, out var value);
        if (IsNumber)
        {
            int newValue = Math.Abs(value);
            if (newValue == 0) return -1;
            return value;
        }
        return -1;
    }

    public static string Encipher(string text, string keytext)
    {
        int key = GetKey(keytext);
        
        var textFilter1 = new TextFilter(true);
        text = textFilter1.Filter(text);
        if (key == -1)
        {
            MessageBox.Show("Неверный ключ!", "Ошибка");
            return text;
        }
        else
        {
            if (key >= text.Length)
            {
                MessageBox.Show("Ключ должен быть меньше длины исходного текста!", "Ошибка");
                return text;
            }
            if (key == 1)
            {
                MessageBox.Show("Ключ должен быть больше 1!", "Ошибка");
                return text;
            }

            int row = 0;
            int direction = 1;

            char[,] fence = new char[key, text.Length];
            for (int i = 0; i < key; i++)
            {
                for (int j = 0; j < text.Length; j++)
                {
                    fence[i, j] = ' ';
                }
            }

            for (int j = 0; j < text.Length; j++)
            {
                fence[row, j] = text[j];
                row += direction;
                if (row == key - 1 || row == 0)
                {
                    direction *= -1;
                }
            }

            StringBuilder cipher = new StringBuilder();
            int count = 0;
            for (int i = 0; i < key; i++)
            {
                for (int j = 0; j < text.Length; j++)
                {
                    if (fence[i, j] != ' ')
                    {
                        cipher.Append(fence[i, j]);
                        count++;
                        if (count % (key + 1) == 0)
                        {
                            cipher.Append(" ");
                        }
                    }
                }
            }
            
            return cipher.ToString();
        }
    }

    public static string Decipher(string text, string keytext)
    {
        int key = GetKey(keytext);
        var textFilter1 = new TextFilter(true);
        text = textFilter1.Filter(text);
        if (key == -1)
        {
            MessageBox.Show("Неверный ключ!", "Ошибка");
            return text;
        }
        else
        {
            if (key >= text.Length)
            {
                MessageBox.Show("Ключ должен быть меньше длины текста!", "Ошибка");
                return text;
            }

            if (key == 1)
            {
                MessageBox.Show("Ключ должен быть больше 1!", "Ошибка");
                return text;
            }

            char[,] fence = new char[key, text.Length];
            int row = 0;
            int direction = 1;
            for (int i = 0; i < text.Length; i++)
            {
                fence[row, i] = '-';
                row += direction;
                if (row == key - 1 || row == 0)
                {
                    direction *= -1;
                }
            }

            int index = 0;
            for (int i = 0; i < key; i++)
            {
                for (int j = 0; j < text.Length; j++)
                {
                    if (fence[i, j] == '-' && index < text.Length)
                    {
                        fence[i, j] = text[index++];
                    }
                }
            }

            StringBuilder plainText = new StringBuilder();
            row = 0;
            direction = 1;
            for (int i = 0; i < text.Length; i++)
            {
                plainText.Append(fence[row, i]);
                row += direction;
                if (row == key - 1 || row == 0)
                {
                    direction *= -1;
                }
            }

            return plainText.ToString();
        }
    }
}