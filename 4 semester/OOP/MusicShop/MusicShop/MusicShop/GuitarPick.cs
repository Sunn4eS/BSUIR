namespace MusicShop
{
    public class GuitarPick
    {
        public string Brand { get; set; }
        public string Model { get; set; }
        public string Color { get; set; }
        public int Width { get; set; }

        public GuitarPick(string brand, string model, string color, int width)
        {
            Brand = brand;
            Model = model;
            Color = color;
            Width = width;
        }
    }
}