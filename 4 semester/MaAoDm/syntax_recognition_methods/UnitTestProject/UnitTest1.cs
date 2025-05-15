using System;
using System.Diagnostics;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Syntax;

namespace UnitTestProject
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestMethod1()
        {
            var homeGrammar = new HomeGrammar();
            Element res = homeGrammar.GetHome();
            Debug.Assert(true);
        }
    }
}
