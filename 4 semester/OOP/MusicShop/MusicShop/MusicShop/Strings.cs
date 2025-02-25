using System.Drawing;
using System.IO;
using System.Windows.Forms;
namespace MusicShop
{
    public class Strings : ProductInfo
    {
        private int[] size_arr = new int[2];
        public string Model { get; set; }
        public string Brand { get; set; }
        public int Price { get; set; }
        public string Material { get; set; }
        public int[] Size
        {
            get { return size_arr; }
        }

        public Strings(string model, string brand, int price, int size_min, int size_max, string material)
        {
            Model = model;
            Brand = brand;
            Price = price;
            Size[0] = size_min;
            Size[1] = size_max;
            Material = material;
        }
    }
}