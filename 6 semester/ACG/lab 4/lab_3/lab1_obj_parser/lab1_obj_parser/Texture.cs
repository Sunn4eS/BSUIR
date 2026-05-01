using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.IO;

namespace lab1_obj_parser
{
    public class Texture
    {
        protected int[] _pixels;
        public int Width { get; private set; }
        public int Height { get; private set; }

        // Существующий конструктор для PNG/JPG/BMP
        public Texture(string path)
        {
            using (Bitmap bmp = new Bitmap(path))
            {
                Width = bmp.Width;
                Height = bmp.Height;
                _pixels = new int[Width * Height];
                var data = bmp.LockBits(new Rectangle(0, 0, Width, Height),
                    ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
                Marshal.Copy(data.Scan0, _pixels, 0, _pixels.Length);
                bmp.UnlockBits(data);
            }
        }

        // Новый защищённый конструктор для создания текстуры из готовых пикселей
        protected Texture(int width, int height, int[] pixels)
        {
            Width = width;
            Height = height;
            _pixels = pixels;
        }

        // Фабричный метод, который сам выбирает способ загрузки
        public static Texture LoadFromFile(string path)
        {
            string ext = Path.GetExtension(path).ToLower();
            if (ext == ".tga")
                return TgaTexture.Load(path);
            else
                return new Texture(path);
        }

        public Vec4 Sample(Vec2 uv)
        {
            double u = uv.X - System.Math.Floor(uv.X);
            double v = uv.Y - System.Math.Floor(uv.Y);
            int x = (int)(u * Width) % Width;
            int y = (int)((1.0 - v) * Height) % Height;
            if (x < 0) x += Width;
            if (y < 0) y += Height;
            int color = _pixels[y * Width + x];
            return new Vec4(
                ((color >> 16) & 255) / 255.0,
                ((color >> 8) & 255) / 255.0,
                (color & 255) / 255.0
            );
        }
    }
}