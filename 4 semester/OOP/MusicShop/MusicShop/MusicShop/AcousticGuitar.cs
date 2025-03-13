using System;

namespace MusicShop
{
    public class AcousticGuitar : Guitar
    {
        public string GuitarType;
        public string PlayingMethodAdvice;

        public AcousticGuitar(string guitarType, string brand, string model, int countOfStrings, int price, string housingType,
            string country, Strings stringsModel) :
            base(brand, model, countOfStrings, price, housingType, country, stringsModel)
        {
           GuitarType = guitarType; 
        }

        public override string ToString()
        {
            return $"{base.ToString()}, Guitar Type: {GuitarType}";
        }

        public override void PlayingMethod()
        {
            PlayingMethodAdvice = "You can play this guitar with pick or with your fingers";
        }
    }
}   