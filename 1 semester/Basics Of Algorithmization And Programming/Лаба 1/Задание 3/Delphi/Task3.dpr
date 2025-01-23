Program Task3;

Uses
  System.SysUtils;

Const
    MIN_X = -1;
    MAX_X = 1;
    MIN_EPS = 0;
    MAX_EPS = 1;

Var
    IsCorrect: Boolean;
    X, Sum, Multiple, EPS: Real;
    N, I: Integer;

Begin

    X := 0;
    EPS := 0;

    Writeln('������ ��������� ������� �������� ������� LN(1+X) ��� ��������� �������� X, � ����� ������������ ���������� ����� �� ���� ��������� ������� EPS:' + #13#10);

     Repeat

        IsCorrect := True;
        Write('������� ����� EPS (0; 1): ');

        Try
            Readln(EPS);
        Except
            Writeln('��������� ������������ ����� ������!');
            IsCorrect := False;
        End;

        If (IsCorrect) And ((EPS <= MIN_EPS) Or (EPS >= MAX_EPS)) Then
        Begin
            Writeln('�������� �� �������� � ��������!');
            IsCorrect := False;
        End;

    Until(IsCorrect);

    Repeat

        IsCorrect := True;
        Write('������� ����� X [-1; 1]: ');

        Try
            Readln(X);
        Except
            Writeln('��������� ������������ ����� ������!');
            IsCorrect := False;
        End;

        If (IsCorrect) And ((X < MIN_X) Or (X > MAX_X)) Then
        Begin
            Writeln('�������� �� �������� � ��������!');
            IsCorrect := False;
        End;

    Until(IsCorrect);

    N := 0;
    I := 1;
    Multiple := X;
    Sum := X;

    While ((abs(Multiple) / I) > EPS) Do
    Begin
        I := I + 1;
        Multiple := -Multiple * X;
        Sum := Sum + Multiple / I;
        N := N + 1;
    End;

    Writeln('����� ����� = ', Sum, #13#10 + '���������� ������ ���� = ', N);
    Readln;
End.
