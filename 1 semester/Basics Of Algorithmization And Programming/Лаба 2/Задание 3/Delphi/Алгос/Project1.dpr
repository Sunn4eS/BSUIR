Program Lab2_3_alg;
uses
  System.SysUtils;
Const
    LowestColumn = 5;
    HighestColumn = 1;
Var
    Matrix: Array [1..4,1..5] of Integer;
    GoodMen: Array [1..4] of Integer;
    Column, Line, Count: integer;

    Mark: Integer;
    GoodMarks: Boolean;
Begin
    GoodMarks := True;

    For Line := Low(Matrix) to High(Matrix) do
    Begin
        For Column := HighestColumn to LowestColumn do
        Begin
        write('write mark of ', Line, ' man ', Column, ' day: ');                     // J column
        Readln(Matrix[Line][Column]);                                              // I line
        End;

    End;

    For Line := Low(Matrix) to High(Matrix) do
    Begin
        For Column := HighestColumn to LowestColumn do
        Begin
        If Matrix[Line][Column] < 9 Then
            GoodMarks := False;
        End;

        if GoodMarks then
            GoodMen[Line] := Line;

        GoodMarks := True;

    End;

    For Line := Low(GoodMen) to High(GoodMen) do
    Begin
        If GoodMen[Line] > 0  then
        Writeln(GoodMen[Line]);
    End;

    Readln;


End.
