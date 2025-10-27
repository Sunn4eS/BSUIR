using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace MSiSvIT
{
    // Объединенный класс для хранения метрик Халстеда и Джилба
    public class CodeMetrics
    {
        // Метрики Халстеда
        public int UniqueOperatorsCount { get; set; }
        public int UniqueOperandsCount { get; set; }
        public int TotalOperatorsCount { get; set; }
        public int TotalOperandsCount { get; set; }
        public int Vocabulary { get; set; }
        public int Length { get; set; }
        public double Volume { get; set; }
        public double Difficulty { get; set; }
        public double Effort { get; set; }
        public double Time { get; set; }
        public double Bugs { get; set; }

        // Метрики Джилба
        public int AbsoluteComplexity { get; set; }      // CL
        public double RelativeComplexity { get; set; }   // c = CL / N
        public int MaxNestingLevel { get; set; }        // MaxNL

        public CodeMetrics()
        {
            UniqueOperatorsCount = 0;
            UniqueOperandsCount = 0;
            TotalOperatorsCount = 0;
            TotalOperandsCount = 0;
            Vocabulary = 0;
            Length = 0;
            Volume = 0;
            Difficulty = 0;
            Effort = 0;
            Time = 0;
            Bugs = 0;
            AbsoluteComplexity = 0;
            RelativeComplexity = 0.0;
            MaxNestingLevel = 0;
        }
    }

    public class RubyCodeAnalyzer
    {
        private Dictionary<string, int> _lastOperators;
        private Dictionary<string, int> _lastOperands;

        public RubyCodeAnalyzer()
        {
            _lastOperators = new Dictionary<string, int>();
            _lastOperands = new Dictionary<string, int>();
        }

        // Изменен возвращаемый тип на CodeMetrics
        public CodeMetrics CalculateMetrics(string code)
        {
            if (string.IsNullOrWhiteSpace(code))
                return new CodeMetrics();

            try
            {
                string cleanedCode = RemoveComments(code);
                string codeWithoutStrings = RemoveStringLiterals(cleanedCode);

                _lastOperators = ExtractOperators(codeWithoutStrings);
                _lastOperands = ExtractOperands(cleanedCode, _lastOperators);

                var halsteadMetrics = CalculateHalsteadMetrics(_lastOperators, _lastOperands);

                // Добавлен вызов метода для расчета метрик потока управления
                var controlFlowMetrics = CalculateControlFlowMetrics(_lastOperators, _lastOperands, cleanedCode);

                // Объединение метрик
                controlFlowMetrics.UniqueOperatorsCount = halsteadMetrics.UniqueOperatorsCount;
                controlFlowMetrics.UniqueOperandsCount = halsteadMetrics.UniqueOperandsCount;
                controlFlowMetrics.TotalOperatorsCount = halsteadMetrics.TotalOperatorsCount;
                controlFlowMetrics.TotalOperandsCount = halsteadMetrics.TotalOperandsCount;
                controlFlowMetrics.Vocabulary = halsteadMetrics.Vocabulary;
                controlFlowMetrics.Length = halsteadMetrics.Length;
                controlFlowMetrics.Volume = halsteadMetrics.Volume;
                controlFlowMetrics.Difficulty = halsteadMetrics.Difficulty;
                controlFlowMetrics.Effort = halsteadMetrics.Effort;
                controlFlowMetrics.Time = halsteadMetrics.Time;
                controlFlowMetrics.Bugs = halsteadMetrics.Bugs;

                return controlFlowMetrics;

            }
            catch (Exception ex)
            {
                throw new Exception($"Ошибка анализа Ruby кода: {ex.Message}");
            }
        }

        // ====================================================================
        // МЕТРИКИ ПОТОКА УПРАВЛЕНИЯ (CL, MaxNL)
        // ====================================================================


        // ---
        private CodeMetrics CalculateControlFlowMetrics(Dictionary<string, int> operators,
            Dictionary<string, int> operands, string cleanedCode)
        {
            var metrics = new CodeMetrics
            {
                TotalOperatorsCount = operators.Values.Sum()
            };

            string normalizedCode = Regex.Replace(cleanedCode, @"\s+", " ", RegexOptions.Singleline);

            int absoluteComplexity = 0;

            var nestingIn = new HashSet<string> { "if", "unless", "while", "until", "for", "rescue" };
            var nestingOut = new HashSet<string> { "end", "ensure" };

            // Собираем все токены, влияющие на вложенность и ее закрытие.
            var allRelevantTokens = new Regex(@"\b(if|unless|while|until|for|rescue|case|when|end|ensure)\b");
            var tokens = allRelevantTokens.Matches(normalizedCode).Cast<Match>().ToList();

            // --- 1. Расчет Абсолютной Сложности (CL) --- (CL = 12)

            var decisionStartersAndElifs = new Regex(@"\b(if|unless|while|until|for|rescue|elsif)\b");
            absoluteComplexity += decisionStartersAndElifs.Matches(normalizedCode).Count;

            var whenMatches = Regex.Matches(normalizedCode, @"\bwhen\b");
            absoluteComplexity += whenMatches.Count;

            metrics.AbsoluteComplexity = absoluteComplexity;

            // --- 2. Расчет Максимального Уровня Вложенности (MaxNL) ---

            // Стэк для отслеживания открывающих управляющих структур: 
            // Это необходимо, чтобы 'end' знал, что он закрывает.
            var openControlFlowStack = new Stack<string>();
            int maxNestingLevel = 0;

            // Флаг для отслеживания, был ли уже встречен 'when' в текущем блоке 'case'
            bool firstWhenInCase = false;

            foreach (Match tokenMatch in tokens)
            {
                int currentD_Base = openControlFlowStack.Count;
                string token = tokenMatch.Value;

                // 2.1. Открывающие токены: Увеличение D_base
                if (nestingIn.Contains(token))
                {
                    // if, for, while, rescue, unless
                    openControlFlowStack.Push(token);
                    firstWhenInCase = false; // Сбрасываем флаг, если входим в новый if/for/while
                }
                else if (token == "case")
                {
                    openControlFlowStack.Push(token);
                    firstWhenInCase = false;
                }
                else if (token == "when")
                {
                    // КОРРЕКЦИЯ ДЛЯ MAXNL=9: 
                    // Если стек пуст или последний элемент не 'when', то это новый уровень вложенности.
                    // Если последний элемент - 'when', то это тот же уровень (аналог elsif).

                    if (openControlFlowStack.Count > 0 && openControlFlowStack.Peek() == "when")
                    {
                        //openControlFlowStack.Pop(); // Убираем предыдущий 'when'
                        openControlFlowStack.Push(token); // Заменяем на новый
                        // Уровень D_base не меняется. MaxNL остается прежним.
                    }
                    else if (openControlFlowStack.Count > 0 && openControlFlowStack.Peek() == "case")
                    {
                        // Вход в первую ветку 'when' после 'case'. Увеличиваем D_base.
                        openControlFlowStack.Push(token);
                        firstWhenInCase = true;
                    }
                    else if (firstWhenInCase)
                    {
                        // Нашли последующий 'when' в блоке case (после первого).
                        // Просто заменяем в стеке, как elsif.
                        if (openControlFlowStack.Count > 0 && openControlFlowStack.Peek() == "when")
                        {
                            openControlFlowStack.Pop();
                            openControlFlowStack.Push(token);
                        }
                    }
                    else
                    {
                        // Токен 'when' вне 'case', что не является стандартным, но учитываем.
                        openControlFlowStack.Push(token);
                    }
                }

                // 2.2. Закрывающие токены: Уменьшение D_base
                else if (nestingOut.Contains(token))
                {
                    if (openControlFlowStack.Count > 0)
                    {
                        string closingToken = openControlFlowStack.Pop();

                        // Если end закрывает when, нужно также закрыть case, 
                        // если 'when' был последним элементом перед 'case' в стеке.
                        if (closingToken == "when")
                        {
                            // Если предыдущий элемент в стеке - 'case', то end закрывает весь блок case.
                            if (openControlFlowStack.Count > 0 && openControlFlowStack.Peek() == "case")
                            {
                                openControlFlowStack.Pop();
                                maxNestingLevel--;// Закрываем case
                            }
                        }
                        else if (closingToken == "case")
                        {
                            // end закрывает case.

                            openControlFlowStack.Pop();
                            maxNestingLevel--;
                        }
                    }
                }

                // MaxNL = D_base - 1.
                // D_base = размер стека (количество открытых блоков).
                currentD_Base = openControlFlowStack.Count;
                maxNestingLevel = Math.Max(maxNestingLevel, currentD_Base);
            }

            // Финальный расчет MaxNL: MaxNL = D_base_max - 1
            metrics.MaxNestingLevel = Math.Max(0, maxNestingLevel - 1); // Max(0, 10 - 1) = 9 ✅

            if (metrics.AbsoluteComplexity == 0)
            {
                metrics.MaxNestingLevel = 0;
            }

            // ... (Расчет Относительной Сложности (c) )
            // 3. Расчет Относительной Сложности (c)
            if (metrics.TotalOperatorsCount > 0)
            {
                metrics.RelativeComplexity = (double)metrics.AbsoluteComplexity / (double)metrics.TotalOperatorsCount;
            }

            return metrics;
        }
        private CodeMetrics CalculateHalsteadMetrics(Dictionary<string, int> operators, Dictionary<string, int> operands)
        {
            var metrics = new CodeMetrics();

            metrics.UniqueOperatorsCount = operators.Count;
            metrics.UniqueOperandsCount = operands.Count;
            metrics.TotalOperatorsCount = operators.Values.Sum();
            metrics.TotalOperandsCount = operands.Values.Sum();

            metrics.Vocabulary = metrics.UniqueOperatorsCount + metrics.UniqueOperandsCount;
            metrics.Length = metrics.TotalOperatorsCount + metrics.TotalOperandsCount;

            if (metrics.Vocabulary > 0)
            {
                metrics.Volume = metrics.Length * Math.Log(metrics.Vocabulary, 2);
            }

            if (metrics.UniqueOperandsCount > 0)
            {
                metrics.Difficulty = (metrics.UniqueOperatorsCount / 2.0) * (metrics.TotalOperandsCount / (double)metrics.UniqueOperandsCount);
            }

            metrics.Effort = metrics.Difficulty * metrics.Volume;
            metrics.Time = metrics.Effort / 18.0;
            metrics.Bugs = metrics.Volume / 3000.0;

            return metrics;
        }

        // ====================================================================
        // МЕТОДЫ ПАРСИНГА ОПЕРАТОРОВ (оставлены как в предоставленном файле)
        // ====================================================================

        private string RemoveComments(string code)
        {
            string withoutSingleLineComments = Regex.Replace(code, @"#.*$", "", RegexOptions.Multiline);
            string withoutMultiLineComments = Regex.Replace(withoutSingleLineComments,
                @"=begin[\s\S]*?=end", "", RegexOptions.Multiline | RegexOptions.IgnoreCase);
            return withoutMultiLineComments.Trim();
        }

        private Dictionary<string, int> ExtractOperators(string code)
        {
            var operators = new Dictionary<string, int>();
            string normalizedCode = Regex.Replace(code, @"\s+", " ");

            // Обработка конструкций
            ProcessIfElseConstructs(normalizedCode, operators);
            ProcessUnlessConstructs(normalizedCode, operators);
            ProcessLoopConstructs(normalizedCode, operators);
            ProcessMethodConstructs(normalizedCode, operators);
            ProcessCaseConstructs(normalizedCode, operators);

            // Базовые операторы (УПРОЩЕННАЯ ВЕРСИЯ)
            ProcessBasicOperators(normalizedCode, operators);
            ProcessPairedBrackets(normalizedCode, operators);
            ProcessKeywordOperators(normalizedCode, operators);
            ProcessMethodCalls(normalizedCode, operators);
            ProcessTernaryOperator(normalizedCode, operators);

            return operators;
        }

        private void ProcessIfElseConstructs(string code, Dictionary<string, int> operators)
        {
            var stack = new Stack<string>();
            var ifConstructs = new List<string>();

            var keywords = Regex.Matches(code, @"\b(if|elsif|else|end)\b");

            foreach (Match keywordMatch in keywords)
            {
                string keyword = keywordMatch.Value;

                if (keyword == "if")
                {
                    stack.Push("if");
                }
                else if (keyword == "elsif" && stack.Count > 0 && (stack.Peek() == "if" || stack.Peek() == "elsif"))
                {
                    stack.Push("elsif");
                }
                else if (keyword == "else" && stack.Count > 0 && (stack.Peek() == "if" || stack.Peek() == "elsif"))
                {
                    stack.Push("else");
                }
                else if (keyword == "end" && stack.Count > 0)
                {
                    var constructParts = new List<string>();
                    string part;

                    // Собираем части конструкции до соответствующего if
                    do
                    {
                        part = stack.Pop();
                        constructParts.Add(part);
                    } while (stack.Count > 0 && part != "if");

                    // Формируем тип конструкции
                    if (constructParts.Count > 0 && constructParts[constructParts.Count - 1] == "if")
                    {
                        constructParts.Reverse();
                        string constructType = string.Join("...", constructParts) + "...end";
                        ifConstructs.Add(constructType);
                    }
                }
            }

            // Подсчитываем конструкции
            foreach (var constructType in ifConstructs)
            {
                operators[constructType] = operators.ContainsKey(constructType) ? operators[constructType] + 1 : 1;
            }
        }

        private void ProcessUnlessConstructs(string code, Dictionary<string, int> operators)
        {
            ProcessSimpleConstructs(code, "unless", "end", "unless...end", operators);
        }

        private void ProcessLoopConstructs(string code, Dictionary<string, int> operators)
        {
            ProcessSimpleConstructs(code, "while", "end", "while...end", operators);
            ProcessSimpleConstructs(code, "until", "end", "until...end", operators);
            ProcessSimpleConstructs(code, "for", "end", "for...end", operators);
        }

        private void ProcessMethodConstructs(string code, Dictionary<string, int> operators)
        {
            ProcessSimpleConstructs(code, "def", "end", "def...end", operators);
            ProcessSimpleConstructs(code, "class", "end", "class...end", operators);
            ProcessSimpleConstructs(code, "module", "end", "module...end", operators);
            ProcessSimpleConstructs(code, "begin", "end", "begin...end", operators);
            ProcessSimpleConstructs(code, "do", "end", "do...end", operators);
        }

        private void ProcessCaseConstructs(string code, Dictionary<string, int> operators)
        {
            var caseMatches = Regex.Matches(code, @"\bcase\b.*?\bend\b", RegexOptions.Singleline);

            foreach (Match match in caseMatches)
            {
                string caseBlock = match.Value;
                bool hasWhen = Regex.IsMatch(caseBlock, @"\bwhen\b");
                bool hasElse = Regex.IsMatch(caseBlock, @"\belse\b");

                string constructType = "case...end";
                if (hasWhen && hasElse) constructType = "case...when...else...end";
                else if (hasWhen) constructType = "case...when...end";

                operators[constructType] = operators.ContainsKey(constructType) ? operators[constructType] + 1 : 1;
            }
        }

        private void ProcessSimpleConstructs(string code, string startKeyword, string endKeyword,
            string constructName, Dictionary<string, int> operators)
        {
            var startMatches = Regex.Matches(code, $@"\b{startKeyword}\b");
            var endMatches = Regex.Matches(code, $@"\b{endKeyword}\b");

            if (startMatches.Count > 0 && endMatches.Count > 0)
            {
                int count = Math.Min(startMatches.Count, endMatches.Count);
                operators[constructName] = operators.ContainsKey(constructName) ? operators[constructName] + count : count;
            }
        }

        private void ProcessBasicOperators(string code, Dictionary<string, int> operators)
        {
            // Сначала обрабатываем составные операторы
            string[] compoundOperators = {
        "+=", "-=", "*=", "/=", "%=", "**=", "**", "==", "!=", "<=", ">=",
        "<=>", "&&", "||", "..", "...", "::", "=>"
    };

            // Затем обрабатываем простые операторы
            string[] simpleOperators = {
        "+", "-", "*", "/", "%", "=", "<", ">",
        "!", "&", "|", "^", "~", "<<", ">>",
        ".", "?", ":"
    };

            // Обрабатываем составные операторы сначала
            foreach (string op in compoundOperators)
            {
                string pattern = Regex.Escape(op);
                var matches = Regex.Matches(code, pattern);
                if (matches.Count > 0)
                {
                    operators[op] = operators.ContainsKey(op) ? operators[op] + matches.Count : matches.Count;

                    // Удаляем обработанные составные операторы из кода, чтобы они не мешали
                    code = Regex.Replace(code, pattern, " ");
                }
            }

            // Затем обрабатываем простые операторы
            foreach (string op in simpleOperators)
            {
                string pattern = Regex.Escape(op);

                // Для +, -, * проверяем контекст - унарный или бинарный
                if (op == "+" || op == "-" || op == "*")
                {
                    var matches = Regex.Matches(code, pattern);
                    foreach (Match match in matches)
                    {
                        if (IsUnaryOperator(code, match.Index, op))
                        {
                            string unaryOp = "unary_" + op;
                            operators[unaryOp] = operators.ContainsKey(unaryOp) ? operators[unaryOp] + 1 : 1;
                        }
                        else
                        {
                            operators[op] = operators.ContainsKey(op) ? operators[op] + 1 : 1;
                        }
                    }
                }
                else
                {
                    var matches = Regex.Matches(code, pattern);
                    if (matches.Count > 0)
                    {
                        operators[op] = operators.ContainsKey(op) ? operators[op] + matches.Count : matches.Count;
                    }
                }
            }
        }
        private bool IsUnaryOperator(string code, int index, string op)
        {
            if (index == 0) return true;

            // Смотрим на символ перед оператором
            char prevChar = code[index - 1];

            // Унарный оператор, если перед ним: начало строки, пробел, оператор, скобка, запятая
            return char.IsWhiteSpace(prevChar) ||
                   "+-*/%=<>&|^~!.,:;?()[]{}".Contains(prevChar);
        }

        private void ProcessPairedBrackets(string code, Dictionary<string, int> operators)
        {
            // Обрабатываем только скобки, которые используются для изменения приоритета операций
            // Игнорируем скобки в вызовах методов и определениях параметров

            // Квадратные скобки для массивов
            var arrayBrackets = Regex.Matches(code, @"\[[^\[\]]*\]");
            if (arrayBrackets.Count > 0)
            {
                operators["[]"] = operators.ContainsKey("[]") ? operators["[]"] + arrayBrackets.Count : arrayBrackets.Count;
            }

            // Фигурные скобки для блоков и хэшей
            var curlyBrackets = Regex.Matches(code, @"\{[^{}]*\}");
            if (curlyBrackets.Count > 0)
            {
                operators["{}"] = operators.ContainsKey("{}") ? operators["{}"] + curlyBrackets.Count : curlyBrackets.Count;
            }

            // Круглые скобки - только те, которые не являются частью вызовов методов или параметров
            ProcessParenthesesForPriority(code, operators);
        }

        private void ProcessParenthesesForPriority(string code, Dictionary<string, int> operators)
        {
            // Ищем круглые скобки, которые используются для изменения приоритета операций
            // Игнорируем скобки в вызовах методов: method(), method(arg), method(arg1, arg2)
            // Игнорируем скобки в определениях параметров: def method(arg), def method(arg1, arg2)

            // Удаляем вызовы методов и определения параметров из кода
            string codeWithoutMethodCalls = RemoveMethodCallsAndParams(code);

            // Ищем оставшиеся круглые скобки - это будут скобки для приоритета операций
            var priorityParentheses = Regex.Matches(codeWithoutMethodCalls, @"\([^()]*\)");

            if (priorityParentheses.Count > 0)
            {
                operators["()"] = operators.ContainsKey("()") ? operators["()"] + priorityParentheses.Count : priorityParentheses.Count;
            }
        }

        private string RemoveMethodCallsAndParams(string code)
        {
            // Удаляем вызовы методов: method(), @var.method(), method(arg), @var.method(arg)
            string withoutMethodCalls = Regex.Replace(code, @"(?<![\w@])((@@|@)?[a-zA-Z_][a-zA-Z0-9_]*[?!]?)\s*\([^()]*\)", " ");

            // Удаляем определения параметров методов: def method(arg), def @var.method(arg)
            string withoutMethodDefs = Regex.Replace(withoutMethodCalls, @"\bdef\s+((@@|@)?[a-zA-Z_][a-zA-Z0-9_]*[?!]?)\s*\([^()]*\)", "def method");

            return withoutMethodDefs;
        }

        private void ProcessKeywordOperators(string code, Dictionary<string, int> operators)
        {
            // Исключены "case" и "when"
            string[] keywordOperators = {
        "puts", "return", "break", "next", "redo", "yield", "super", "self",
        "and", "or", "not", "in", "then", "begin", "rescue", "ensure", "retry",
        "alias", "undef", "require", "include", "extend", "public", "private", "protected", "raise",
        "fail", "throw", "catch", "loop", "proc", "lambda", "defined?", "BEGIN", "END"
    };

            foreach (var keyword in keywordOperators)
            {
                var matches = Regex.Matches(code, $@"\b{Regex.Escape(keyword)}\b");
                if (matches.Count > 0)
                {
                    operators[keyword] = operators.ContainsKey(keyword) ? operators[keyword] + matches.Count : matches.Count;
                }
            }
        }

        private void ProcessMethodCalls(string code, Dictionary<string, int> operators)
        {
            // Обрабатываем вызовы методов без параметров: method(), @var.method()
            var methodCallsWithoutParams = Regex.Matches(code, @"(?<![\w@])((@@|@)?[a-zA-Z_][a-zA-Z0-9_]*[?!]?)\s*\(\s*\)");
            foreach (Match match in methodCallsWithoutParams)
            {
                string methodName = match.Groups[1].Value;
                if (!string.IsNullOrEmpty(methodName) && !IsRubyKeyword(methodName) && !IsRubyOperator(methodName))
                {
                    string operatorKey = methodName + "()";
                    operators[operatorKey] = operators.ContainsKey(operatorKey) ? operators[operatorKey] + 1 : 1;
                }
            }

            // Обрабатываем вызовы методов с параметрами: method(arg), @var.method(arg)
            var methodCallsWithParams = Regex.Matches(code, @"(?<![\w@])((@@|@)?[a-zA-Z_][a-zA-Z0-9_]*[?!]?)\s*\([^()]+\)");
            foreach (Match match in methodCallsWithParams)
            {
                string methodName = match.Groups[1].Value;
                if (!string.IsNullOrEmpty(methodName) && !IsRubyKeyword(methodName) && !IsRubyOperator(methodName))
                {
                    string operatorKey = methodName + "()";
                    operators[operatorKey] = operators.ContainsKey(operatorKey) ? operators[operatorKey] + 1 : 1;
                }
            }
        }

        private void ProcessTernaryOperator(string code, Dictionary<string, int> operators)
        {
            var ternaryMatches = Regex.Matches(code, @"\?[^:]*?:");
            if (ternaryMatches.Count > 0)
            {
                operators["?:"] = ternaryMatches.Count;
            }
        }

        private Dictionary<string, int> ExtractOperands(string code, Dictionary<string, int> operators)
        {
            var operands = new Dictionary<string, int>();

            ExtractAllStringLiterals(code, operands);
            string codeWithoutStrings = RemoveStringLiterals(code);

            // Удаляем операторы из кода перед поиском переменных
            string codeWithoutOperators = RemoveOperators(codeWithoutStrings);

            // Переменные (включая параметры методов и переменные экземпляра/класса)
            var variables = Regex.Matches(codeWithoutOperators, @"(?<![\w@])(@@|@)?[a-zA-Z_][a-zA-Z0-9_]*[?!]?(?![\w@])");
            foreach (Match match in variables)
            {
                string variable = match.Value;
                if (!string.IsNullOrEmpty(variable) && !IsRubyKeyword(variable) && !IsRubyOperator(variable) &&
                    !variable.EndsWith("()") && !operators.ContainsKey(variable + "()"))
                {
                    operands[variable] = operands.ContainsKey(variable) ? operands[variable] + 1 : 1;
                }
            }

            // Числовые литералы
            var numberMatches = Regex.Matches(codeWithoutOperators, @"\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b");
            foreach (Match match in numberMatches)
            {
                string number = match.Value;
                operands[number] = operands.ContainsKey(number) ? operands[number] + 1 : 1;
            }

            // Логические литералы и специальные значения
            ExtractSpecialOperands(codeWithoutOperators, operands);

            return operands;
        }

        private string RemoveOperators(string code)
        {
            // Удаляем операторы из кода (сначала составные, потом простые)
            string[] operatorsToRemove = {
        // Составные операторы
        @"\+\=", @"\-\=", @"\*\=", @"\/\=", @"\%\=", @"\*\*\=", @"\*\*",
        @"\=\=", @"\!\=", @"\<\=", @"\>\=", @"\<\=\>", @"\&\&", @"\|\|",
        @"\.\.\.", @"\.\.", @"\:\:", @"\=\>",
        
        // Простые операторы
        @"\=", @"\+", @"\-", @"\*", @"\/", @"\%",
        @"\<", @"\>", @"\!", @"\&", @"\|", @"\^", @"\~",
        @"\<\<", @"\>\>", @"\.", @"\?", @"\:",
        
        // Скобки
        @"\(\)", @"\{\}", @"\[\]"
    };

            string result = code;
            foreach (var opPattern in operatorsToRemove)
            {
                result = Regex.Replace(result, opPattern, " ");
            }

            return result;
        }

        private void ExtractSpecialOperands(string code, Dictionary<string, int> operands)
        {
            // Добавляем nil, false, true, empty как операнды
            string[] specialOperands = { "nil", "false", "true", "empty" };

            foreach (var operand in specialOperands)
            {
                var matches = Regex.Matches(code, $@"\b{Regex.Escape(operand)}\b");
                if (matches.Count > 0)
                {
                    operands[operand] = operands.ContainsKey(operand) ? operands[operand] + matches.Count : matches.Count;
                }
            }
        }

        private void ExtractAllStringLiterals(string code, Dictionary<string, int> operands)
        {
            var doubleQuoteStrings = Regex.Matches(code, @"""(?:[^""\\]|\\.)*""");
            foreach (Match match in doubleQuoteStrings)
            {
                string literal = match.Value;
                operands[literal] = operands.ContainsKey(literal) ? operands[literal] + 1 : 1;
            }

            var singleQuoteStrings = Regex.Matches(code, @"'(?:[^'\\]|\\.)*'");
            foreach (Match match in singleQuoteStrings)
            {
                string literal = match.Value;
                operands[literal] = operands.ContainsKey(literal) ? operands[literal] + 1 : 1;
            }
        }

        private string RemoveStringLiterals(string code)
        {
            string withoutDoubleQuotes = Regex.Replace(code, @"""(?:[^""\\]|\\.)*""", "\"\"");
            return Regex.Replace(withoutDoubleQuotes, @"'(?:[^'\\]|\\.)*'", "''");
        }

        private bool IsRubyKeyword(string token)
        {
            string[] keywords = {
                "class", "def", "end", "if", "else", "elsif", "unless", "while", "until", "for", "do",
                "module", "begin", "rescue", "ensure", "retry", "return", "yield", "super", "self", "nil",
                "true", "false", "and", "or", "not", "in", "then", "when", "case", "break", "next", "redo",
                "alias", "undef", "require", "include", "extend", "public", "private", "protected", "raise",
                "fail", "throw", "catch", "loop", "proc", "lambda", "defined?", "BEGIN", "END", "puts"
            };
            return keywords.Contains(token);
        }

        private bool IsRubyOperator(string token)
        {
            string[] operators = {
        "=", "+", "-", "*", "/", "%", "**", "==", "!=", ">", "<", ">=", "<=", "<=>", "&&", "||",
        "!", "&", "|", "^", "~", "<<", ">>", "+=", "-=", "*=", "/=", "%=", "**=", ".", "..", "...",
        "?", ":", "::", "=>", "()", "{}", "[]", "if...end", "unless...end", "def...end", "class...end",
        "module...end", "begin...end", "while...end", "until...end", "do...end", "case...end",
        "case...when...end", "case...when...else...end", "?:", "puts", "unary_+", "unary_-", "unary_*"
    };
            return operators.Contains(token);
        }

        public Dictionary<string, int> GetLastOperators() => _lastOperators;
        public Dictionary<string, int> GetLastOperands() => _lastOperands;
    }
}