namespace MusicShop
{
    public class ElectricGuitar : Guitar
    {
        public string GuitarType { get; set; }
        public string PickUpType { get; set; }
        public string BridgeType { get; set; }

        public ElectricGuitar(string guitarType, string pickUpType, string bridgeType, string brand, string model, int countOfStrings, int price, string housingType, string country, Strings stringsModel) 
            : base(brand, model, countOfStrings, price, housingType, country, stringsModel)
        {
            GuitarType = guitarType;
            PickUpType = pickUpType;
            BridgeType = bridgeType;
        }
    }
}