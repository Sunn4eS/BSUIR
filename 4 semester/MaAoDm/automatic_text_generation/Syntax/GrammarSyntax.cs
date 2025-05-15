using System;
using System.Collections.Generic;
using System.Linq;

namespace Syntax
{
    public class GrammarSyntax
    {
        private int _elementNumber;
        private readonly Dictionary<string, ElementType> _elementTypes;
        private readonly List<Rule> _emptyRules;
        private readonly List<Rule> _rules;
        private readonly ElementType _startElementType;

        public GrammarSyntax(IEnumerable<Element> baseElements)
        {
            var elements = new List<Element>(baseElements);
            _emptyRules = new List<Rule>
            {
                new LeftRule(null, null, null),
                new UpRule(null, null, null)
            };
            _rules = new List<Rule>();
            _elementNumber = 1;
            _elementTypes = TerminalElementCreator.GetTerminalElementTypes();
            _startElementType = ConnectElementToSyntax(elements);
        }

        public Grammar Grammar => new Grammar(_startElementType, _rules, _elementTypes);

        private ElementType ConnectElementToSyntax(List<Element> elements)
        {
            if (elements.Count == 1) return elements[0].ElementType;
            RuleSearchResult searchRuleResult = null;
            foreach (var candidate in elements)
            {
                searchRuleResult = SearchRule(elements, candidate);
                if (searchRuleResult != null) break;
            }
            if (searchRuleResult == null) throw new InvalidElementException();
            var result = new ElementType($"O{_elementNumber++}");
            _elementTypes.Add(result.Name, result);
            _rules.Add(searchRuleResult.GetRule(result));
            return result;
        }

        private RuleSearchResult SearchRule(List<Element> elements, Element candidate)
        {
            foreach (var rule in _emptyRules)
            {
                if (IsFirstInRule(rule, candidate, elements))
                {
                    elements.Remove(candidate);
                    return new RuleSearchResult
                    {
                        FirstElementType = candidate.ElementType,
                        SecondElementType = ConnectElementToSyntax(elements),
                        EmptyRule = rule,
                        Elements = elements
                    };
                }

                if (!IsSecondInRule(rule, candidate, elements)) continue;
                elements.Remove(candidate);
                return new RuleSearchResult
                {
                    FirstElementType = ConnectElementToSyntax(elements),
                    SecondElementType = candidate.ElementType,
                    EmptyRule = rule,
                    Elements = elements
                };
            }
            return null;
        }

        private static bool IsFirstInRule(Rule rule, Element candidate, List<Element> otherElements)
        {
            return otherElements.All(element => !IsDifferentElementFirstInRule(rule, candidate, element));
        }

        private static bool IsSecondInRule(Rule rule, Element candidate, List<Element> otherElements)
        {
            return otherElements.All(element => !IsDifferentElementSecondInRule(rule, candidate, element));
        }

        private static bool IsDifferentElementFirstInRule(Rule rule, Element candidate,
            Element element)
        {
            return candidate.StartPosition != element.StartPosition &&
                   candidate.EndPosition != element.EndPosition &&
                   !rule.IsRulePositionPare(candidate, element);
        }

        private static bool IsDifferentElementSecondInRule(Rule rule, Element candidate,
            Element element)
        {
            return candidate.StartPosition != element.StartPosition &&
                   candidate.EndPosition != element.EndPosition &&
                   !rule.IsRulePositionPare(element, candidate);
        }
    }
}