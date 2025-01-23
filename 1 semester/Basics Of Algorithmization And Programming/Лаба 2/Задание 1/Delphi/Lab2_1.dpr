Program Lab2_1;

Uses
  System.SysUtils;

Const
    MIN = -10000;
    MAX = 10000;
    MIN_N = 3;
    MAX_N = 10000;
    Length_Of_Arr = 2;

Var
    N, I, J: Integer;
    Coordinates: Array Of Array Of Integer;
    Vector: Array[1..2] Of Array[1..2] Of Real;
    IsCorrect, NotConvexPolygon, NotOnSameLine, IsCorrectFigure, SameCoordinate: Boolean;
    VectorMultiplication, PrevVectorMultiplication, X_Test, Max_X, Min_X, Max_Y, Min_Y, Mid_X, Mid_Y, SquareOfFigure: Real;

Begin
    SquareOfFigure := 0;
    N := 0;
    PrevVectorMultiplication := 0;
    NotConvexPolygon := True;
    NotOnSameLine := True;
    IsCorrectFigure := True;
    Writeln('Эта программа находит площадь N-угольника.');

    Repeat

        IsCorrect := True;
        Write('Введите количество вершин многоугольника [' , MIN_N, '; ', MAX_N, ']: ');
        Try
            Readln(N);
        Except
            Writeln('Проверьте корректность ввода данных!');
            IsCorrect := False;
        End;

        If (IsCorrect And ((N < MIN_N) Or (N > MAX_N))) Then
        Begin
            Writeln('Значение не попадает в диапазон!');
            IsCorrect := False;
        End;

    Until (IsCorrect);

    SetLength(Coordinates, N, Length_Of_Arr);

    For I := Low(Coordinates) To High(Coordinates) Do
    Begin

        Writeln('Введите ', I + 1,' пару координат (X, Y)');
        Repeat

            IsCorrect := True;
            Write('Введите X [', MIN, '; ', MAX, ']: ');

            Try
                Readln(Coordinates[I,0]);
            Except
                Writeln('Проверьте корректность ввода данных!');
                IsCorrect := False;
            End;

            If (IsCorrect And ((Coordinates[I,0] < MIN) Or (Coordinates[I,0] > MAX))) Then
            Begin
                Writeln('Значение не попадает в диапазон!');
                IsCorrect := False;
            End;

        Until (IsCorrect);

        Repeat

            IsCorrect := True;
            Write('Введите Y [', MIN, '; ', MAX, ']: ');

            Try
                Readln(Coordinates[I,1]);
            Except
                Writeln('Проверьте корректность ввода данных!');
                IsCorrect := False;
            End;

            If (IsCorrect And ((Coordinates[I,1] < MIN) Or (Coordinates[I,1] > MAX))) Then
            Begin
                Writeln('Значение не попадает в диапазон!');
                IsCorrect := False;
            End;

        Until (IsCorrect);

    End;

    SameCoordinate := False;
    For I := Low(Coordinates) To High(Coordinates) Do
    Begin
        For J := I + 1 To High(Coordinates) Do
        Begin
            If (Coordinates[I,0] = Coordinates[J,0]) And ((Coordinates[I,1] = Coordinates[J,1])) Then
            Begin
                Writeln('Ошибка! Введенные координаты равны!');
                SameCoordinate := True;
            End;
        End;
    End;

    For I := Low(Coordinates) To High(Coordinates) Do
    Begin
        For J := I + 2 To High(Coordinates) Do
        Begin
            Vector[1,1] := Coordinates[(I + 1) Mod N,0] - Coordinates[I Mod N,0];
            Vector[1,2] := Coordinates[(I + 1) Mod N,1] - Coordinates[I Mod N,1];
            Vector[2,1] := Coordinates[(J + 1) Mod N,0] - Coordinates[J Mod N,0];
            Vector[2,2] := Coordinates[(J + 1) Mod N,1] - Coordinates[J Mod N,1];
            VectorMultiplication := (Vector[1,1] * Vector[2,2] - Vector[2,1] * Vector[1,2]);

            If VectorMultiplication <> 0 Then
            Begin
                X_Test := ((Coordinates[I Mod N,0] * Vector[1,2] * Vector[2,1]) -
                            (Coordinates[J Mod N,0] * Vector[2,2] * Vector[1,1]) +
                            (Vector[1,1] * Vector[2,1] * (Coordinates[J Mod N,1]) -
                            Coordinates[I Mod N,1])) /
                           -VectorMultiplication;

                If Coordinates[(I + 1) mod N, 0] - Coordinates[I mod N, 0] = 0 Then
                Begin

                    If Coordinates[(I + 1) Mod N,0] > Coordinates[I Mod N,0] Then
                    Begin
                        Max_X := Coordinates[(I + 1) Mod N,0];
                        Min_X := Coordinates[I Mod N,0];
                    End
                    Else
                    Begin
                        Max_X := Coordinates[I Mod N,0];
                        Min_X := Coordinates[(I + 1) Mod N,0];
                    End;
                    If (X_Test > Min_X) And (X_Test < Max_X) Then
                        IsCorrectFigure := False;

                End
                Else
                Begin

                    If Coordinates[(J + 1) Mod N,0] > Coordinates[J Mod N,0] Then
                    Begin
                        Max_X := Coordinates[(J + 1) Mod N,0];
                        Min_X := Coordinates[J Mod N,0];
                    End
                    Else
                    Begin
                        Max_X := Coordinates[J Mod N,0];
                        Min_X := Coordinates[(J + 1) Mod N,0];
                    End;
                    If (X_Test > Min_X) And (X_Test < Max_X) Then
                        IsCorrectFigure := False;

                End;

            End;
        End;
    End;

    If (Not IsCorrectFigure) And (Not SameCoordinate) Then
        Writeln('Ошибка! Стороны многоугольника пересекаются!');

    If IsCorrectFigure Then
    Begin
        For I := Low(Coordinates) To High(Coordinates) Do
        Begin
            Vector[1,1] := Coordinates[(I + 1) Mod N,0] - Coordinates[I Mod N,0];
            Vector[1,2] := Coordinates[(I + 1) Mod N,1] - Coordinates[I Mod N,1];
            Vector[2,1] := Coordinates[(I + 2) Mod N,0] - Coordinates[(I + 1) Mod N,0];
            Vector[2,2] := Coordinates[(I + 2) Mod N,1] - Coordinates[(I + 1) Mod N,1];
            VectorMultiplication := (Vector[1,1] * Vector[2,2] - Vector[2,1] * Vector[1,2]);

            If (VectorMultiplication * PrevVectorMultiplication < 0) Then
                NotConvexPolygon := False;

            If VectorMultiplication = 0 Then
                NotOnSameLine := False;

            PrevVectorMultiplication := VectorMultiplication;
        End;
    End;

    If (IsCorrectFigure And (Not SameCoordinate)) Then
    Begin
        If Not NotOnSameLine Then
            Writeln('Ошибка! Стороны многоугольника лежат на одной прямой!')
        Else If Not NotConvexPolygon Then
            Writeln('Многоугольник не является выпуклым');

        Max_X := Coordinates[0,0];
        Min_X := Coordinates[0,0];
        Max_Y := Coordinates[0,1];
        Min_Y := Coordinates[0,1];

        For I := Low(Coordinates) To High(Coordinates) Do
        Begin
            If Coordinates[I, 0] < Min_X Then
                Min_X := Coordinates[I,0];
            If Coordinates[I, 0] > Max_X Then
                Max_X := Coordinates[I, 0];
            If Coordinates[I, 1] < Min_Y Then
                Min_Y := Coordinates[I, 1];
            If Coordinates[I, 1] > Max_Y Then
                Max_Y := Coordinates[I, 1];
        End;

        Mid_X := (Min_X + Max_X) / 2;
        Mid_Y := (Min_Y + Max_Y) / 2;

        For I := Low(Coordinates) To High(Coordinates) Do
        Begin
            Vector[1,1] := Coordinates[(I + 1) Mod N,0] - Mid_X;
            Vector[1,2] := Coordinates[(I + 1) Mod N,1] - Mid_Y;
            Vector[2,1] := Coordinates[(I + 2) Mod N,0] - Mid_X;
            Vector[2,2] := Coordinates[(I + 2) Mod N,1] - Mid_Y;
            VectorMultiplication := abs(Vector[1,1] * Vector[2,2] - Vector[2,1] * Vector[1,2]);

            SquareOfFigure := SquareOfFigure + (0.5 * (VectorMultiplication));
        End;

        If NotOnSameLine And NotConvexPolygon Then
            Writeln('Площадь многоугольника = ', SquareOfFigure);
    End;
    Coordinates := Nil;

    Readln;
End.
