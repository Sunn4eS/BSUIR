using System;

namespace TestFramework
{

    [AttributeUsage(AttributeTargets.Class)]
    public class TestClassAttribute : Attribute
    {
        public string Description { get; set; }

        //Паралеллизм 
        public bool RunParallel { get; set; } = true;
        public TestClassAttribute() { }
    }

    // Для таймаута
    [AttributeUsage(AttributeTargets.Method)]
    public class TimeoutAttribute : Attribute
    {
        public int Milliseconds { get; }

        public TimeoutAttribute(int milliseconds)
        {
            Milliseconds = milliseconds;
        }
    }


    [AttributeUsage(AttributeTargets.Method)]
    public class SetupAttribute : Attribute { }
   
    [AttributeUsage(AttributeTargets.Method)]
    public class TeardownAttribute : Attribute { }


    [AttributeUsage(AttributeTargets.Method)]
    public class TestMethodAttribute : Attribute
    {
        public bool Skip { get; set; } = false;

        public string Description { get; set; }

        public int Priority { get; set; } = 5;
    }

    [AttributeUsage(AttributeTargets.Method, AllowMultiple = true)]
    public class TestCaseAttribute : Attribute
    {
        public object[] Arguments { get; }

        public TestCaseAttribute(params object[] args)
        {
            Arguments = args;
        }
    }
}