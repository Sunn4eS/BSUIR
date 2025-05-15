using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;

namespace Syntax
{
    public class HomeGrammarOther
    {
        private static readonly Dictionary<string, ElementType> ElementTypes = GetElementTypes();
        private readonly List<Rule> rules;
        private readonly ElementType startElementType;

        public HomeGrammarOther()
        {
            startElementType = new ElementType("Злой человек");

            rules = new List<Rule>
            {
                new LeftRule(ElementTypes["Верхняя часть квадрата"], ElementTypes["a3"], ElementTypes["a4"]),
                new LeftRule(ElementTypes["Волосы слева"], ElementTypes["a3"], ElementTypes["a3"]),
                new LeftRule(ElementTypes["Волосы справа"], ElementTypes["a3"], ElementTypes["a3"]),
                new LeftRule(ElementTypes["Волосы"], ElementTypes["Волосы слева"], ElementTypes["Волосы справа"]),
                new LeftRule(ElementTypes["Нижняя часть квадрата"], ElementTypes["a4"], ElementTypes["a3"]),
                new UpRule(ElementTypes["Квадрат"], ElementTypes["Верхняя часть квадрата"], ElementTypes["Нижняя часть квадрата"]),
                new UpRule(ElementTypes["Глаз"], ElementTypes["a1"], ElementTypes["Нижняя часть квадрата"]),
                new LeftRule(ElementTypes["Глаза"], ElementTypes["Глаз"], ElementTypes["Глаз"]),
                new UpRule(ElementTypes["Глаза и рот"], ElementTypes["Глаза"], ElementTypes["a1"]),
                new InsideRule(ElementTypes["Лицо"], ElementTypes["Глаза и рот"],ElementTypes["Квадрат"] ),
                new UpRule(startElementType, ElementTypes["Волосы"], ElementTypes["Лицо"]),
            };
        }

        private static Dictionary<string, ElementType> GetElementTypes()
        {
            return new Dictionary<string, ElementType>
            {
                {"a1", new TerminalElementType("a1", new Line(new Point(0, 0), new Point(10, 0)))},
                {"a2", new TerminalElementType("a2", new Line(new Point(0, 0), new Point(0, 10)))},
                {"a3", new TerminalElementType("a3", new Line(new Point(0, 0), new Point(10, 10)))},
                {"a4", new TerminalElementType("a4", new Line(new Point(10, 0), new Point(0, 10)))},
                {"Волосы слева", new ElementType("Волосы слева")},
                {"Волосы справа", new ElementType("Волосы справа")},
                {"Верхняя часть квадрата", new ElementType("Верхняя часть квадрата")},
                {"Волосы", new ElementType("Волосы")},
                {"Нижняя часть квадрата", new ElementType("Нижняя часть квадрата")},
                {"Квадрат", new ElementType("Квадрат")},
                {"Глаза", new ElementType("Глаза")},
                {"Глаз", new ElementType("Глаз")},
                {"Глаза и рот", new ElementType("Глаза и рот")},
                {"Лицо", new ElementType("Лицо")},
            };
        }

        public Element GetHome()
        {
            return GetElement(startElementType);
        }

        private Element GetElement(ElementType elementType)
        {
            var terminalElementType = elementType as TerminalElementType;
            if (terminalElementType != null)
            {
                return terminalElementType.StandartElement;
            }

            Rule rule = rules.FirstOrDefault(x => x.StartElementType.Name == elementType.Name);
            Debug.Assert(rule != null, "rule != null");
            return rule.TransformConnect(GetElement(rule.FirstArgumentType),
                GetElement(rule.SecondArgumentType));
        }

        public RecognazingResult IsHome(IEnumerable<Element> baseElements)
        {
            var elements = new ConcurrentBag<Element>(baseElements);
            for (int i = 0; i < rules.Count; i++)
            {
                ContainRuleAgrumentsResult result = ContainRuleAgruments(elements, rules[i]);
                elements = result.Elements;
                if (!result.IsElementFound)
                    return new RecognazingResult(rules[i].StartElementType.Name, false);
            }
            return new RecognazingResult("", true);
        }

        private static ContainRuleAgrumentsResult ContainRuleAgruments(
            ConcurrentBag<Element> elements, Rule rule)
        {
            var result = new ContainRuleAgrumentsResult
            {
                Elements = new ConcurrentBag<Element>(elements),
                IsElementFound = false
            };

            foreach (Element firstElement in elements)
            {
                if (firstElement.ElementType.Name == rule.FirstArgumentType.Name)
                {
                    result = ContainRuleAgrumentsForFirstElement(elements, rule, firstElement,
                        result);
                }
            }
            return result;
        }

        private static ContainRuleAgrumentsResult ContainRuleAgrumentsForFirstElement(
            IEnumerable<Element> elements, Rule rule,
            Element firstElement, ContainRuleAgrumentsResult result)
        {
            Element element = firstElement;
            Parallel.ForEach(elements, (Element secondElement) =>
            {
                if (rule.IsRulePare(element, secondElement))
                {
                    result.Elements.Add(rule.Connect(element, secondElement));
                    result.IsElementFound = true;
                }
            });
            return result;
        }

        public static Element GetTerminalElement(Line line)
        {
            String resultName = GetTerminalElementName(line);
            return new Element(ElementTypes[resultName], line);
        }

        private static string GetTerminalElementName(Line line)
        {
            double deltaX = line.From.X - line.To.X;
            double deltaY = line.From.Y - line.To.Y;
            if (Math.Abs(deltaY) < 1) return "a1";
            if (Math.Abs(deltaX) < 1) return "a2";
            if (Math.Abs(deltaX) < 1) return "a2";
            if (Math.Abs(deltaX / deltaY) < 0.2) return "a2";
            if (Math.Abs(deltaY / deltaX) < 0.2) return "a1";
            Point highPoint = line.To.Y > line.From.Y ? line.To : line.From;
            Point lowPoint = line.To.Y < line.From.Y ? line.To : line.From;
            if (highPoint.X < lowPoint.X) return "a4";
            return "a3";
        }

        private class ContainRuleAgrumentsResult
        {
            public ConcurrentBag<Element> Elements { get; set; }
            public bool IsElementFound { get; set; }
        }
    }
}