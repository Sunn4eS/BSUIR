using System;

namespace Syntax
{
    public class RecognizingResult
    {
        public RecognizingResult(string errorElementName, bool isHome)
        {
            ErrorElementName = errorElementName;
            IsHome = isHome;
        }

        public string ErrorElementName { get; }
        public bool IsHome { get; }
    }
}