namespace Lab5;

public class Function
{
    private int _freeMember;
    private int _coefX;
    private int _coefY;
    private int _coefXY;

    public Function(int freeMember, int coefX, int coefY, int coefXY)
    {
        _freeMember = freeMember;
        _coefX = coefX;
        _coefY = coefY;
        _coefXY = coefXY;
    }
    
    public int GetValue(Point point) => 
        _freeMember + _coefX * point.X + _coefY * point.Y + _coefXY * point.X * point.Y;

    public double GetY(double x) =>
        -(_freeMember + _coefX * x) / (_coefY + _coefXY * x);

    public static Function operator +(Function first, Function second) =>
        new Function(
            first._freeMember + second._freeMember,
            first._coefX + second._coefX,
            first._coefY + second._coefY,
            first._coefXY + second._coefXY
        );

    public static Function operator *(int value, Function function) =>
        new Function(
            function._freeMember * value,
            function._coefX * value,
            function._coefY * value,
            function._coefXY * value
        );

    public override string ToString()
    {
        return $"y = -({_freeMember} {(_coefX >= 0 ? '+' : '-')} {Math.Abs(_coefX)}x) / ({_coefY} {(_coefXY >= 0 ? '+' : '-')} {Math.Abs(_coefXY)}x)";
    }
}