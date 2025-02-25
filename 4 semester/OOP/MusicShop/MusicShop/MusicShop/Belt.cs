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
        // public Panel Print(string imagePath, int x, int y, ProductInfo product)
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