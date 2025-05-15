using System.Windows;

namespace Syntax
{
    internal class TerminalElementType : ElementType
    {
        private readonly Line _standardElementLine;

        public TerminalElementType(string name, Line standardElementLine)
            : base(name)
        {
            _standardElementLine = standardElementLine;
        }

        public Element StandardElement =>
            new(this,
                new Line(new Point(_standardElementLine.From.X, _standardElementLine.From.Y),
                    new Point(_standardElementLine.To.X, _standardElementLine.To.Y)));
    }
}