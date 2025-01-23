Program Lab3_3;
Uses
    System.SysUtils;
Type
    TMatrix = Array Of Array Of Integer;
    TArr = Array Of Integer;
    ERRORS_LIST = (CORRECT, RANGE_ERR, NUM_ERR, NOT_TXT, NOT_EXIST, NOT_READABLE, NOT_WRITEABLE, ORDER_ERR, CHOICE_ERR, FILE_EMPTY);
Const

    MIN_NUMBER = 0;
    MAX_NUMBER = 100000000;
    FILE_CHOICE = 1;
    CONSOLE_CHOICE = 2;
    ERRORS: Array [ERRORS_LIST] Of String = ('', 'Значение не попадает в диапазон!', 'Проверьте корректность ввода данных!', 'Расширение не txt!', 'Проверьте корректность ввода пути к файлу!', 'Файл закрыт для чтения!', 'Файл закрыт для записи!', 'Значения порядков не равны!', 'Проверьте корректность выбора!', 'Файл пуст!');

Procedure PrintTask();
Begin
    WriteLn('Данная программа переводит числа из 10 с\с в 16 с\с', #13#10);
End;
Function CheckArea(Num: Integer; MIN, MAX: Integer) : ERRORS_LIST;
Var
    Errors: ERRORS_LIST;
Begin
    Errors := CORRECT;
    If (Num < MIN) Or (Num > MAX) Then
        Errors := RANGE_ERR;
    CheckArea := Errors;
End;
Procedure PrintError(Error: ERRORS_LIST);
Begin
    WriteLn(ERRORS[Error], #13#10'Повторите попытку: ');
End;
Function CheckNum(MIN, MAX: Integer) : Integer;
Var
    Errors: ERRORS_LIST;
    Num: Integer;
Begin
    Num := 0;
    Repeat
        Errors := CORRECT;
        Try
            Readln(Num);
        Except
            Errors := CHOICE_ERR;
        End;
        If Errors = CORRECT Then
            Errors := CheckArea(Num, MIN, MAX);
        If Errors <> CORRECT Then
            PrintError(Errors);
    Until Errors = CORRECT;
    CheckNum := Num;
End;
Function CheckInOut() : Boolean;
Var
    Num: Integer;
    Choose: Boolean;
Begin
    Choose := False;
    Num := CheckNum(FILE_CHOICE, CONSOLE_CHOICE);
    If Num = 1 Then
        Choose := True;
    CheckInOut := Choose;
End;
Function ChooseFileInput() : Boolean;
Var
    Choose: Boolean;
Begin
    WriteLn('Вы хотите вводить число через файл? (Да - ', 1, ' / Нет - ', 2, ')');
    Choose := CheckInOut();
    ChooseFileInput := Choose;
End;
Function IsReadable (Var F: TextFile) : ERRORS_LIST;
Var
    Errors: ERRORS_LIST;
Begin
    Errors := CORRECT;
    Try
        Try
            Reset(F);
        Finally
            CloseFile(F);
        End;
    Except
        Errors := NOT_READABLE;
    End;
    IsReadable := Errors;
End;
Procedure FileReading(Var F: TextFile);
Var
    Errors: ERRORS_LIST;
    PathToFile: String;
Begin
    PathToFile := '';
    Repeat
        Errors := CORRECT;
        Write('Введите путь к файлу с расширением .txt: ');
        Readln(PathToFile);
        If ExtractFileExt(PathToFile) <> '.txt' Then
            Errors := NOT_TXT;
        If Not FileExists(PathToFile) And (Errors = CORRECT) Then
            Errors := NOT_EXIST;
        If EOF(F) Then
            Errors := FILE_EMPTY;
        If Errors = CORRECT Then
            AssignFile(F, PathToFile);
        If (Errors = CORRECT) And (IsReadable(F) <> CORRECT) Then
            Errors := NOT_READABLE;
        If Errors <> CORRECT Then
            PrintError(Errors);
    Until Errors = CORRECT;
End;
Function FileWriting(Var F: TextFile) : String;
Var
    PathToFile: String;
    Errors: ERRORS_LIST;
Begin
    PathToFile := '';
    Repeat
        Errors := CORRECT;
        Write('Введите путь к файлу с расширением .txt: ');
        Readln(PathToFile);
        If ExtractFileExt(PathToFile) <> '.txt' Then
            Errors := NOT_TXT;
        If Not FileExists(PathToFile) And (Errors = CORRECT) Then
            Errors := NOT_EXIST;
            AssignFile(F, PathToFile);
        If (ERRORS = CORRECT) And (FileIsReadOnly(PathToFile)) Then
            Errors := NOT_WRITEABLE;
        If Errors <> CORRECT Then
            PrintError(Errors);
    Until Errors = CORRECT;
    FileWriting := PathTofile;
End;
Function ReadDec(): Integer;
Var
    RF: TextFile;
    Error: ERRORS_LIST;
    DecNum: Integer;
    FromFile: Boolean;
Begin
    Error := CORRECT;
    DecNum := 0;
    FromFile := ChooseFileInput();
    If FromFile Then
    Begin
        FileReading(RF);
        Reset(RF);
        Try
            Readln(RF, DecNum);
        Except
            Error := NUM_ERR;
        End;
        If Error = CORRECT Then
            Error := CheckArea(DecNum, MIN_NUMBER, MAX_NUMBER);
        CloseFile(RF);
        If Error <> CORRECT Then
            PrintError(Error);
    End
    Else
    Begin
        Writeln('Введите число [', MIN_NUMBER, ':', MAX_NUMBER, ']');
        DecNum := CheckNum(MIN_NUMBER, MAX_NUMBER)
    End;
    ReadDec := DecNum;
End;
Function DecToHex(DecNum: Integer): String;
Const
    HexCharList: Array [0..15] Of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
Var
    HexNum: String;
    ModFromDec: Integer;
Begin
    ModFromDec := 0;
    HexNum := '';
    While (DecNum > 0) Do
    Begin
        ModFromDec := DecNum Mod 16;
        HexNum := HexCharList[ModFromDec] + HexNum;
        DecNum := DecNum Div 16;
    End;
    DecToHex := HexNum;
End;
Function ChooseFileOutput() : Boolean;
Var
    Choose: Boolean;
Begin
    WriteLn;
    WriteLn('Вы хотите выводить ответ через файл? (Да - ', 1, ' / Нет - ', 2, ')');
    Choose := CheckInOut();
    ChooseFileOutput := Choose;
End;
Procedure PrintResult(HexNum: String);
Var
    F: TextFile;
    PrintToFile: Boolean;
Begin
    PrintToFile := ChooseFileOutput();
    If PrintToFile Then
    Begin
        FileWriting(F);
        Append(F);
        Write(F, 'Число в 16с/c: ');
        Write(F, HexNum);
        CloseFile(F);
    End
    Else
    Begin
        Write('Число в 16с/c: ');
        Write(HexNum);
    End;
End;
Var
    DecNum: Integer;
    HexNum: String;
Begin
    PrintTask();
    DecNum := ReadDec();
    HexNum := DecToHex(DecNum);
    PrintResult(HexNum);
    ReadLn;
End.

