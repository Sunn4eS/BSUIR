using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Collections.Generic;

namespace LemerGeneratorLab
{
    class Program
    {
        const long m = 2147483648L;     
        const long a = 1103515245L;
        const long c = 12345L;

        const int N = 1000;
        const int K = 20;

        static readonly (double p, double crit)[] ChiSquareTable = new[]
        {
            (0.99, 7.633),
            (0.95, 10.117),
            (0.90, 10.865),
            (0.10, 27.204),
            (0.05, 30.144),
            (0.01, 36.191)
        };

        static readonly (double p, double a, double b)[] KSTable = new[]
        {
            (0.99, 0.0709, 0.15),
            (0.95, 0.1601, 0.14),
            (0.75, 0.3793, 0.15),
            (0.50, 0.5887, 0.15),
            (0.25, 0.8326, 0.16),
            (0.05, 1.2239, 0.17),
            (0.01, 1.5174, 0.2)
        };

        static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;

            long[] seeds = { 1L, 12345L, 987654321L };

            var histData = new List<int[]>();
            var cdfData = new List<double[]>();
            var runSummaries = new List<RunSummary>();

            for (int run = 0; run < seeds.Length; run++)
            {
                Console.WriteLine($"=== Прогон {run + 1} (x0 = {seeds[run]}) ===\n");
                var (numbers, uniform) = GenerateSequence(seeds[run], N);

                var hist = BuildHistogram(uniform, K);
                histData.Add(hist);
                Console.WriteLine("Гистограмма (частоты по интервалам):");
                for (int i = 0; i < K; i++)
                {
                    double left = (double)i / K;
                    double right = (double)(i + 1) / K;
                    Console.WriteLine($"[{left:F2}; {right:F2}) : {hist[i]}");
                }

                double chiSq = ChiSquareTest(hist, N, K);
                string chiP = GetChiSquareRange(chiSq, K - 1);
                Console.WriteLine($"\nСтатистика хи-квадрат V = {chiSq:F4}");
                Console.WriteLine($"Диапазон p: {chiP}");

                Array.Sort(uniform);
                var (ksPlus, ksMinus, ksMax) = KSTest(uniform, N);
                string ksP = GetKSRange(ksMax, N);
                Console.WriteLine($"K+ = {ksPlus:F4}, K- = {ksMinus:F4}, K = {ksMax:F4}");
                Console.WriteLine($"Диапазон p: {ksP}");

                cdfData.Add(uniform);

                runSummaries.Add(new RunSummary
                {
                    Seed = seeds[run],
                    ChiSq = chiSq,
                    ChiRange = chiP,
                    KsPlus = ksPlus,
                    KsMinus = ksMinus,
                    KsMax = ksMax,
                    KsRange = ksP
                });

                Console.WriteLine("\n" + new string('-', 50) + "\n");
            }

            string html = GenerateHtmlReport(seeds, histData, cdfData, runSummaries);
            string filePath = Path.Combine(Directory.GetCurrentDirectory(), "report.html");
            File.WriteAllText(filePath, html, Encoding.UTF8);
            Console.WriteLine($"HTML отчёт сохранён: {filePath}");
        }

        static (long[] raw, double[] uniform) GenerateSequence(long seed, int count)
        {
            long[] raw = new long[count];
            double[] uniform = new double[count];
            long x = seed;
            for (int i = 0; i < count; i++)
            {
                x = (a * x + c) % m;
                raw[i] = x;
                uniform[i] = (double)x / m;
            }
            return (raw, uniform);
        }

        static int[] BuildHistogram(double[] data, int bins)
        {
            int[] hist = new int[bins];
            foreach (var val in data)
            {
                int idx = (int)(val * bins);
                if (idx >= bins) idx = bins - 1; // на случай val == 1.0 (не должно произойти)
                hist[idx]++;
            }
            return hist;
        }

        static double ChiSquareTest(int[] observed, int total, int bins)
        {
            double expected = (double)total / bins;
            double chi = 0;
            for (int i = 0; i < bins; i++)
            {
                double diff = observed[i] - expected;
                chi += (diff * diff) / expected;
            }
            return chi;
        }

        static string GetChiSquareRange(double chi, int df)
        {
            if (df != 19)
            {
                return "Нет таблицы для данного df";
            }

            if (chi < ChiSquareTable[0].crit) return "p < 0.01 (отвергаем)";
            if (chi < ChiSquareTable[1].crit) return "0.01 < p < 0.05 (подозрительно)";
            if (chi < ChiSquareTable[2].crit) return "0.05 < p < 0.10 (слегка подозрительно)";
            if (chi < ChiSquareTable[3].crit) return "0.10 < p < 0.90 (приемлемо)";
            if (chi < ChiSquareTable[4].crit) return "0.90 < p < 0.95 (слегка подозрительно)";
            if (chi < ChiSquareTable[5].crit) return "0.95 < p < 0.99 (подозрительно)";
            return "p > 0.99 (отвергаем)";
        }

        static (double plus, double minus, double max) KSTest(double[] sorted, int n)
        {
            double maxPlus = 0, maxMinus = 0;
            for (int j = 0; j < n; j++)
            {
                double u = sorted[j];
                double fn = (double)(j + 1) / n;   // F_n(x) после скачка в точке x_j
                double fnPrev = (double)j / n;     // F_n(x) до скачка
                double plus = fn - u;              // j/n - u_j (в формулах j от 1 до n)
                double minus = u - fnPrev;         // u_j - (j-1)/n
                if (plus > maxPlus) maxPlus = plus;
                if (minus > maxMinus) maxMinus = minus;
            }
            double sqrtN = Math.Sqrt(n);
            double kPlus = sqrtN * maxPlus;
            double kMinus = sqrtN * maxMinus;
            double kMax = Math.Max(kPlus, kMinus);
            return (kPlus, kMinus, kMax);
        }

        static string GetKSRange(double kStat, int n)
        {
            double sqrtN = Math.Sqrt(n);
            double crit99 = KSTable[0].a - KSTable[0].b / sqrtN;
            double crit95 = KSTable[1].a - KSTable[1].b / sqrtN;
            double crit75 = KSTable[2].a - KSTable[2].b / sqrtN;
            double crit50 = KSTable[3].a - KSTable[3].b / sqrtN;
            double crit25 = KSTable[4].a - KSTable[4].b / sqrtN;
            double crit05 = KSTable[5].a - KSTable[5].b / sqrtN;
            double crit01 = KSTable[6].a - KSTable[6].b / sqrtN;

            if (kStat < crit99) return "p > 0.99 (отвергаем)";
            if (kStat < crit95) return "0.95 < p < 0.99 (подозрительно)";
            if (kStat < crit75) return "0.75 < p < 0.95 (приемлемо)";
            if (kStat < crit50) return "0.50 < p < 0.75 (приемлемо)";
            if (kStat < crit25) return "0.25 < p < 0.50 (приемлемо)";
            if (kStat < crit05) return "0.05 < p < 0.25 (приемлемо)";
            if (kStat < crit01) return "0.01 < p < 0.05 (подозрительно)";
            return "p < 0.01 (отвергаем)";
        }

        static string GenerateHtmlReport(long[] seeds, List<int[]> histData, List<double[]> cdfData, List<RunSummary> summaries)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<!DOCTYPE html>");
            sb.AppendLine("<html>");
            sb.AppendLine("<head>");
            sb.AppendLine("<meta charset=\"UTF-8\">");
            sb.AppendLine("<title>Лабораторная работа №1: Тестирование ГПСЧ</title>");
            sb.AppendLine("<script src=\"https://cdn.jsdelivr.net/npm/chart.js\"></script>");
            sb.AppendLine("<style>");
            sb.AppendLine("body { font-family: Arial; margin: 20px; }");
            sb.AppendLine(".run-block { border: 1px solid #ccc; padding: 20px; margin-bottom: 30px; border-radius: 8px; }");
            sb.AppendLine("canvas { max-width: 800px; margin: 20px 0; }");
            sb.AppendLine("</style>");
            sb.AppendLine("</head>");
            sb.AppendLine("<body>");
            sb.AppendLine("<h1>Лабораторная работа №1: Тестирование генератора псевдослучайных чисел</h1>");
            sb.AppendLine("<p><b>Генератор:</b> смешанный алгоритм Лемера (линейный конгруэнтный метод)</p>");
            sb.AppendLine($"<p><b>Параметры:</b> a = {a}, c = {c}, m = {m}</p>");
            sb.AppendLine($"<p><b>Объём выборки:</b> N = {N}, число интервалов гистограммы K = {K}</p>");

            for (int run = 0; run < seeds.Length; run++)
            {
                sb.AppendLine($"<div class=\"run-block\">");
                sb.AppendLine($"<h2>Прогон {run + 1} (x0 = {seeds[run]})</h2>");
                sb.AppendLine($"<p>Статистика хи-квадрат V = {summaries[run].ChiSq:F4}, диапазон p: {summaries[run].ChiRange}</p>");
                sb.AppendLine($"<p>КС: K+ = {summaries[run].KsPlus:F4}, K- = {summaries[run].KsMinus:F4}, K = {summaries[run].KsMax:F4}, диапазон p: {summaries[run].KsRange}</p>");

                // Гистограмма
                sb.AppendLine($"<h3>Гистограмма</h3>");
                sb.AppendLine($"<canvas id=\"histChart{run}\" width=\"800\" height=\"400\"></canvas>");

                // График CDF
                sb.AppendLine($"<h3>Эмпирическая и теоретическая функции распределения</h3>");
                sb.AppendLine($"<canvas id=\"cdfChart{run}\" width=\"800\" height=\"400\"></canvas>");

                sb.AppendLine($"</div>");
            }

            // Скрипты для построения графиков
            sb.AppendLine("<script>");
            for (int run = 0; run < seeds.Length; run++)
            {
                // Данные гистограммы
                var hist = histData[run];
                string labels = string.Join(",", Enumerable.Range(0, K).Select(i => $"'{(double)i / K:F2}-{(double)(i + 1) / K:F2}'"));
                string values = string.Join(",", hist);

                sb.AppendLine($@"
                var ctxHist{run} = document.getElementById('histChart{run}').getContext('2d');
                new Chart(ctxHist{run}, {{
                    type: 'bar',
                    data: {{
                        labels: [{labels}],
                        datasets: [{{
                            label: 'Частота',
                            data: [{values}],
                            backgroundColor: 'rgba(54, 162, 235, 0.6)',
                            borderColor: 'rgba(54, 162, 235, 1)',
                            borderWidth: 1
                        }}]
                    }},
                    options: {{
                        scales: {{
                            y: {{
                                beginAtZero: true,
                                title: {{
                                    display: true,
                                    text: 'Количество чисел'
                                }}
                            }},
                            x: {{
                                title: {{
                                    display: true,
                                    text: 'Интервалы'
                                }}
                            }}
                        }}
                    }}
                }});");

                // Данные для CDF
                var sorted = cdfData[run];
                // Создаем точки эмпирической CDF (ступенчатая)
                var empPoints = new List<string>();
                empPoints.Add("{x:0, y:0}");
                for (int j = 0; j < sorted.Length; j++)
                {
                    // На каждом скачке значение увеличивается
                    double x = sorted[j];
                    double y = (double)(j + 1) / N;
                    empPoints.Add($"{{x:{x.ToString(System.Globalization.CultureInfo.InvariantCulture)}, y:{y.ToString(System.Globalization.CultureInfo.InvariantCulture)}}}");
                }
                // Добавляем точку (1,1) для завершения
                empPoints.Add("{x:1, y:1}");
                string empData = string.Join(",", empPoints);

                // Теоретическая CDF - прямая y=x, две точки достаточно
                string theoData = "{x:0, y:0}, {x:1, y:1}";

                sb.AppendLine($@"
                var ctxCdf{run} = document.getElementById('cdfChart{run}').getContext('2d');
                new Chart(ctxCdf{run}, {{
                    type: 'line',
                    data: {{
                        datasets: [{{
                            label: 'Эмпирическая F_n(x)',
                            data: [{empData}],
                            stepped: true,
                            borderColor: 'rgba(255, 99, 132, 1)',
                            backgroundColor: 'transparent',
                            borderWidth: 2
                        }},
                        {{
                            label: 'Теоретическая F(x)=x',
                            data: [{theoData}],
                            borderColor: 'rgba(75, 192, 192, 1)',
                            borderDash: [5, 5],
                            borderWidth: 2,
                            fill: false
                        }}]
                    }},
                    options: {{
                        scales: {{
                            x: {{
                                type: 'linear',
                                min: 0,
                                max: 1,
                                title: {{
                                    display: true,
                                    text: 'x'
                                }}
                            }},
                            y: {{
                                min: 0,
                                max: 1,
                                title: {{
                                    display: true,
                                    text: 'F(x)'
                                }}
                            }}
                        }}
                    }}
                }});");
            }
            sb.AppendLine("</script>");

            sb.AppendLine("</body>");
            sb.AppendLine("</html>");
            return sb.ToString();
        }

        // Класс для хранения сводки по прогону
        class RunSummary
        {
            public long Seed { get; set; }
            public double ChiSq { get; set; }
            public string ChiRange { get; set; }
            public double KsPlus { get; set; }
            public double KsMinus { get; set; }
            public double KsMax { get; set; }
            public string KsRange { get; set; }
        }
    }
}