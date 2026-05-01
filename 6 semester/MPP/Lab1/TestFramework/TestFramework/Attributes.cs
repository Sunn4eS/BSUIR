using System;

namespace TestFramework
{

    [AttributeUsage(AttributeTargets.Method | AttributeTargets.Class)]
    public class CategoryAttribute : Attribute
    {
        public string Name { get; }
        public CategoryAttribute(string name) => Name = name;
    }

    // yield return
    [AttributeUsage(AttributeTargets.Method)]
    public class TestCaseSourceAttribute : Attribute
    {
        public string MethodName { get; }
        public TestCaseSourceAttribute(string methodName) => MethodName = methodName;
    }


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