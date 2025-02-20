namespace MusicShop
{
    public class Strings
    {
        private int[] size_arr = new int[2];
        public string Model { get; set; }
        public string Brand { get; set; }
        public int Price { get; set; }
        public string Material { get; set; }
        public int[] Size
        {
            get { return size_arr; }
        }
        
    }
}