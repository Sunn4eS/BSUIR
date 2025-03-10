using System.Text;

namespace FenceAndVigener.Classes;

public static class ProgressiveVigener
{
    private const string Alphabet = "ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЁ";

    static string GetFullKey(string key, string text)
    {
        char[] letters = key.ToCharArray();
        var newKey = new StringBuilder();
        while (newKey.Length < text.Length)
        {
            newKey.Append(letters);
            for (int i = 0; i < letters.Length; i++)
            {
                letters[i] = Alphabet[(Alphabet.IndexOf(letters[i]) + 1) % Alphabet.Length];
            }
        }
        newKey.Length = text.Length;

        return newKey.ToString();
    }

    static string Encryption(string text, string key, bool encrypt = true)
    {
        var textFilter1 = new TextFilter(true);
        text = textFilter1.Filter(text);
        var textFilter2 = new TextFilter(true);
        text = textFilter2.Filter(text);
        if (key == "")
        {
            return textFilter1.Unfilter(text);
        }
        return 
    }
    
}