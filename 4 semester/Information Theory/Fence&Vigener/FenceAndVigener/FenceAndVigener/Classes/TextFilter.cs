using System.Text;

namespace FenceAndVigener.Classes;

internal class TextFilter
{
    HashSet<char> _alphabet;
    char[] _oldText;
    bool isRussia;

    public TextFilter(bool isRussia)
    {
        _alphabet = new HashSet<char>();
        if (isRussia)
        {
            for (int i = 0; i < 32; i++)
            {
                _alphabet.Add((char)('А' + i));
            }
            _alphabet.Add('Ё');
        }
        else
        {
            for (int i = 0; i < 26; i++)
            {
                _alphabet.Add((char)('A' + i));
            }
        }
        this.isRussia = isRussia;
    }

    public string Filter(string text)
    {
        _oldText = text.ToCharArray();
        var newText = new StringBuilder();
        for (int i = 0; i < _oldText.Length; i++)
        {
            if (_alphabet.Contains(Char.ToUpper(_oldText[i])))
            {
                newText.Append(Char.ToUpper(_oldText[i]));
            }
        }
        return newText.ToString();
    }

    public string Unfilter(string text)
    {
        int j = 0;
        for (int i = 0; j < _oldText.Length && i < text.Length; j++)
        {
            if (_alphabet.Contains(Char.ToUpper(_oldText[j])))
            {
                _oldText[j] = (isRussia && (_oldText[j] >= 'а' && _oldText[j] <= 'я' || _oldText[j] == 'ё') || !isRussia && (_oldText[j] >= 'a' && _oldText[j] <= 'z')) ? Char.ToLower(text[i]) : text[i];
                i++;
            }
        }
        return new string(_oldText);
    }
}