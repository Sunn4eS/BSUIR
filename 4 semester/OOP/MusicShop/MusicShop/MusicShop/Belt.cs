namespace MusicShop
{
    public class Belt
    {
        public string Brand { get; set; }
        public string Model { get; set; }
        public string Material { get; set; }

        public Belt(string brand, string model, string material)
        {
            Brand = brand;
            Model = model;
            Material = material;
        }
    }
}