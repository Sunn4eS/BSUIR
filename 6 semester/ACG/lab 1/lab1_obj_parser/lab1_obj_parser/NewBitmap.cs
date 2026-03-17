using System;
using System.Drawing;
using System.Drawing.Imaging;

namespace lab1_obj_parser
{
    public unsafe class NewBitmap : IDisposable
    {
        private Bitmap _bitmap;
        private BitmapData? _bitmapData;
        private byte* _scan0; 
        private int _stride;  
        private int _width;
        private int _height;

        public NewBitmap(Bitmap bitmap)
        {
            _bitmap = bitmap;
            _width = bitmap.Width;
            _height = bitmap.Height;
            Lock();
        }

        private void Lock()
        {
            Rectangle rect = new Rectangle(0, 0, _width, _height);

            _bitmapData = _bitmap.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);

            _scan0 = (byte*)_bitmapData.Scan0;
            _stride = _bitmapData.Stride;
        }

        public void Dispose()
        {
            if (_bitmapData != null)
            {
                _bitmap.UnlockBits(_bitmapData);
                _bitmapData = null;
            }
        }

        public void SetPixel(int x, int y, Color color)
        {
            if (x < 0 || x >= _width || y < 0 || y >= _height) return;

            byte* row = _scan0 + (y * _stride);
            int* pixel = (int*)(row + x * 4);

            *pixel = color.ToArgb();
        }
    }
}