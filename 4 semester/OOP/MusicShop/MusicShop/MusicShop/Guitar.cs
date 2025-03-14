using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace MusicShop
{
    
    public abstract class Guitar : MusicalInstrument, IProductInfo
    {
        
        
        protected string Id { get; set; }
        public string Brand { get; set; }
        public string Model { get; set; }
        public Strings StringsModel { get; set; }
        public int CountOfStrings { get; set; }
        public int Price { get; set; }
        public string HousingType { get; set; }
        public string Country { get; set; }
        public string CareInst;
        
        
        
        public Guitar(string brand, string model, int countOfStrings, int price, string housingType, string country)
        {
            Brand = brand;
            Model = model;
            CountOfStrings = countOfStrings;
            Price = price;
            HousingType = housingType;
            Country = country;
            
        }
        private void UpdatePrice(int newPrice)
        {
            Price = newPrice;
        }

        public virtual void ChangeStrings(Strings newStingsModel)
        {
            UpdatePrice(Price - StringsModel.Price + newStingsModel.Price);
            StringsModel = newStingsModel;
        }
        public abstract void PlayingMethod();

        public override string ToString()
        {
            return $"Brand: {Brand}, Model: {Model}, Price: {Price}";
        }

        public virtual string GetCareInstructions()
        {
            CareInst = "Clean the body regularly and store in a dry place.\n";
            return CareInst;
        }
    }
}