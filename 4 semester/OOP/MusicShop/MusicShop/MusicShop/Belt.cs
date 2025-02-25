using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace MusicShop
{
    public class Belt : ProductInfo
    {
        public string Brand { get; set; }
        public string Model { get; set; }
        public string Material { get; set; }
        public int Price { get; set; }

        public Belt(string brand, string model, string material, int price)
        {
            Brand = brand;
            Model = model;
            Material = material;
            Price = price;
        }
    }
}