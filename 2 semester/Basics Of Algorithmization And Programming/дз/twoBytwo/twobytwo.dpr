Program HW_2To2023;
Uses
  SysUtils;

Type
  TArr = Array of Integer;

Procedure MultiplyByTwo(Var Num: TArr);
Var
    Buf, I: Integer;
Begin
    Buf := 0;
    For I := 0 To Length(num) - 1 Do
    begin
        Num[I] := Num[I] * 2 + Buf;
        Buf := Num[i] Div 10;
        Num[I] := Num[I] Mod 10;
    End;
    If Buf > 0 Then
    Begin
        SetLength(Num, Length(Num) + 1);
        Num[Length(Num) - 1] := Buf;
    End;
End;

Function PowTwo(): TArr;
Var
    Num: TArr;
    I: Integer;
Begin
    SetLength(Num, 1);
    Num[0] := 1;
    For I := 1 To 2023 Do
        MultiplyByTwo(Num);
    PowTwo := Num;
End;

Procedure PrintResult(Const Num: TArr);
Var
    I: Integer;
Begin
    For I := Length(Num) - 1 Downto 0 do
    Write(Num[i]);
    Writeln;
End;
Var
    ResNum: TArr;
Begin
    ResNum := PowTwo();
    PrintResult(ResNum);
    Readln;
End.

