using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;

namespace ImageGenerator
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            var fonts = new List<FontInfo>
            {
                /*new FontInfo(new Font("Calibri", 17), 0),
                new FontInfo(new Font("Times New Roman", 17), 0),
                new FontInfo(new Font("Segoe UI Light", 15), 0),
                new FontInfo(new Font("Yu Mincho Demibold", 15), 0),
                new FontInfo(new Font("Arial Narrow", 15), 0),
                new FontInfo(new Font("Georgia", 16), 0),
                new FontInfo(new Font("Onyx", 15), 0),
                new FontInfo(new Font("Tahoma", 16), 0)*/
                new FontInfo(new Font("Open Sans", 20), 0),
                new FontInfo(new Font("Montserrat", 20), 0)
                
            };

            var textBrush = new SolidBrush(Color.Black);

            for (int i = '0'; i <= '9'; i++)
            {
                Draw(fonts, ((char) i).ToString(), textBrush);
            }

            for (int i = 'а'; i <= 'я'; i++)
            {
                Draw(fonts, ((char) i).ToString(), textBrush);
            }

            for (int i = 'a'; i <= 'z'; i++)
            {
                Draw(fonts, ((char) i).ToString(), textBrush);
            }
        }

        private static void Draw(List<FontInfo> fonts, String i, SolidBrush textBrush)
        {
            foreach (var font in fonts)
            {
                using (var bitmap = new Bitmap(30, 30))
                using (var gr = Graphics.FromImage(bitmap))
                {
                    gr.Clear(Color.White);
                    gr.DrawString(i, font.Font, textBrush, new Point(0, font.DeltaX));
                    bitmap.Save(String.Format("{0}-{1}.png", i, font.Font.Name),
                        ImageFormat.Png);
                }
            }
        }
    }
}