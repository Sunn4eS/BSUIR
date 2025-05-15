using System;

namespace Syntax
{
    public class InvalidElementException : Exception
    {
        public InvalidElementException() : base("Can't create grammar from elements")
        {
        }
    }
}