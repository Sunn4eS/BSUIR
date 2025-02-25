using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace MusicShop
{
    
    public abstract class Guitar : ProductInfo
    {
        
        
        protected int Id { get; set; }
        public string Brand { get; set; }
        public string Model { get; set; }
        public Strings StringsModel { get; set; }
        public int CountOfStrings { get; set; }
        public int Price { get; set; }
        public string HousingType { get; set; }
        public string Country { get; set; }
        
        
        
        public Guitar(string brand, string model, int countOfStrings, int price, string housingType, string country, Strings stringsModel)
        {
            Brand = brand;
            Model = model;
            CountOfStrings = countOfStrings;
            Price = price + stringsModel.Price;
            HousingType = housingType;
            Country = country;
            StringsModel = stringsModel;
            
        }
        
        

        private void UpdatePrice(int newPrice)
        {
            Price = newPrice;
        }

        public void ChangeStrings(Strings newStingsModel)
        {
            UpdatePrice(Price - StringsModel.Price + newStingsModel.Price);
            StringsModel = newStingsModel;
        }

        // public virtual Panel Print(string imagePath, int x, int y)
        // {
        //     var image = new PictureBox();
        //     image.Location = new Point(x, y);
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
        //     else
        //     {
        //         MessageBox.Show($"Файл не найден: {imagePath}");
        //     }
        //
        //     var info = new Label();
        //     info.Location = new Point(0, image.Bottom + 10);
        //     info.AutoSize = true;
        //     info.Font = new Font("Segoe UI", 12.2F, FontStyle.Bold, GraphicsUnit.Point, 204);
        //     info.Text = $"{Brand} {Model}\n{Price} BYN";
        //
        //
        //     var panel = new Panel();
        //     panel.Location = new Point(0, 0);
        //     panel.AutoScroll = true;
        //     panel.Size = new Size(image.Width, image.Height + info.Height * 3 + 10);
        //     panel.Controls.Add(image);
        //     panel.Controls.Add(info);
        //
        //     return panel;
        // }
    }
}