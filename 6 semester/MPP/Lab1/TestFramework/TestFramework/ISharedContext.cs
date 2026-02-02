

namespace TestFramework
{
    public interface ISharedContext
    {
        void Init();   
        void Cleanup(); 
    }

    [System.AttributeUsage(System.AttributeTargets.Class)]
    public class UseSharedContextAttribute : System.Attribute
    {
        public System.Type ContextType { get; }

        public UseSharedContextAttribute(System.Type contextType)
        {
            ContextType = contextType;
        }
    }
}