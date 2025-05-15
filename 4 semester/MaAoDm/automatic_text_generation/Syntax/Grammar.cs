using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Syntax
{
    public class Grammar
    {
        public Grammar(ElementType startElementType, List<Rule> rules,
            Dictionary<string, ElementType> elementTypes)
        {
            Rules = rules;
            StartElementType = startElementType;
            ElementTypes = elementTypes;
        }

        protected Grammar()
        {
        }

        private Dictionary<string, ElementType> ElementTypes { get; set; }
        private List<Rule> Rules { get; set; }
        private ElementType StartElementType { get; set; }

        public Element GetImage()
        {
            return GetElement(StartElementType);
        }

        private Element GetElement(ElementType elementType)
        {
            if (elementType is TerminalElementType terminalElementType)
            {
                return terminalElementType.StandardElement;
            }

            var rule = Rules.FirstOrDefault(x => x.StartElementType.Name == elementType.Name);
            Debug.Assert(rule != null, "rule != null");
            return rule.TransformConnect(GetElement(rule.FirstArgumentType),
                GetElement(rule.SecondArgumentType));
        }

        public RecognizingResult IsImage(IEnumerable<Element> baseElements)
        {
            var elements = new ConcurrentBag<Element>(baseElements);

            foreach (var rule in Rules)
            {
                var result = ContainRuleArguments(elements, rule);
                elements = result.Elements;
                if (!result.IsElementFound)
                    return new RecognizingResult(rule.StartElementType.Name, false);
            }

            return new RecognizingResult("", true);
        }

        private static ContainRuleArgumentsResult ContainRuleArguments(
            ConcurrentBag<Element> elements, Rule rule)
        {
            var result = new ContainRuleArgumentsResult
            {
                Elements = new ConcurrentBag<Element>(elements),
                IsElementFound = false
            };

            foreach (var firstElement in elements)
            {
                if (firstElement.ElementType.Name == rule.FirstArgumentType.Name)
                {
                    result = ContainRuleArgumentsForFirstElement(elements, rule, firstElement,
                        result);
                }
            }

            return result;
        }

        private static ContainRuleArgumentsResult ContainRuleArgumentsForFirstElement(
            IEnumerable<Element> elements, Rule rule,
            Element firstElement, ContainRuleArgumentsResult result)
        {
            var element = firstElement;
            Parallel.ForEach(elements, (Element secondElement) =>
            {
                if (!rule.IsRulePare(element, secondElement)) return;
                result.Elements.Add(rule.Connect(element, secondElement));
                result.IsElementFound = true;
            });
            return result;
        }

        public override string ToString()
        {
            var result = new StringBuilder();
            foreach (var rule in Rules)
            {
                result.AppendFormat("{0} -> {1}({2}, {3}); {4}", rule.StartElementType.Name,
                    rule.Name, rule.FirstArgumentType.Name, rule.SecondArgumentType.Name, Environment.NewLine);
            }

            return result.ToString();
        }

        private class ContainRuleArgumentsResult
        {
            public ConcurrentBag<Element> Elements { get; set; }
            public bool IsElementFound { get; set; }
        }
    }
}