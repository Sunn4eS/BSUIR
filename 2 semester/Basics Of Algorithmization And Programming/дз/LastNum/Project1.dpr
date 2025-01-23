Program HW_LastNum;
Uses
    System.SysUtils;

Function FindLastNum(Num, Deg: Integer): Integer;
Var
    LastNum: Integer;
Begin
    LastNum := 1;
    Dec(Deg);
    Case Num Mod 10 Of
        1: LastNum := 1;
        2: Case Deg  Mod 4 Of
                0: LastNum := 2;
                1: LastNum := 4;
                2: LastNum := 8;
                3: LastNum := 6;
           End;
        3: Case Deg Mod 4 Of
                0: LastNum := 3;
                1: LastNum := 9;
                2: LastNum := 7;
                3: LastNum := 1;
           End;
        4: Case Deg Mod 2 Of
                0: LastNum := 4;
                1: LastNum := 6;
           End;
        5: LastNum := 5;
        6: LastNum := 6;
        7: Case Deg Mod 4 Of
                0: LastNum := 7;
                1: LastNum := 9;
                2: LastNum := 3;
                3: LastNum := 1;
           End;
        8: Case Deg Mod 4 Of
                0: LastNum := 8;
                1: LastNum := 4;
                2: LastNum := 2;
                3: LastNum := 6;
           End;
        9: Case Deg Mod 2 Of
                0: LastNum := 9;
                1: LastNum := 1;
           End;
        0: LastNum := 0;
    End;
    FindLastNum := LastNum;
End;

Begin
End.
