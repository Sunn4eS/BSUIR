using System.Drawing;

namespace ImageGenerator
{
    public class FontInfo
    {
        public FontInfo(Font font, int deltaX)
        {
            Font = font;
            DeltaX = deltaX;
        }

        public Font Font { get; set; }
        public int DeltaX { get; set; }
    }
}