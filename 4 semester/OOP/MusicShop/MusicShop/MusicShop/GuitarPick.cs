namespace MusicShop
{
    public class GuitarPick : IProductInfo
    {
        public string Brand { get; set; }
        public string Model { get; set; }
        public string Color { get; set; }
        public int Width { get; set; }
        public int Price { get; set; }

        public GuitarPick(string brand, string model, int price, string color, int width)
        {
            Brand = brand;
            Model = model;
            Color = color;
            Width = width;
            Price = price;
        }

        public override string ToString()
        {
            return $"Brand: {Brand}, Model: {Model}, Color: {Color}, Width: {Width}";
        }
    }
}