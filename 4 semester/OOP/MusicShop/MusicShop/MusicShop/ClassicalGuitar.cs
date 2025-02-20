namespace MusicShop
{
    public class ClassicalGuitar : Guitar
    {
        public ClassicalGuitar(string brand, string model, int countOfStrings, int price, string housingType,
            string country, Strings stringsModel)
            : base(brand, model, countOfStrings, price, housingType, country, stringsModel)
        {
            
        }
    }
}