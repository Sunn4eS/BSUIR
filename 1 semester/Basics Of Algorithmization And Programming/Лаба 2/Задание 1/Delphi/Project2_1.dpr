Program Lab2_1;
{$APPTYPE CONSOLE}

Uses
    System.SysUtils;

Var
    N, Count, I, J, N_Decr: Integer;
    X, Y: Array of Integer;
    S_Triangle: Array of Real;
    S_Figure, Mid_X, Mid_Y, Min_X, Min_Y, Max_X, Max_Y, X_Test: Real;
    Min_X_1, Min_Y_1, Max_X_1, Max_Y_1: Real;
    Vec_Mult, Vec_Length, Vec_1_X, Vec_2_X, Vec_1_Y, Vec_2_Y: Real;
    IsCorrect, IsCorrectFigure, Point_N_Repeats: Boolean;

Begin
    Writeln('Эта программа проверяет, находится ли заданная точка на одной из сторон заданного координатами многоугольника.');
    N := 0;

    Repeat
        Writeln('Введите количество вершин многоугольника');
        IsCorrect := True;
        Try
            Readln(N);
        Except
            Writeln('Неверный тип данных');
            IsCorrect := False;
        End;
        if (N < 3) and (IsCorrect) then
        Begin
            IsCorrect := False;
            Writeln('Число вершин многоугольника должно быть больше 2');
        End;
    Until IsCorrect;

    SetLength(X, 2 * N);
    SetLength(Y, 2 * N);
    IsCorrect := False;
    Point_N_Repeats := True;
    Count := 0;
    N_Decr := N - 1;

    Repeat
        Writeln('Введите x и y координаты вершин');

        For I := Low(X) to N_Decr Do
        Begin
            Repeat
                IsCorrect := True;
                Try
                    Readln(X[I]);
                Except
                    Writeln('Неверный тип данных');
                    IsCorrect := False;
                End;
            Until IsCorrect;

            Repeat
                IsCorrect := True;
                Try
                    Readln(Y[I]);
                Except
                    Writeln('Неверный тип данных');
                    IsCorrect := False;
                End;
            Until IsCorrect;
        End;

        For I := 0 to N_Decr do
        Begin
            X[N + I] := X[I];
            Y[N + I] := Y[I];
        End;


        For I := 0 to N_Decr Do
        Begin
            For J := I + 1 to N_Decr Do
            Begin
                If ((X[I] = X[J]) and (Y[I] = Y[J])) or (Point_N_Repeats = False) Then
                Begin
                    Point_N_Repeats := False;
                    Writeln('Введённые координаты точек совпадают, т.е. совпадают несколько точек');
                End
                Else
                    Point_N_Repeats := True;
            End;
        End;

        {Проверка фигуры на пересечение сторон}

        IsCorrectFigure := True;
        For I := 0 to N Do
        Begin
            For J := I + 2 to N + Count Do
            Begin
                Try
                    If Count = 0 Then
                       Inc(Count);
                    X_Test := (X[I] * (Y[I + 1] - Y[I]) / (X[I + 1] - X[I]) +
                    Y[J] - Y[I] - X[J] * (Y[J + 1] - Y[J]) /  (X[J + 1] - X[J])) /
                      ((Y[I + 1] - Y[I]) / (X[I + 1] - X[I]) -
                      (Y[J + 1] - Y[J]) / (X[J + 1] - X[J]));
                    If X[I] < X[I + 1] Then
                        Min_X := X[I]
                    Else
                        Min_X := X[I + 1];
                    If X[I] > X[I + 1] Then
                        Max_X := X[I]
                    Else
                        Max_X := X[I + 1];
                    If (X_Test > Min_X) and (X_Test < Max_X) Then
                        IsCorrectFigure := False
                Except
                    If (X[I] - X[J + 1] - X[I + 1] + X[J] = 0) Then
                        IsCorrectFigure := False
                    Else If (Y[I] - Y[J + 1] - Y[I + 1] + Y[J] = 0) Then
                        IsCorrectFigure := False
                    Else
                        IsCorrectFigure := True;
                End;
            End;
        End;
        If IsCorrectFigure = False Then
            Writeln('Введённая фигура не многоугольник');
    Until IsCorrect and IsCorrectFigure and Point_N_Repeats;

    {Поиск макисмального и минимального элемента в массиве}

    Min_X_1 := X[0];
    Max_X_1 := X[0];
    Min_Y_1 := Y[0];
    Max_Y_1 := Y[0];
    For I := Low(x) To High(X) Do

        Begin
            If Min_X_1 > X[I] Then
                Min_X_1 := X[I];
            If Min_Y_1 > Y[I] Then
                Min_Y_1 := Y[I];
            If Max_X_1 < X[I] Then
                Max_X_1 := X[I];
            If Max_Y_1 < Y[I] Then
                Max_Y_1 := Y[I];
        End;

    {Определенние центра многоугольника}
    Mid_X := (Min_X_1 + Max_X_1) / 2;
    Mid_Y := (Min_Y_1 + Max_Y_1) / 2;

    setlength(S_Triangle, N);

    For I := Low(X) to N_decr do
        {x[i] y[i]  x[i+1] y[i+1] mid_x mid_y}
        Begin

        Vec_1_X := X[I] - Mid_X;
        Vec_1_Y := Y[I] - Mid_Y;
        Vec_2_X := X[I+1] - Mid_X;
        Vec_2_Y := Y[I+1] - Mid_Y;

        Vec_Mult := ((Vec_1_X * Vec_1_Y) - (Vec_2_X * Vec_2_Y));

        Vec_Length := Abs(Vec_Mult);

        S_Figure := S_Figure +(0.5 * (Vec_Length));


        End;

       Writeln(S_Figure);


    Readln;

    End.







