using System.Text;

namespace FenceAndVigener.Classes;

public static class ProgressiveVigener
{
    private const string Alphabet = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ";

    static string GetFullKey(string text, string key)
    {
        char[] chars = key.ToCharArray();
        var sb = new StringBuilder();
        while (sb.Length < text.Length)
        {
            sb.Append(chars);
            for (int i = 0; i < chars.Length; i++)
            {
                chars[i] = Alphabet[(Alphabet.IndexOf(chars[i]) + 1) % Alphabet.Length];
            }
        }
        sb.Length = text.Length;
        return sb.ToString();
    }

    static string Encryption(string text, string key, bool encrypt = true)
    {
        var textFilter1 = new TextFilter(true);
        text = textFilter1.Filter(text);
        var textFilter2 = new TextFilter(true);
        key = textFilter2.Filter(key);
        if (key == "")
        {
            return textFilter1.Unfilter(text);
        }

        key = GetFullKey(text, key);

        var chipherText = new char[text.Length];
        for (int i = 0; i < text.Length; i++)
        {
            chipherText[i] = Alphabet[(Alphabet.Length + Alphabet.IndexOf(text[i]) + Alphabet.IndexOf(key[i]) * (encrypt ? 1 : -1)) % Alphabet.Length];
        }

        return textFilter1.Unfilter(new string(chipherText));
    }
    public static string Encrypt(string text, string key)
    {
        return Encryption(text, key);
    }

    public static string Decrypt(string text, string key)
    {
        return Encryption(text, key, false);
    }
    
}