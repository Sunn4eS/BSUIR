using System;

namespace TestFramework
{
    public class TestAssertionException : Exception
    {
        public TestAssertionException(string message) : base(message)
        {
        }
    }
}