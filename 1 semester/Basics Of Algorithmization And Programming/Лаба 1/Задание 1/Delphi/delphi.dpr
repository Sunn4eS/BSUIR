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
    Writeln('������ ��������� �������� ����� ���� �� ��� �����.' + #13#10);

    Repeat
        IsIncorrect := True;
        Writeln('������� ����� ������: ');

        Try
            Readln(NumOfMonth);
        Except
            Writeln('��������� ������������ ����� ������!');
            IsIncorrect := False;
        End;

        If (IsIncorrect) And ((NumOfMonth < MIN_MONTH) Or (NumOfMonth > MAX_MONTH)) Then
        Begin
            Writeln('�������� �� �������� � ��������!');
            IsIncorrect := False;
        End;

    Until(IsInCorrect);

    If (NumOfMonth > 2) And (NumOfMonth < 6) Then
        Writeln('�����');
    If (NumOfMonth > 8) And (NumOfMonth < 12) Then
        Writeln('�����');
    If (NumOfMonth > 5) And (NumOfMonth < 9) Then
        Writeln('����');
    If (NumOfMonth = 12) Or (NumOfMonth = 1) Or (NumOfMonth = 2) Then
        Writeln('����');

    Readln;
End.







