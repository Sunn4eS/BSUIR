Program Task2_2;

Uses
  System.SysUtils;

Procedure OutputTask();
Begin
    Writeln('������ ��������� �������� ����� �� ����������� N � ���� ������������ ���� ���������������� ����������� �����:' + #13#10);
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

        Write('������� ����� N: ');
        IsCorrect := True;

        Try
            Readln(N);
        Except
            Writeln('��������� ������������ ����� ������!');
            IsCorrect := False;

        End;

        CheckRangeN := CheckRange(N);

        If CheckRangeN And IsCorrect Then
        Begin
            Writeln('�������� �� �������� � ��������');
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
        Writeln('����� �����������')
    Else
        Writeln('������ �����������');

    Readln;
End.

