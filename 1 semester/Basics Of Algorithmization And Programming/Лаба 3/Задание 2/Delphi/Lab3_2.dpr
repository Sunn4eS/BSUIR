Program Lab3_2;
Uses
    System.SysUtils;
Type
    TSet = Set Of 2..255;
    ERRORS_LIST = (CORRECT, RANGE_ERR, NUM_ERR, NOT_TXT, NOT_EXIST, NOT_READABLE, NOT_WRITEABLE, CHOICE_ERR, FILE_EMPTY);
Const
    MIN_NUMBER = 2;
    MAX_NUMBER = 254;
    FILE_CHOICE = 1;
    CONSOLE_CHOICE = 2;
    ERRORS: Array [ERRORS_LIST] Of String = ('', 'Значение не попадает в диапазон!', 'Проверьте корректность ввода данных!', 'Расширение не txt!', 'Проверьте корректность ввода пути к файлу!', 'Файл закрыт для чтения!', 'Файл закрыт для записи!', 'Проверьте корректность выбора!', 'Файл пуст!');

Procedure PrintTask();
Begin
    WriteLn('Данная программа ищет все простые числа до числа P', #13#10);
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
            Errors := NUM_ERR;
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
        If EOF(F) And (Errors = CORRECT) Then
            Errors := FILE_EMPTY;
        If Errors = CORRECT Then
            AssignFile(F, PathToFile);
        If (Errors = CORRECT) And (IsReadable(F) <> CORRECT) Then
            Errors := NOT_READABLE;
        If Errors <> CORRECT Then
            PrintError(Errors);
    Until Errors = CORRECT;
End;
Procedure FileWriting(Var F: TextFile);
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
        If Errors = CORRECT Then
            AssignFile(F, PathToFile);
        If (ERRORS = CORRECT) And (FileIsReadOnly(PathToFile)) Then
            Errors := NOT_WRITEABLE;
        If Errors <> CORRECT Then
            PrintError(Errors);
    Until Errors = CORRECT;
End;
Function ReadSet() : TSet;
Var
    RF: TextFile;
    Numbers: TSet;
    FromFile: Boolean;
    Num: Integer;
    Error: ERRORS_LIST;
Begin
    Num := 0;
    Error := CORRECT;
    FromFile := ChooseFileInput();
    If FromFile Then
    Begin
        FileReading(RF);
        Reset(RF);
        Try
            Readln(RF, Num);
        Except
            Error := NUM_ERR;
        End;
        If Error = CORRECT Then
            Error := CheckArea(Num, MIN_NUMBER, MAX_NUMBER);
        CloseFile(RF);
        Numbers := [2..Num];
        If Error <> CORRECT Then
            PrintError(Error);
    End
    Else
    Begin
        Writeln('Введите число до которого вы хотетие найти простые числа [', MIN_NUMBER, ':', MAX_NUMBER, ']');
        Num := CheckNum(MIN_NUMBER, MAX_NUMBER);
        Numbers := [2..Num];
    End;
    ReadSet := Numbers;
End;
Function SortSet(PrimeNumbers: TSet): TSet;
Var
    Prime: Integer;
    I, Count: Integer;
Begin
    Count := 1;
    Prime := MIN_NUMBER;
    For I := MIN_NUMBER To MAX_NUMBER Do
    Begin
        If (I In PrimeNumbers) Then
            Inc(Count);
    End;
    While (Prime * Prime < Count) Do
    Begin
        If Prime In PrimeNumbers Then
        Begin
            For I := 2 * Prime To Count Do
                If I Mod Prime = 0 Then
                    Exclude(PrimeNumbers, I);
        End;
        Inc(Prime);
    End;
    SortSet := PrimeNumbers;
End;
Function ChooseFileOutput() : Boolean;
Var
    Choose: Boolean;
Begin
    WriteLn('Вы хотите выводить ответ через файл? (Да - ', 1, ' / Нет - ', 2, ')');
    Choose := CheckInOut();
    ChooseFileOutput := Choose;
End;
Procedure PrintResult(PrimeNumbers: TSet);
Var
    Num: Integer;
    F: TextFile;
    PrintToFile: Boolean;

Begin
    Num := 0;
    PrintToFile := ChooseFileOutput();
    If PrintToFile Then
    Begin
        FileWriting(F);
        Append(F);
        Write(F, 'Множество простых чисел: ');
    End
    Else
        Write('Множество простых чисел:');
    For Num in PrimeNumbers Do
    Begin
        If PrintToFile Then
            Write(F, '''', Num, '''; ')
        Else
            Write('''', Num, '''; ');
    End;
    If PrintToFile Then
        CloseFile(F);
End;
Var
    F: TextFile;
    PrimeNumbers: TSet;
Begin
    PrintTask();
    PrimeNumbers := ReadSet();
    PrimeNumbers := SortSet(PrimeNumbers);
    PrintResult(PrimeNumbers);
    ReadLn;
End.

