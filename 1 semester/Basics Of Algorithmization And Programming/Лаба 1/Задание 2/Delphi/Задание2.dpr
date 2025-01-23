Program Task2;

Uses
    System.SysUtils;

Const
    MINDAY = 0;
    MAXDAY = 1000;
    PERCENTAGE = 0.1;
    SECONDDAY = 2;

Var
    NumOfDays: Integer;
    IsIncorrect: Boolean;
    DistancePerDay: Real;
    TotalDistance: Real;
    I: Integer;

Begin
    NumOfDays := 0;
    Writeln('Данная программа показывает какой суммарный пробег пробежит спортсмен за N дней:'
      + #13#10);
    Repeat
        IsIncorrect := True;
        Writeln('Введите количество дней: ');

        Try
            Readln(NumOfDays);
        Except
            Writeln('Проверьте корректность ввода данных!');
            IsIncorrect := False;
        End;

        If (IsIncorrect) And ((NumOfDays < MINDAY) Or (NumOfDays > MAXDAY)) Then
        Begin
            Writeln('Значение не попадает в диапазон!');
            IsIncorrect := False;
        End;

    Until (IsIncorrect);

    DistancePerDay := 10;
    TotalDistance := 10;
    For I := SECONDDAY To NumOfDays Do
    Begin
        DistancePerDay := DistancePerDay * PERCENTAGE + DistancePerDay;
        TotalDistance := TotalDistance + DistancePerDay;
    End;
    Writeln('Общее расстояние: ', TotalDistance);
    Readln;

End.
