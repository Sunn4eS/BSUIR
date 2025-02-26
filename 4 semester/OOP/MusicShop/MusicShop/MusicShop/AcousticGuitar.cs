namespace MusicShop
{
    public class AcousticGuitar : Guitar

    {
        public string GuitarType;

        public AcousticGuitar(string guitarType, string brand, string model, int countOfStrings, int price, string housingType,
            string country, Strings stringsModel) :
            base(brand, model, countOfStrings, price, housingType, country, stringsModel)
        {
           GuitarType = guitarType; 
        }
    }
}