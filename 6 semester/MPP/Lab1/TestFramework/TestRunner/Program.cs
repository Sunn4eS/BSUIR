using Application.Tests; 
using TestFramework;
using System.Reflection;

namespace TestRunner
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("==================================================");
            Console.WriteLine("                  TEST RUNNER                     ");
            Console.WriteLine("==================================================\n");

            var testAssembly = Assembly.GetAssembly(typeof(ValidationTests));

            var testClasses = testAssembly.GetTypes()
                .Where(t => t.GetCustomAttribute<TestClassAttribute>() != null)
                .ToArray();

            int globalTotal = 0, globalPassed = 0, globalFailed = 0;

            foreach (var classType in testClasses)
            {
                RunTestsForClass(classType, ref globalTotal, ref globalPassed, ref globalFailed);
                Console.WriteLine();
            }

            Console.WriteLine("==================================================");
            Console.WriteLine($"ИТОГО: Запущено: {globalTotal}, Успешно: {globalPassed}, Провалено: {globalFailed}");
            Console.ReadLine();
        }

       
        static void RunTestsForClass(Type classType, ref int total, ref int passed, ref int failed)
        {
            var classAttr = classType.GetCustomAttribute<TestClassAttribute>();
            string description = classAttr.Description ?? "";

            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine($"КЛАСС: {classType.Name}");
            if (!string.IsNullOrEmpty(description)) Console.WriteLine($"INFO:  {description}");
            Console.ResetColor();

            object sharedContextObject = null;
            ISharedContext contextInterface = null;

            var contextAttr = classType.GetCustomAttribute<UseSharedContextAttribute>();
            if (contextAttr != null)
            {
                try
                {
                    sharedContextObject = Activator.CreateInstance(contextAttr.ContextType);

                    if (sharedContextObject is ISharedContext ctx)
                    {
                        contextInterface = ctx;
                        ctx.Init();
                    }
                }
                catch (Exception ex)
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine($"CRITICAL: Не удалось создать Shared Context: {ex.Message}");
                    Console.ResetColor();
                    return;
                }
            }

            var setupMethod = classType.GetMethods().FirstOrDefault(m => m.GetCustomAttribute<SetupAttribute>() != null);
            var teardownMethod = classType.GetMethods().FirstOrDefault(m => m.GetCustomAttribute<TeardownAttribute>() != null);

            var testMethods = classType.GetMethods()
                .Where(m => m.GetCustomAttribute<TestMethodAttribute>() != null)
                .OrderBy(m => m.GetCustomAttribute<TestMethodAttribute>().Priority)
                .ToArray();

            foreach (var method in testMethods)
            {
                var methodAttr = method.GetCustomAttribute<TestMethodAttribute>();

                if (methodAttr.Skip)
                {
                    PrintResult(method.Name, "SKIPPED", ConsoleColor.Yellow, "Пропущен");
                    continue;
                }

                var testCases = method.GetCustomAttributes<TestCaseAttribute>().ToArray();
                if (testCases.Length > 0)
                {
                    foreach (var tc in testCases)
                    {
                        ExecuteSingleTest(classType, method, setupMethod, teardownMethod, sharedContextObject, tc.Arguments, ref total, ref passed, ref failed);
                    }
                }
                else
                {
                    ExecuteSingleTest(classType, method, setupMethod, teardownMethod, sharedContextObject, null, ref total, ref passed, ref failed);
                }
            }

            if (contextInterface != null)
            {
                try
                {
                    contextInterface.Cleanup();
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Ошибка очистки контекста: {ex.Message}");
                }
            }
        }

        static void ExecuteSingleTest(Type classType, MethodInfo method, MethodInfo setup, MethodInfo teardown,
                                      object sharedContext, object[] args,
                                      ref int total, ref int passed, ref int failed)
        {
            total++;
            string testName = method.Name + (args != null ? $"({string.Join(", ", args)})" : "");

            object instance = null;

            try
            {
                if (sharedContext != null)
                {
                    instance = Activator.CreateInstance(classType, new object[] { sharedContext });
                }
                else
                {
                    instance = Activator.CreateInstance(classType);
                }

                setup?.Invoke(instance, null);

                var result = method.Invoke(instance, args);

                if (result is Task task)
                {
                    task.GetAwaiter().GetResult();
                }

                PrintResult(testName, "PASSED", ConsoleColor.Green);
                passed++;
            }
            catch (TargetInvocationException ex)
            {
                var inner = ex.InnerException;
                if (inner is TestAssertionException)
                {
                    PrintResult(testName, "FAILED", ConsoleColor.Red, inner.Message);
                }
                else
                {
                    PrintResult(testName, "ERROR", ConsoleColor.DarkRed, $"{inner.GetType().Name}: {inner.Message}");
                }
                failed++;
            }
            catch (Exception ex)
            {
                PrintResult(testName, "CRASH", ConsoleColor.DarkRed, ex.Message);
                failed++;
            }
            finally
            {
                try
                {
                    if (instance != null) teardown?.Invoke(instance, null);
                }
                catch {}
            }
        }

        static void PrintResult(string name, string status, ConsoleColor color, string msg = "")
        {
            Console.Write($"[{name}] ");
            Console.ForegroundColor = color;
            Console.Write(status);
            Console.ResetColor();
            if (!string.IsNullOrEmpty(msg)) Console.Write($" -> {msg}");
            Console.WriteLine();
        }
    }
}