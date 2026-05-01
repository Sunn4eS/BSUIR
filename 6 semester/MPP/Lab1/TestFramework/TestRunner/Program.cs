using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.Threading;
using TestFramework;
using Application.Tests;

namespace TestRunner
{
    public delegate bool TestFilter(MethodInfo method);

    class Program
    {
        static int _passed, _failed;

        static void Main()
        {
            Console.WriteLine("=== ЗАПУСК ТЕСТОВОЙ ПЛАТФОРМЫ (ЛР 4) ===\n");

            TestFilter filter = (m) =>
            {
                var attr = m.GetCustomAttribute<TestMethodAttribute>();
                return attr != null && attr.Priority <= 10;
            };

            //TestFilter filter = (m) => m.GetCustomAttribute<CategoryAttribute>()?.Name == "Smoke";

            var testActions = DiscoveryTests(filter);

            using (var pool = new CustomThreadPool(minThreads: 2, maxThreads: 10, idleTimeoutMs: 2000, stuckTimeoutMs: 4000))
            {
                pool.WorkerCreated += (s, e) => PrintEvent($"[ПУЛ] Поток {e.WorkerId:D2} запущен", ConsoleColor.Cyan);
                pool.WorkerRemoved += (s, e) => PrintEvent($"[ПУЛ] Поток {e.WorkerId:D2} удален (простой)", ConsoleColor.Yellow);
                pool.ThreadStuck += (s, e) => PrintEvent($"[ПУЛ] Поток {e.WorkerId:D2} ЗАВИС!", ConsoleColor.Magenta);
                pool.TaskStarted += (s, e) => { };

                Console.WriteLine($"[Инфо] Подготовлено тестов к запуску: {testActions.Count}\n");

                var sw = Stopwatch.StartNew();

                foreach (var action in testActions)
                {
                    pool.Enqueue(action);
                }

                pool.WaitAll();
                sw.Stop();

                Console.WriteLine($"\n=== ИТОГИ ===");
                Console.WriteLine($"Успешно: {_passed} | Провалено: {_failed}");
                Console.WriteLine($"Время: {sw.Elapsed.TotalSeconds:F2} сек.");
            }

            Console.WriteLine("\nНажмите Enter для выхода...");
            Console.ReadLine();
        }

        private static List<Action> DiscoveryTests(TestFilter filter)
        {
            var actions = new List<Action>();

            var testClasses = Assembly.GetAssembly(typeof(ValidationTests))
                .GetTypes()
                .Where(t => t.GetCustomAttribute<TestClassAttribute>() != null);

            foreach (var type in testClasses)
            {
                var methods = type.GetMethods();
                var setup = methods.FirstOrDefault(m => m.GetCustomAttribute<SetupAttribute>() != null);
                var teardown = methods.FirstOrDefault(m => m.GetCustomAttribute<TeardownAttribute>() != null);

                foreach (var m in methods)
                {
                    if (m.GetCustomAttribute<TestMethodAttribute>() == null) continue;
                    if (!filter(m)) continue;

                    var sourceAttr = m.GetCustomAttribute<TestCaseSourceAttribute>();
                    if (sourceAttr != null)
                    {
                        var sourceMethod = type.GetMethod(sourceAttr.MethodName, BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
                        if (sourceMethod != null)
                        {
                            var dataSet = (IEnumerable<object[]>)sourceMethod.Invoke(null, null);
                            foreach (var args in dataSet)
                            {
                                actions.Add(() => ExecuteTest(type, m, setup, teardown, args));
                            }
                            continue;
                        }
                    }

                    var testCases = m.GetCustomAttributes<TestCaseAttribute>();
                    if (testCases.Any())
                    {
                        foreach (var tc in testCases)
                            actions.Add(() => ExecuteTest(type, m, setup, teardown, tc.Arguments));
                    }
                    else
                    {
                        actions.Add(() => ExecuteTest(type, m, setup, teardown, null));
                    }
                }
            }
            return actions;
        }

        private static void ExecuteTest(Type type, MethodInfo m, MethodInfo s, MethodInfo td, object[] args)
        {
            string testName = args == null ? m.Name : $"{m.Name}({string.Join(", ", args)})";
            object instance = Activator.CreateInstance(type);

            try
            {
                s?.Invoke(instance, null); 
                m.Invoke(instance, args);  

                Interlocked.Increment(ref _passed);
                PrintResult(testName, "PASSED", ConsoleColor.Green);
            }
            catch (Exception ex)
            {
                Interlocked.Increment(ref _failed);
                var inner = ex.InnerException ?? ex;
                PrintResult(testName, "FAILED", ConsoleColor.Red, inner.Message);
            }
            finally
            {
                try { td?.Invoke(instance, null); } catch { } 
            }
        }

        private static void PrintResult(string name, string status, ConsoleColor color, string msg = "")
        {
            lock (Console.Out)
            {
                int tid = CustomThreadPool.CurrentWorkerId.Value;
                Console.ForegroundColor = color;
                Console.Write($"[Поток {tid:D2}] {status.PadRight(8)}");
                Console.ResetColor();
                Console.WriteLine($": {name} {msg}");
            }
        }

        private static void PrintEvent(string message, ConsoleColor color)
        {
            lock (Console.Out)
            {
                Console.ForegroundColor = color;
                Console.WriteLine($" >>> {message}");
                Console.ResetColor();
            }
        }
    }
}