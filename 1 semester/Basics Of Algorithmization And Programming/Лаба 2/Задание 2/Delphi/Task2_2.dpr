Program Task2_2;

Uses
  System.SysUtils;

Procedure OutputTask();
Begin
    Writeln('Данная программа выясняет можно ли представить N в виде произведения трех последовательных натуральных чисел:' + #13#10);
End;

Function CheckRange(N: Integer): Boolean;
Const
    MIN = 1;
    MAX = 100000;

Begin
    CheckRange := (N < MIN) Or (N > MAX);
End;

Function InputNum() : Integer;
Var
    N: Integer;
    IsCorrect: Boolean;
    CheckRangeN: Boolean;

Begin
    Repeat

        Write('Введите число N: ');
        IsCorrect := True;

        Try
            Readln(N);
        Except
            Writeln('Проверьте корректность ввода данных!');
            IsCorrect := False;

        End;

        CheckRangeN := CheckRange(N);

        If CheckRangeN And IsCorrect Then
        Begin
            Writeln('Значение не попадает в диапазон');
            IsCorrect := False;
        End;

    Until(IsCorrect);
    InputNum := N;
End;

Function CheckMultiplication(N: Integer) : Boolean;
Var
    Mult: Double;
    I: Integer;

Begin
    Mult := 1;
    I := 1;
    While (Mult < N) Do
    Begin
        Mult := Mult * (I + 2) / I;
        Inc(I);
    End;
    CheckMultiplication := (N = Mult);
End;

Var
    CheckMult: Boolean;

Begin
    OutputTask();

    CheckMult := CheckMultiplication(InputNum());
    If CheckMult Then
        Writeln('Можно представить')
    Else
        Writeln('Нельзя представить');

    Readln;
End.

