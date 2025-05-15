using System;
using System.Collections.Generic;
using System.Data;

namespace Syntax
{
    internal class RuleSearchResult
    {
        internal ElementType FirstElementType { get; set; }
        internal ElementType SecondElementType { get; set; }
        internal Rule EmptyRule { get; set; }
        internal List<Element> Elements { get; set; }

        internal Rule GetRule(ElementType result)
        {
            return (Rule) Activator.CreateInstance(EmptyRule.GetType(),
                result, FirstElementType, SecondElementType);
        }
    }
}