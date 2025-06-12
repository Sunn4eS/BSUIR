using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace OpenKey
{
    public class ElGamal
    {
        public int P { get; set; }
        public int G { get; set; }
        public int X { get; set; }
        public int K { get; set; }
        public int Y { get; set; }

        private int A { get; set; }

        public void InitializeElGamal(int p, int g, int x, int k) 
        {
            this.P = p;
            this.G = g;
            this.X = x;
            this.K = k;

            this.Y = (int)MathTools.FastExp(g, x, p);
            this.A = (int)MathTools.FastExp(g, k, p);
        }

        public byte[] StartEncryption(byte[] srcData)
        {
            int[] result = new int[srcData.Length * 2];

            for (int i = 0; i < srcData.Length; i++)
            {
                if (srcData[i] >= this.P)
                {
                    return null;
                }

                result[2 * i] = (int)this.A;
                result[2 * i + 1] = (int)MathTools.FastPowMul(this.Y, this.K, srcData[i], this.P);
            }

            // Преобразование int[] в byte[]
            byte[] byteResult = new byte[result.Length * sizeof(int)];
            Buffer.BlockCopy(result, 0, byteResult, 0, byteResult.Length);

            return byteResult;
        }

        public byte[] StartDecryption(byte[] srcData)
        {
            if (srcData.Length % sizeof(int) != 0)
            {
                MessageBox.Show("Файл поврежден или не является файлом, зашифрованным по алгоритму Эль-Гамаля!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return null;
            }

            // Преобразование byte[] в int[]
            int[] intArray = new int[srcData.Length / sizeof(int)];
            Buffer.BlockCopy(srcData, 0, intArray, 0, srcData.Length);

            byte[] result = new byte[srcData.Length / 8];

            for (int i = 0; i < intArray.Length / 2; i++)
            {
                int a = intArray[2 * i];
                int b = intArray[2 * i + 1];

                result[i] = (byte) MathTools.FastPowMul(a, -this.X, b, this.P);
            }

            return result;
        }

        public List<int> GetPrimitiveRoots(int p) 
        {
            List<int> roots = new List<int>();
            int eilerFuncValue = p - 1;

            for (int g = 2; g < eilerFuncValue; g++) 
            {
                long modulo = MathTools.FastExp(g, eilerFuncValue, p);
                if (modulo == 1) 
                {
                    bool isPrimitiveRoot = true;
                    for (int l = 1; l <= eilerFuncValue - 1; l++) 
                    {
                        long otherModulo = MathTools.FastExp(g, l, p);
                        if (otherModulo == 1) 
                        {
                            isPrimitiveRoot = false;
                            break;
                        }
                    }
                    if (isPrimitiveRoot) 
                    {
                        roots.Add(g);
                    }
                }
            }

            return roots;
        }

        public List<int> GetListK(int p) 
        {
            List<int> kList = new List<int>();
            for (int k = 2; k < p - 1; k++) 
            {
                if (MathTools.IsRelativelyPrime(k, p - 1)) 
                {
                    kList.Add(k);   
                }
            }

            return kList;
        }
    }
}
