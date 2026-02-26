using Application.Tests;
using System;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using TestFramework;

namespace TestRunner
{
    class Program
    {
        private static readonly object _consoleLock = new object();

        static void Main()
        {
            Console.WriteLine("=== TEST RUNNER ===\n");

            int maxDegree = 6;
            Console.WriteLine($"Максимум потоков: {maxDegree}");

            var testTypes = GetTestClasses();
            
            var sw = Stopwatch.StartNew();

            var (total, passed, failed) = RunAllTests(testTypes, maxDegree);

            sw.Stop();

            Console.WriteLine($"\nИТОГО: Запущено: {total}, Успешно: {passed}, Провалено: {failed}");
            Console.WriteLine($"ВРЕМЯ ВЫПОЛНЕНИЯ: {sw.Elapsed.TotalSeconds:F3} сек.");
            Console.ReadLine();
        }

        private static Type[] GetTestClasses()
        {
            return Assembly.GetAssembly(typeof(ValidationTests))!
                .GetTypes()
                .Where(t => t.HasAttr<TestClassAttribute>())
                .ToArray();
        }

        private static (int t, int p, int f) RunAllTests(Type[] classes, int maxDegree)
        {
            int t = 0, p = 0, f = 0;
            foreach (var type in classes)
            {
                var res = RunTestsForClass(type, maxDegree);
                t += res.t; p += res.p; f += res.f;
            }
            return (t, p, f);
        }

        static (int t, int p, int f) RunTestsForClass(Type type, int maxDegree)
        {
            LogClassName(type);

            
            var context = CreateSharedContext(type);
            context?.Init();

           
            var methods = type.GetMethods();
            var setup = methods.FirstOrDefault(m => m.HasAttr<SetupAttribute>());
            var teardown = methods.FirstOrDefault(m => m.HasAttr<TeardownAttribute>());

            var classAttr = type.GetCustomAttribute<TestClassAttribute>();
            bool runParallel = classAttr?.RunParallel ?? true;


            int t = 0, p = 0, f = 0;
            var tests = GetSortedTests(methods).ToList();

            if (runParallel)
            {
                var options = new ParallelOptions { MaxDegreeOfParallelism = maxDegree };

                Parallel.ForEach(tests, options, method =>
                {
                    var (mt, mp, mf) = RunTestMethod(type, method, setup, teardown, context);
                    Interlocked.Add(ref t, mt);
                    Interlocked.Add(ref p, mp);
                    Interlocked.Add(ref f, mf);
                });
            }
            else
            {
                foreach (var method in tests)
                {
                    var (mt, mp, mf) = RunTestMethod(type, method, setup, teardown, context);
                    t += mt; p += mp; f += mf;
                }
            }

            context?.Cleanup();
            return (t, p, f);
        }

        static (int t, int p, int f) RunTestMethod(Type type, MethodInfo m, MethodInfo? s, MethodInfo? td, object? ctx)
        {
            var attr = m.GetCustomAttribute<TestMethodAttribute>()!;
            if (attr.Skip)
            {
                PrintStatus(m.Name, "SKIPPED", ConsoleColor.Yellow);
                return (0, 0, 0);
            }

            int t = 0, p = 0, f = 0;
            var testCases = m.GetCustomAttributes<TestCaseAttribute>()
                .Select(a => a.Arguments)
                .DefaultIfEmpty(null);

            foreach (var args in testCases)
            {
                t++;
                bool success = Execute(type, m, s, td, ctx, args);
                if (success) p++; else f++;
            }
            return (t, p, f);
        }

        static bool Execute(Type type, MethodInfo m, MethodInfo? s, MethodInfo? td, object? ctx, object[]? args)
        {
            string name = FormatTestName(m, args);

            var timeoutAttr = m.GetCustomAttribute<TimeoutAttribute>();
            int timeoutMs = timeoutAttr?.Milliseconds ?? -1;

            try
            {
                object? instance = CreateInstance(type, ctx);

                Action testAction = () =>
                {
                    s?.Invoke(instance, null);       
                    try
                    {
                        m.Invoke(instance, args);    
                    }
                    catch (TargetInvocationException ex)
                    {
                        throw ex.InnerException!;
                    }
                    finally
                    {
                        InvokeSafe(td, instance);   
                    }
                };

                Task task = Task.Run(testAction);

                bool completedInTime = task.Wait(timeoutMs);

                if (!completedInTime)
                {
                    PrintStatus(name, "FAILED", ConsoleColor.Red, $"Timeout ({timeoutMs}ms)");
                    return false;
                }

                if (task.IsFaulted)
                {
                    throw task.Exception!.InnerException!;
                }

                PrintStatus(name, "PASSED", ConsoleColor.Green, $"(Thread {Thread.CurrentThread.ManagedThreadId})");
                return true;
            }
            catch (Exception ex)
            {
                HandleException(name, ex);
                return false;
            }
        }

        private static object CreateInstance(Type type, object? ctx)
        {
            return ctx != null 
                ? Activator.CreateInstance(type, ctx)! 
                : Activator.CreateInstance(type)!;
        }

        private static void HandleException(string name, Exception ex)
        {
            var err = ex is AggregateException ae ? ae.Flatten().InnerException : ex;
            bool isAssert = err is TestAssertionException;
            
            var status = isAssert ? "FAILED" : "ERROR";
            var color = isAssert ? ConsoleColor.Red : ConsoleColor.DarkRed;

            PrintStatus(name, status, color, err?.Message);
        }

        private static void InvokeSafe(MethodInfo? method, object? instance)
        {
            try { method?.Invoke(instance, null); } catch { }
        }

        private static IOrderedEnumerable<MethodInfo> GetSortedTests(MethodInfo[] methods)
        {
            return methods
                .Where(m => m.HasAttr<TestMethodAttribute>())
                .OrderBy(m => m.GetCustomAttribute<TestMethodAttribute>()!.Priority);
        }

        private static ISharedContext? CreateSharedContext(Type type)
        {
            var attr = type.GetCustomAttribute<UseSharedContextAttribute>();
            if (attr == null) return null;
            return Activator.CreateInstance(attr.ContextType) as ISharedContext;
        }

        private static string FormatTestName(MethodInfo m, object[]? args)
        {
            if (args == null) return m.Name;
            return $"{m.Name}({string.Join(", ", args)})";
        }

        private static void LogClassName(Type type)
        {
            lock (_consoleLock)
            {
                var attr = type.GetCustomAttribute<TestClassAttribute>();
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine($"\nКЛАСС: {type.Name} {attr?.Description}");
                Console.ResetColor();
            }
        }

        private static void PrintStatus(string n, string s, ConsoleColor c, string? msg = null)
        {
            lock (_consoleLock)
            {

                Console.Write($"[{n}] ");
                Console.ForegroundColor = c;
                Console.Write(s);
                Console.ResetColor();
                if (msg != null) Console.Write($" -> {msg}");
                Console.WriteLine();
            }
        }
    }

    public static class Ext 
    {
        public static bool HasAttr<T>(this MemberInfo m) where T : Attribute 
            => m.GetCustomAttribute<T>() != null;
    }
}