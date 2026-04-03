using System;
using System.Drawing;

namespace lab1_obj_parser
{
    public unsafe class Rasterizer
    {
        private NewBitmap _canvas;
        private float[] _zBuffer;
        private int _width;
        private int _height;

        // Мягкие настройки Phong 
        private readonly float ka = 0.2f;
        private readonly float kd = 0.8f;
        private readonly float ks = 0.8f;
        private readonly float shininess = 32.0f;

        public Rasterizer(NewBitmap canvas)
        {
            _canvas = canvas;
            _width = canvas.Width;
            _height = canvas.Height;
            _zBuffer = new float[_width * _height];
        }

        public void Clear()
        {
            Array.Fill(_zBuffer, float.MaxValue);
        }

        public void DrawTriangle(Vec4 v1, Vec4 v2, Vec4 v3,
                         Vec4 n1, Vec4 n2, Vec4 n3,
                         Vec4 p1, Vec4 p2, Vec4 p3,
                         Vec4 cameraPos, Vec4 lightDir)
        {
            // Сортировка по Y (стандартно)
            if (v1.Y > v2.Y) { Swap(ref v1, ref v2); Swap(ref n1, ref n2); Swap(ref p1, ref p2); }
            if (v1.Y > v3.Y) { Swap(ref v1, ref v3); Swap(ref n1, ref n3); Swap(ref p1, ref p3); }
            if (v2.Y > v3.Y) { Swap(ref v2, ref v3); Swap(ref n2, ref n3); Swap(ref p2, ref p3); }

            int y1 = (int)v1.Y, y2 = (int)v2.Y, y3 = (int)v3.Y;
            if (y1 == y3) return;

            byte* scan0 = _canvas.GetScan0();
            int stride = _canvas.GetStride();

            for (int y = y1; y <= y3; y++)
            {
                if (y < 0 || y >= _height) continue;

                bool isUpper = y < y2;
                float t1 = (float)(y - y1) / (y3 - y1);
                float t2 = isUpper ? (float)(y - y1) / (y2 - y1 + 1e-6f) : (float)(y - y2) / (y3 - y2 + 1e-6f);

                Vec4 va = v1 + (v3 - v1) * t1;
                Vec4 vb = isUpper ? v1 + (v2 - v1) * t2 : v2 + (v3 - v2) * t2;

                Vec4 na = n1 + (n3 - n1) * t1;
                Vec4 nb = isUpper ? n1 + (n2 - n1) * t2 : n2 + (n3 - n2) * t2;

                Vec4 pa = p1 + (p3 - p1) * t1;
                Vec4 pb = isUpper ? p1 + (p2 - p1) * t2 : p2 + (p3 - p2) * t2;

                if (va.X > vb.X) { Swap(ref va, ref vb); Swap(ref na, ref nb); Swap(ref pa, ref pb); }

                int xStart = (int)Math.Ceiling(va.X);
                int xEnd = (int)Math.Ceiling(vb.X);

                float dx = (float)(vb.X - va.X);
                if (dx < 1e-6f) dx = 1.0f;

                int offset = y * _width;
                byte* row = scan0 + (y * stride);

                for (int x = xStart; x < xEnd; x++)
                {
                    if (x < 0 || x >= _width) continue;

                    float phi = (x - (float)va.X) / dx;
                    float z = (float)(va.Z + (vb.Z - va.Z) * phi);

                    if (z < _zBuffer[offset + x])
                    {
                        _zBuffer[offset + x] = z;

                        // Интерполяция нормали и позиции
                        Vec4 n = (na + (nb - na) * phi).Normalize();
                        Vec4 p = pa + (pb - pa) * phi;

                        // Освещение (Phong)
                        double dotLN = Vec4.Dot(n, lightDir);
                        double diffuse = Math.Max(dotLN, 0.0) * kd;

                        // Мягкие блики
                        Vec4 viewDir = (cameraPos - p).Normalize();
                        Vec4 reflectDir = Vec4.Reflect(lightDir, n).Normalize();
                        double specBase = Math.Max(Vec4.Dot(reflectDir, viewDir), 0.0);
                        double specular = Math.Pow(specBase, shininess) * ks;

                        // Интенсивность с мягким Ambient
                        double intensity = ka + diffuse + specular;
                        byte colorVal = (byte)(Math.Min(intensity, 1.0) * 255);

                        int* pixel = (int*)(row + x * 4);
                        *pixel = (255 << 24) | (colorVal << 16) | (colorVal << 8) | colorVal;
                    }
                }
            }
        }

        private void Swap<T>(ref T a, ref T b) { T t = a; a = b; b = t; }
    }
}