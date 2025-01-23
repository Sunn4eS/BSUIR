Program Task4;

Uses
    System.SysUtils;
Const
    MAXNUMOFEL = 100;
    MINNUMOFEL = 0;
    MAXEL = 300;
    MINEL = -300;
Var
    NumOfEl: Integer;
    Prod: Integer;
    Arr: Array of Integer;
    I: Integer;
    IsIncorrect: Boolean;


Begin
    NumOfEl := 0;
    Writeln('Данная программа вычисляет произведение элементов массива с N элементов:' + #13#10);

    Repeat
        IsIncorrect := True;
        Writeln('Введите количство элементов [0; 100]:');

        Try
            Readln(NumOfEL);

        Except
            Writeln('Проверьте корректность ввода данных!');
            IsIncorrect := False;
        End;

        If (IsIncorrect) And ((NumOfEl < MINNUMOFEL) Or (NumOfEl > MAXNUMOFEL)) Then
        Begin
            Writeln('Значение не попадает в диапазон!');
            IsIncorrect := False;
        End;
    Until(IsInCorrect);

    SetLength(Arr, NumOfEl);
    For I := Low(Arr) To High(Arr) Do
    Begin
        Repeat
            IsIncorrect := True;
            Writeln('Введите элемент массива [-300; 300]:');

            Try
                Readln(Arr[I]);
            Except
                Writeln('Проверьте корректность ввода данных!');
                IsIncorrect := False;
            End;

            If (IsIncorrect) And ((Arr[I] < MINEL) Or (Arr[I] > MAXEL)) Then
            Begin
                Writeln('Значение не попадает в диапазон!');
                IsIncorrect := False;
            End;

        Until(IsInCorrect);
    End;
    Prod:= Arr[0];
    For I := Low(Arr) To High(Arr) Do
        Prod:= Prod * Arr[i];
    Writeln('Произведение =', Prod);
    Readln;
End.
