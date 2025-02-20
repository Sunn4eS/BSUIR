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
    }
}