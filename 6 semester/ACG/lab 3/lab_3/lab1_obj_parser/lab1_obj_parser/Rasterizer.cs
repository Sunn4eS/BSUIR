using System;
using System.Drawing;

namespace lab1_obj_parser
{
    public class Rasterizer
    {
        private NewBitmap _canvas;
        private float[] _zBuffer;
        private int _width;
        private int _height;

        //Фоновое
        private readonly double ka = 0.3;
        //Рассеянное
        private readonly double kd = 0.7;

        //Бликовое
        double ks = 0.5; // коэффициент отражения
        double shininess = 32.0; // блеск


        public Rasterizer(NewBitmap canvas)
        {
            _canvas = canvas;
            _width = canvas.Width;
            _height = canvas.Height;
            _zBuffer = new float[_width * _height];
        }

        private void Swap(ref int a, ref int b)
        {
            int temp = a; 
            a = b; 
            b = temp;
        }
        private void Swap(ref float a, ref float b) 
        {
            float t = a; 
            a = b; 
            b = t; 
        }

        private void Swap(ref Vec4 a, ref Vec4 b)
        {
            Vec4 t = a;
            a = b;
            b = t;
        }


        public void Clear()
        {
            for (int i = 0; i < _zBuffer.Length; i++)
            {
                _zBuffer[i] = float.MaxValue;
            }
        }


        public void DrawTriangle(Vec4 v1, Vec4 v2, Vec4 v3,
                         Vec4 n1, Vec4 n2, Vec4 n3,
                         Vec4 p1, Vec4 p2, Vec4 p3,
                         Vec4 cameraPos, Vec4 lightDir)
        {
            // Распаковываем координаты для удобства
            // Нам важны X, Y (на экране) и Z (глубина)
            int x1 = (int)v1.X, y1 = (int)v1.Y; float z1 = (float)v1.Z;
            int x2 = (int)v2.X, y2 = (int)v2.Y; float z2 = (float)v2.Z;
            int x3 = (int)v3.X, y3 = (int)v3.Y; float z3 = (float)v3.Z;

            // 1. Сортировка вершин по Y (сверху вниз)
            // Важно: когда меняем местами Y, нужно поменять и X, и Z!
            if (y1 > y2) { Swap(ref x1, ref x2); Swap(ref y1, ref y2); Swap(ref z1, ref z2); }
            if (y1 > y3) { Swap(ref x1, ref x3); Swap(ref y1, ref y3); Swap(ref z1, ref z3); }
            if (y2 > y3) { Swap(ref x2, ref x3); Swap(ref y2, ref y3); Swap(ref z2, ref z3); }

            // Высота всего треугольника
            int totalHeight = y3 - y1;

            for (int i = 0; i < totalHeight; i++)
            {
                int y = y1 + i;
                if (y < 0 || y >= _height) continue;

                bool secondHalf = i > y2 - y1 || y2 == y1;
                int segmentHeight = secondHalf ? y3 - y2 : y2 - y1;
                if (segmentHeight == 0) segmentHeight = 1;

                float alpha = (float)i / totalHeight;
                float beta = (float)(i - (secondHalf ? y2 - y1 : 0)) / segmentHeight;

                int ax = x1 + (int)((x3 - x1) * alpha);
                float az = z1 + (z3 - z1) * alpha;


                Vec4 an = n1 + (n3 - n1) * alpha; // Нормаль на длинной стороне
                Vec4 ap = p1 + (p3 - p1) * alpha; // Позиция на длинной стороне
                // Координаты на короткой стороне (B)
                int bx;
                float bz;
                Vec4 bn;
                Vec4 bp;
                

                if (!secondHalf) // Верхняя половина (v1 -> v2)
                {
                    bx = x1 + (int)((x2 - x1) * beta);
                    bz = z1 + (z2 - z1) * beta;
                    bn = n1 + (n2 - n1) * beta;
                    bp = p1 + (p2 - p1) * beta;
                }
                else // Нижняя половина (v2 -> v3)
                {
                    bx = x2 + (int)((x3 - x2) * beta);
                    bz = z2 + (z3 - z2) * beta;
                    bn = n2 + (n3 - n2) * beta;
                    bp = p2 + (p3 - p2) * beta;
                }

                // Гарантируем, что ax слева, bx справа
                if (ax > bx) 
                { 
                    Swap(ref ax, ref bx); 
                    Swap(ref az, ref bz); 
                    Swap(ref an, ref bn); 
                    Swap(ref ap, ref bp); 
                }


                // --- Рисуем горизонтальную линию ---
                for (int x = ax; x <= bx; x++)
                {
                    if (x < 0 || x >= _width) continue;

                    float phi = (bx == ax) ? 1.0f : (float)(x - ax) / (bx - ax);
                    float z = az + (bz - az) * phi;

                    int idx = x + y * _width; 
                    if (z < _zBuffer[idx]) 
                    {
                        // 1. Интерполируем финальную нормаль и позицию для КОНКРЕТНОГО пикселя
                        Vec4 pixelNormal = (an + (bn - an) * phi).Normalize();
                        Vec4 pixelPos = ap + (bp - ap) * phi;

                        // А) Фоновое (Ambient)
                        double ambient = ka;

                        // Б) Рассеянное (Diffuse)
                        double diff = Math.Max(Vec4.Dot(pixelNormal, lightDir), 0.0);
                        double diffuse = kd * diff;

                        Vec4 viewDir = (cameraPos - pixelPos).Normalize();
                        
                        Vec4 reflectDir = Vec4.Reflect(lightDir, pixelNormal).Normalize();

                        double spec = Math.Pow(Math.Max(Vec4.Dot(reflectDir, viewDir), 0.0), shininess);
                        double specular = ks * spec;

                        // Итоговая интенсивность (формула 3.5)
                        double intensity = ambient + diffuse + specular;
                        if (intensity > 1.0) intensity = 1.0;

                        int finalColor = (int)(255 * intensity);
                        _canvas.SetPixel(x, y, Color.FromArgb(finalColor, finalColor, finalColor));

                        _zBuffer[x + y * _width] = z;
                    }
                }
            }
        }

    }
}