Program BrickMatch;
Uses
  System.SysUtils;

Type
    TBrick = Array [0..2] Of Integer;
    THole = Array [0..1] Of Integer;
Const
    Hig = 0;
    Wid = 1;
    Len = 2;

Procedure ReadBrickDimensions(Var Brick: TBrick);
Var
    I: Integer;
Begin
    For I := 0 To High(Brick) Do
    Begin
        Write('Введите ', I + 1, ' измерение кирпича: ');
        Readln(Brick[I]);
    End;
    Writeln;
End;

Procedure ReadHoleDimensions(Var Hole: THole);
Var
    I: Integer;
Begin
    For I := 0 To High(Hole) Do
    Begin
        Write('Введите ', I + 1, ' измерение отверстия: ');
        Readln(Hole[I]);
    End;
End;

Function IsBrickMatch(Brick: TBrick; Hole: THole): Boolean;
Var
    IsMatch: Boolean;
Begin
    IsMatch := False;
    If ((Brick[Hig] <= Hole[Hig]) And (Brick[Wid] <= Hole[Wid])) Or ((Brick[Len] <= Hole[Wid]) And (Brick[Hig] <= Hole[Hig])) Or ((Brick[Wid] <= Hole[Hig]) And (Brick[Len] <= Hole[Wid])) Or ((Brick[Wid] <= Hole[Hig]) And (Brick[Hig] <= Hole[Wid])) Or ((Brick[Hig] <= Hole[Wid]) And (Brick[Len] <= Hole[Hig])) Or ((Brick[Len] <= Hole[Hig]) And (Brick[Wid] <= Hole[Wid])) Then
        IsMatch := True;
    IsBrickMatch := IsMatch;
End;

Var
    Brick: TBrick;
    Hole: THole;
    IsMatch: Boolean;
Begin
    ReadBrickDimensions(Brick);
    ReadHoleDimensions(Hole);
    IsMatch := IsBrickMatch(Brick, Hole);
    if IsMatch then
        Writeln('Yes')
    Else
        Writeln('No');
        Readln;


End.
