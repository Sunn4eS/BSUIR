program Alg;
uses
  System.SysUtils;

Type
    TMatrix = Array of Array of Integer;
    TArr = Array of Integer;

Var
    n, Line, Column, MaxColumn, MinLine, Num: Integer;
    Matrix: TMatrix;
    MinInLine: TArr;
    MaxInColumn: TArr;

Begin
    Readln(n);
    SetLength(Matrix, n, n);
    SetLength(MinInLine, N);
    SetLength(MaxInColumn, N);
    for Line := Low(Matrix) to High(Matrix) do
    begin
        for Column := Low(Matrix) to High(Matrix) do
        Begin
            Readln(Matrix[Line][Column]);
            Write(' ');
        End;
        Writeln;
    end;

    MinInLine[0] := Matrix[0][0];
    MaxInColumn[0] := Matrix[0][0];

    for Line := Low(Matrix) to High(Matrix) do
    Begin
        MinInLine[Line] := matrix[Line][0];

        For column := Low(Matrix) To High(Matrix) Do
        Begin

            if Matrix[Line][Column] < MinInLine[line] then
                MinInLine[line] := matrix[Line][Column];
        End;
    End;


    for Column := Low(Matrix) to High(Matrix) do
    Begin
        MaxInColumn[Column] := Matrix[0][Column];
        For Line := Low(Matrix) To High(Matrix) Do
        Begin

            if Matrix[Line][Column] > MaxInColumn[Column] then
                MaxInColumn[Column] := Matrix[line][Column];

        End;
    End;

    for Line := Low(Matrix) to High(Matrix) do
    Begin
        for Column := Low(Matrix) to High(Matrix) do
        if MinInLine[line] = MaxInColumn[Column] then
            Writeln('yes', line + 1, ' ', column + 1);
    End;

    Readln;
End.
