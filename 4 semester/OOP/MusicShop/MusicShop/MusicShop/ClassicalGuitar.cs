namespace MusicShop
{
    public class ClassicalGuitar : Guitar
    {
        public double NeckWidth { get; set; }
        public string PlayingMethodAdvice;
        public ClassicalGuitar(string brand, string model, int countOfStrings, int price, string housingType,
            string country, double neckWidth)
            : base(brand, model, countOfStrings, price, housingType, country)
        {
            NeckWidth = neckWidth;        
        }

        public override string ToString()
        {
            return $"{base.ToString()}, Neck Width: {NeckWidth}";
        }

        public override void PlayingMethod()
        {
            PlayingMethodAdvice = "You should play this guitar with your fingers";
        }
    }
}