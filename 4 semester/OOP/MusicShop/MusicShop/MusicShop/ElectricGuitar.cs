namespace MusicShop
{
    public class ElectricGuitar : Guitar
    {
        public string GuitarType { get; set; }
        public string PickUpType { get; set; }
        public string BridgeType { get; set; }
        public string PlayingMethodAdvice;

        public ElectricGuitar(string guitarType, string pickUpType, string bridgeType, string brand, string model, int countOfStrings, int price, string housingType, string country, Strings stringsModel) 
            : base(brand, model, countOfStrings, price, housingType, country, stringsModel)
        {
            GuitarType = guitarType;
            PickUpType = pickUpType;
            BridgeType = bridgeType;
        }

        public override string ToString()
        {
            return $"{base.ToString()}, Guitar Type: {GuitarType}, Pick Up Type: {PickUpType}, Bridge Type: {BridgeType}";
        }

        public override void PlayingMethod()
        {
            PlayingMethodAdvice = "You should play this guitar with pick";
        }
    }
}