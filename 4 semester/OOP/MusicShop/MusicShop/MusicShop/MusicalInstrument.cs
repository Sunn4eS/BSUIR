namespace MusicShop
{
    public abstract class MusicalInstrument
    {
        private static int _objectCounter;
        public static int ObjectCounter => _objectCounter;

        static MusicalInstrument()
        {
            _objectCounter = 0;
        }

        protected MusicalInstrument()
        {
            _objectCounter++;
        }

    }
}