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


        public void Clear()
        {
            for (int i = 0; i < _zBuffer.Length; i++)
            {
                _zBuffer[i] = float.MaxValue;
            }
        }

        public void DrawTriangle(Vec4 v1, Vec4 v2, Vec4 v3, Color color)
        {
            int x1 = (int)v1.X, y1 = (int)v1.Y; float z1 = (float)v1.Z;
            int x2 = (int)v2.X, y2 = (int)v2.Y; float z2 = (float)v2.Z;
            int x3 = (int)v3.X, y3 = (int)v3.Y; float z3 = (float)v3.Z;

            if (y1 > y2) { Swap(ref x1, ref x2); Swap(ref y1, ref y2); Swap(ref z1, ref z2); }
            if (y1 > y3) { Swap(ref x1, ref x3); Swap(ref y1, ref y3); Swap(ref z1, ref z3); }
            if (y2 > y3) { Swap(ref x2, ref x3); Swap(ref y2, ref y3); Swap(ref z2, ref z3); }

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

                int bx;
                float bz;

                if (!secondHalf) 
                {
                    bx = x1 + (int)((x2 - x1) * beta);
                    bz = z1 + (z2 - z1) * beta;
                }
                else 
                {
                    bx = x2 + (int)((x3 - x2) * beta);
                    bz = z2 + (z3 - z2) * beta;
                }

                
                if (ax > bx)
                {
                    Swap(ref ax, ref bx);
                    Swap(ref az, ref bz); 
                }

                for (int x = ax; x <= bx; x++)
                {
                    if (x < 0 || x >= _width) continue;

                    float phi = (bx == ax) ? 1.0f : (float)(x - ax) / (bx - ax);
                    float z = az + (bz - az) * phi;

                    
                    int idx = x + y * _width; 
                    if (z < _zBuffer[idx]) 
                    {
                        _zBuffer[idx] = z; 
                        _canvas.SetPixel(x, y, color); 
                    }
                }
            }
        }

    }
}