using System.Drawing;
using System.Windows.Forms;

namespace MusicShop
{
    
    public abstract class Guitar
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
            Price = price;
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

        public virtual Panel Print()
        {
            var panel = new Panel();
            panel.AutoSize = true;
            panel.Location = new Point(0, 0);
            
            var image = new PictureBox();
            image.Location = new Point(0, 0);
            image.SizeMode = PictureBoxSizeMode.StretchImage;
            
            var info = new Label();
            info.AutoSize = true;
            info.Font = new Font("Segoe UI", 12.2F, FontStyle.Bold, GraphicsUnit.Point, 204);
            info.Text = "{}";
            return panel;
        } 
    }
}