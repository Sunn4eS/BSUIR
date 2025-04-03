using System;

namespace ThreadEncryption.BackEnd
{
    internal static class Key
    {
        public static int[] polynomial = { 34, 15, 14, 1 };

        public static byte[] Generate(byte[] key, int length)
        {
            return Generate(key, polynomial, length);
        }

        private static byte[] Generate(byte[] key, int[] polynomial, int length)
        {
            byte[] generatedKey = new byte[length];

            for (int i = 0; i < length; i++) 
            {               
                generatedKey[i] = key[0];

                byte firstBit = GetFirstBit(key, polynomial);
                LeftShift(key);
                key[key.Length - 1] = firstBit;
            }

            return generatedKey;
        }

        private static byte GetFirstBit(byte[] key, int[] polynomial)
        {
            byte firstBit = 0;
            for (int i = 0; i < polynomial.Length; i++)
            {
                firstBit ^= key[key.Length - polynomial[i]];
            }
            return firstBit;
        }

        private static void LeftShift(byte[] key)
        {
            for (int i = 0; i < key.Length - 1; i++)
            {
                key[i] = key[i + 1];
            }
        }
    }
}