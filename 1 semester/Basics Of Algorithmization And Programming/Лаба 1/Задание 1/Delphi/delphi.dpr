Program Num1;

Uses
    System.SysUtils;
Const
    MIN_MONTH = 1;
    MAX_MONTH = 12;
Var
    NumOfMonth: Integer;
    IsIncorrect: Boolean;
Begin
    NumOfMonth := 0;
    Writeln('Данная программа называет месяц года по его номер.' + #13#10);

    Repeat
        IsIncorrect := True;
        Writeln('Введите номер месяца: ');

        Try
            Readln(NumOfMonth);
        Except
            Writeln('Проверьте корректность ввода данных!');
            IsIncorrect := False;
        End;

        If (IsIncorrect) And ((NumOfMonth < MIN_MONTH) Or (NumOfMonth > MAX_MONTH)) Then
        Begin
            Writeln('Значение не попадает в диапазон!');
            IsIncorrect := False;
        End;

    Until(IsInCorrect);

    If (NumOfMonth > 2) And (NumOfMonth < 6) Then
        Writeln('Весна');
    If (NumOfMonth > 8) And (NumOfMonth < 12) Then
        Writeln('Осень');
    If (NumOfMonth > 5) And (NumOfMonth < 9) Then
        Writeln('Лето');
    If (NumOfMonth = 12) Or (NumOfMonth = 1) Or (NumOfMonth = 2) Then
        Writeln('Зима');

    Readln;
End.







