using System;
using System.Drawing;

namespace lab1_obj_parser
{
    public class Rasterizer
    {
        private Bitmap _canvas;

        public Rasterizer(Bitmap canvas)
        {
            _canvas = canvas;
        }
        private void SetPixel(int x, int y, Color color)
        {
            if (x >= 0 && x < _canvas.Width && y >= 0 && y < _canvas.Height)
            {
                _canvas.SetPixel(x, y, color);
            }
        }

        // Алгоритм Брезенхема
        public void DrawLine(int x0, int y0, int x1, int y1, Color color)
        {
            var dx = Math.Abs(x1 - x0);
            var dy = Math.Abs(y1 - y0);
            var sx = (x0 < x1) ? 1 : -1;
            var sy = (y0 < y1) ? 1 : -1;
            var err = dx - dy;

            int maxSteps = dx + dy + 1;
            int steps = 0;

            while (steps < maxSteps)
            {
                SetPixel(x0, y0, color);

                if (x0 == x1 && y0 == y1) break;

                var e2 = 2 * err;
                if (e2 > -dy)
                {
                    err -= dy;
                    x0 += sx;
                }
                if (e2 < dx)
                {
                    err += dx;
                    y0 += sy;
                }
                steps++;
            }
        }
    }
}