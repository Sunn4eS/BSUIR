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
        
        // public Panel Print(string imagePath, int x, int y)
        // {
        //     var image = new PictureBox();
        //     image.Location = new Point(0, 0);
        //     image.Size = new Size(150, 150);
        //     image.SizeMode = PictureBoxSizeMode.StretchImage;
        //     image.BorderStyle = BorderStyle.Fixed3D;
        //     if (System.IO.File.Exists(imagePath))
        //     {
        //         using (var fileStream = new FileStream(imagePath, FileMode.Open, FileAccess.Read))
        //         {
        //             image.Image = Image.FromStream(fileStream);
        //         }
        //     }
        //     else {
        //         MessageBox.Show($"Файл не найден: {imagePath}");
        //     }
        //     var info = new Label();
        //     info.Location = new Point(0, image.Bottom + 10);
        //     info.AutoSize = true;
        //     info.Font = new Font("Segoe UI", 12.2F, FontStyle.Bold, GraphicsUnit.Point, 204);
        //     info.Text = $"{Brand} {Model}\n{Price} BYN";
        //     
        //     
        //     var panel = new Panel();
        //     panel.Location = new Point(x, y);
        //     panel.AutoScroll = true;    
        //     panel.Size = new Size(image.Width, image.Height + info.Height * 3 + 10);
        //     panel.Controls.Add(image);
        //     panel.Controls.Add(info);
        //     
        //     return panel;
        // } 
        
    }
}