program X;

Uses
    System.SysUtils;

Type
    TRoots = Array Of Real;

Function SolveSquare(A, B, C: Real): TRoots;
Var
    X: TRoots;
    D: Real;
Begin
    If A = 0 Then
        Writeln('Не квадратное уравнение')
    Else
    Begin
        If (B = 0) And (C = 0) Then
        Begin
            Setlength(X, 1);
            X[0] := 0;
        End
        Else
        Begin
            If C = 0 Then
            Begin
                SetLength(X, 2);
                X[0] := 0;
                X[1] := ((-1) * B) / A;
            End
            Else
            Begin
                If B = 0 Then
                Begin
                    Setlength(X, 2);
                    X[0] := (-1) * (Sqrt(C) / A);
                    X[1] := (Sqrt(C) / A);
                End
                Else
                Begin
                    D := (B * B) - (4 * A * C);
                    If D < 0 Then
                        Writeln('Корней нет')
                    Else
                    Begin
                        If D = 0 Then
                        Begin
                            SetLength(X, 1);
                            X[0] := ((-1) * B) / (2 * A);
                        End
                        Else
                        Begin
                            SetLength(X, 2);
                            X[0] := (((-1) * B) + Sqrt(D)) / (2 * A);
                            X[1] := (((-1) * B) - Sqrt(D)) / (2 * A);
                        End;
                    End;
                End;
            End;
        End;
    End;
    SolveSquare := X;
End;

Var
    A, B, C: Real;
    Roots: TRoots;

Begin
    Readln(A, B, C);
    Roots := solveSquare(A, B, C);
    Writeln(#13#10);
    for var i  := 0 to High(Roots) do
        Writeln(Roots[i]);
    Readln;
End.
