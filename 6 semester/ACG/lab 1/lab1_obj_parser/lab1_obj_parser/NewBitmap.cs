using System;
using System.Drawing;
using System.Drawing.Imaging;

namespace lab1_obj_parser
{
    // Обертка над Bitmap для быстрого доступа к пикселям
    public unsafe class NewBitmap : IDisposable
    {
        private Bitmap _bitmap;
        private BitmapData _bitmapData;
        private byte* _scan0; // Указатель на начало данных в памяти
        private int _stride;  // Ширина строки в байтах (может быть больше ширины картинки)
        private int _width;
        private int _height;

        public NewBitmap(Bitmap bitmap)
        {
            _bitmap = bitmap;
            _width = bitmap.Width;
            _height = bitmap.Height;
            Lock();
        }

        // Блокируем память битмапа
        private void Lock()
        {
            Rectangle rect = new Rectangle(0, 0, _width, _height);

            // Используем формат 32bppArgb (4 байта на пиксель: Alpha, Red, Green, Blue)
            // Это самый быстрый формат для записи int-ом
            _bitmapData = _bitmap.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);

            _scan0 = (byte*)_bitmapData.Scan0;
            _stride = _bitmapData.Stride;
        }

        // Освобождаем память (обязательно!)
        public void Dispose()
        {
            if (_bitmapData != null)
            {
                _bitmap.UnlockBits(_bitmapData);
                _bitmapData = null;
            }
        }

        // Супер-быстрая установка пикселя через указатели
        public void SetPixel(int x, int y, Color color)
        {
            // Проверка границ (можно убрать для экстремальной скорости, если уверены в координатах)
            if (x < 0 || x >= _width || y < 0 || y >= _height) return;

            // Вычисляем адрес пикселя:
            // Scan0 + (y * ширина_строки) + (x * 4_байта)
            byte* row = _scan0 + (y * _stride);
            int* pixel = (int*)(row + x * 4);

            // Записываем цвет сразу как int (ARGB)
            *pixel = color.ToArgb();
        }
    }
}