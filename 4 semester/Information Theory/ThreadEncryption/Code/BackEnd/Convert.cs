using System.Text;

namespace ThreadEncryption.BackEnd
{
    internal static class Convert
    {
        public static string BytesToString(byte[] bytes, int index, int count)
        {
            StringBuilder text = new StringBuilder();
            for (int i = index; i < index + count; i++)
            {
                for (int j = 0; j < 8; j++)
                {
                    text.Append((char)(((bytes[i] >> j) & 0x1) + '0'));
                }
            }
            return text.ToString();
        }

        public static string BitsToString(byte[] bits, int index, int count)
        {
            StringBuilder text = new StringBuilder();
            for (int i = index; i < index + count; i++)
            {
                text.Append((char)(bits[i] + '0'));
            }
            return text.ToString();
        }
    }
}
