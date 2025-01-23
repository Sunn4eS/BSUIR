Program Task1;

Uses
    System.SysUtils;

Type
    TArr = Array of Integer;
    ERRORS_CODE = (CORRECT,
                   INCORRECT_CHOICE,
                   INCORRECT_NUMBER,
                   FILE_NOT_TXT,
                   FILE_NOT_EXIST,
                   FILE_NOT_READABLE,
                   FILE_IS_EMPTY,
                   FILE_NOT_WRITABLE,
                   INCORRECT_RANGE,
                   INCORRECT_ARRAY_LENGTH,
                   EXTRA_DATA,
                   INCORRECT_DATA_IN_FILE);

Const
    ERRORS: Array [ERRORS_CODE] Of String = ('Правильно',
                                             'Проверьте корректность ввода данных!',
                                             'Ошибка! Введите 1 или 2',
                                             'Расширение файла не .txt!',
                                             'Проверьте корректность ввода пути к файлу!',
                                             'Файл закрыт для чтения!',
                                             'Файл пуст!',
                                             'Файл закрыт для записи!',
                                             'Значение не попадает в диапазон!',
                                             'Неправильная длина массива!',
                                             'Лишние данные в файле!',
                                             'Некорректный тип данных в файле!');

Procedure PrintTask();
Begin
    Writeln('Эта программа реализует сортировку бинарными вставками');
End;

Function ChooseOption() : Integer;
Var
    Error: ERRORS_CODE;
    OptionString: String;
    OptionInt: Integer;
Begin
    OptionInt := 0;
    OptionString := '';
    Repeat
        Error := CORRECT;
        Readln(OptionString);
        Try
            OptionInt := StrToInt(OptionString);
        Except
            Error := INCORRECT_CHOICE
        End;
        If (Error = CORRECT) And (OptionInt <> 1) And (OptionInt <> 2) Then
            Error := INCORRECT_NUMBER;
        If Error <> CORRECT Then
            Writeln(ERRORS[Error]);
    Until Error = CORRECT;
    ChooseOption := OptionInt;
End;

Function ReadPathToFile() : String;
Var
    PathToFile: String;
    Error: ERRORS_CODE;
Begin
    PathToFile := '';
    Repeat
        Error := CORRECT;
        Write('Введите путь к файлу: ');
        ReadLn(PathToFile);
        If ExtractFileExt(PathToFile) <> '.txt' Then
            Error := FILE_NOT_TXT;
        If Error <> CORRECT Then
            Writeln(ERRORS[Error]);
    Until Error = CORRECT;
    ReadPathToFile := PathToFile;
End;

Function IsReadable(Var F: TextFile) : ERRORS_CODE;
Var
    Error: ERRORS_CODE;
Begin
    Error := CORRECT;
    Try
        Reset(F);
        CloseFile(F);
    Except
        Error := FILE_NOT_READABLE;
    End;
    IsReadable := Error;
End;

Function IsWritable(Var F: TextFile) : ERRORS_CODE;
Var
    Error: ERRORS_CODE;
Begin
    Error := CORRECT;
    Try
        Append(F);
        CloseFile(F);
    Except
        Error := FILE_NOT_WRITABLE;
    End;
    IsWritable := Error;
End;

Function IsEmpty(Var F: TextFile) : ERRORS_CODE;
Var
    Size: Integer;
    Error: ERRORS_CODE;
Begin
    Size := 0;
    Error := CORRECT;
    Reset(F);
    If Not EOF(F) Then
        Size := 1;
    CloseFile(F);
    If Size = 0 Then
        Error := FILE_IS_EMPTY;
    IsEmpty := Error;
End;

Procedure GetReadableFile(Var F: TextFile);
Var
    PathToFile: String;
    Error: ERRORS_CODE;
Begin
    Repeat
        Error := CORRECT;
        PathToFile := ReadPathToFile();
        AssignFile(F, PathToFile);
        If Not FileExists(PathToFile) Then
            Error := FILE_NOT_EXIST;
        If Error = CORRECT Then
            Error := IsReadable(F);
        If Error = CORRECT Then
            Error := IsEmpty(F);
        If Error <> CORRECT Then
            Writeln(ERRORS[Error]);
    Until Error = CORRECT;
End;

Procedure GetWritableFile(Var F: TextFile);
Var
    PathToFile: String;
    Error: ERRORS_CODE;
Begin
    Repeat
        Error := CORRECT;
        PathToFile := ReadPathToFile();
        AssignFile(F, PathToFile);
        If Not FileExists(PathToFile) Then
            Error := FILE_NOT_EXIST;
        If Error = CORRECT Then
            Error := IsWritable(F);
        If Error <> CORRECT Then
            Writeln(ERRORS[Error]);
    Until Error = CORRECT;
End;

Function ReadFileNum(Var F: TextFile; Var Num: Integer; Const MIN: Integer; Const MAX: Integer) :
                     ERRORS_CODE;
Var
    Error: ERRORS_CODE;
Begin
    Error := CORRECT;
    Try
        Read(F, Num);
    Except
        Error := INCORRECT_DATA_IN_FILE;
    End;
    If (Error = CORRECT) And ((Num < MIN) Or (Num > MAX)) Then
        Error := INCORRECT_RANGE;
    ReadFileNum := Error;
End;

Procedure ReadConsoleNum(Var Num: Integer; Const MIN: Integer; Const MAX: Integer);
Var
    Error: ERRORS_CODE;
    StringNum: String;
Begin
    Repeat
        Error := CORRECT;
        ReadLn(StringNum);
        Try
            Num := StrToInt(StringNum);
        Except
            Error := INCORRECT_CHOICE;
        End;
        If (Error = CORRECT) And ((Num < MIN) Or (Num > MAX)) Then
            Error := INCORRECT_RANGE;
        If Error <> CORRECT Then
            Writeln(ERRORS[Error]);
    Until Error = CORRECT;
End;

Function ReadLengthOfArray(Var F: TextFile; Var ArrayLength: Integer; Const Option: Integer; Const
                           MIN: Integer; Const MAX: Integer) : ERRORS_CODE;
Var
   Error: ERRORS_CODE;
Begin
    Error := CORRECT;
    If Option = 1 Then
    Begin
        Error := ReadFileNum(F, ArrayLength, MIN, MAX);
        If (Error = CORRECT) And (Not EOLN(F)) Then
            Error := EXTRA_DATA;
    End
    Else
    Begin
        Write('Введите длину массива[', MIN, ': ', MAX, ']: ');
        ReadConsoleNum(ArrayLength, MIN, MAX);
    End;
    ReadLengthOfArray := Error;
End;

Function FillArray(Var F: TextFile; Const ArrayLength: Integer; Var Arr: TArr; Const Option:
                   Integer; Const MIN: Integer; Const MAX: Integer) : ERRORS_CODE;
Var
   Error: ERRORS_CODE;
   I: Integer;
Begin
    Error := CORRECT;
    If Option = 1 Then
    Begin
        SetLength(Arr, ArrayLength);
        I := 0;
        ReadLn(F);
        While (Error = CORRECT) And (I < ArrayLength) Do
        Begin
            Error := ReadFileNum(F, Arr[I], MIN, MAX);
            Inc(I);
        End;
        If (Error = CORRECT) And (I <> ArrayLength) Then
            Error := INCORRECT_ARRAY_LENGTH;
        If (Error = CORRECT) And (Not EOF(F)) Then
            Error := EXTRA_DATA;
    End
    Else
    Begin
        SetLength(Arr, ArrayLength);
        Writeln('Введите массив: ');
        For I := Low(Arr) To High(Arr) Do
        Begin
            Write('Введите ', I + 1, ' элемент массива в диапазоне[', MIN, ': ', MAX, ']: ');
            ReadConsoleNum(Arr[I], MIN, MAX);
        End;
    End;
    FillArray := Error;
End;

Procedure ReadArray(Var Arr: TArr; Var ArrayLength: Integer);
Const
    MIN_LENGTH = 1;
    MAX_LENGTH = 1000;
    MIN_ARRAY = -1000000;
    MAX_ARRAY = 1000000;
Var
    F: TextFile;
    Option: Integer;
    Error: ERRORS_CODE;
Begin
    Writeln;
    Writeln('Выберете способ ввода данных:');
    Writeln('Через файл - 1');
    Writeln('Через консоль - 2');
    Option := ChooseOption();
    If Option = 1 Then
    Begin
        Repeat
            GetReadableFile(F);
            Reset(F);
            Error := ReadLengthOfArray(F, ArrayLength, Option, MIN_LENGTH, MAX_LENGTH);
            If Error = CORRECT Then
                Error := FillArray(F, ArrayLength, Arr, Option, MIN_ARRAY, MAX_ARRAY);
            CloseFile(F);
            If Error <> CORRECT Then
                Writeln(ERRORS[Error]);
        Until Error = CORRECT;
    End
    Else
    Begin
        Repeat
            Error := ReadLengthOfArray(F, ArrayLength, Option, MIN_LENGTH, MAX_LENGTH);
            Error := FillArray(F, ArrayLength, Arr, Option, MIN_ARRAY, MAX_ARRAY);
        Until Error = CORRECT;
    End;
End;

Function FindPositionOfElement(Const Arr: TArr; Const Buf: Integer; High: Integer) : Integer;
Var
   Low, Mid: Integer;
Begin
    Low := 0;
    While Low <= High Do
    Begin
        Mid := (Low + High) Div 2;
        If Buf < Arr[Mid] Then
            High := Mid - 1
        Else
            Low := Mid + 1;
    End;
    FindPositionOfElement := Low;
End;

Procedure PrintDetail(Const Arr: TArr; Const I: Integer);
Var
    K: Integer;
Begin
    For K := Low(Arr) To I Do
        Write(Arr[K], ' ');
    Write('  ');
    For K := I + 1 To High(Arr) Do
        Write(Arr[K], ' ');
    Writeln;
End;

Procedure SortArray(Var Arr: TArr);
Var
    I, J, HighPosition, LowPosition, Buf: Integer;
Begin
    For I := Low(Arr) + 1 To High(Arr) Do
    Begin
        Buf := Arr[I];
        HighPosition := I;
        LowPosition := FindPositionOfElement(Arr, Buf, HighPosition);
        J := I - 1;
        While J >= LowPosition Do
        Begin
            Arr[J + 1] := Arr[J];
            Dec(J);
        End;
        Arr[J + 1] := Buf;
        PrintDetail(Arr, I);
    End;
End;

Procedure PrintInputArray(Const Arr: TArr);
Var
    I: Integer;
Begin
    Writeln;
    Write('Исходный массив: ');
    For I := Low(Arr) To High(Arr) Do
        Write(Arr[I], ' ');
    Writeln;
    Writeln('Пошаговая детализация:');
    Write(Arr[0], '   ');
    For I := Low(Arr) + 1 To High(Arr) Do
        Write(Arr[I], ' ');
    Writeln;
End;

Procedure PrintResult(Const Arr: TArr);
Var
    F: TextFile;
    Option, I: Integer;
Begin
    Writeln;
    Writeln('Выберете способ вывода результата:');
    Writeln('Через файл - 1');
    Writeln('Через консоль - 2');
    Option := ChooseOption();
    If Option = 1 Then
    Begin
        GetWritableFile(F);
        Append(F);
        Writeln(F);
        Write(F, 'Отсортированный массив: ');
        For I := Low(Arr) To High(Arr) Do
            Write(F, Arr[I], ' ');
        CloseFile(F);
    End
    Else
    Begin
        Writeln;
        Write('Отсортированный массив: ');
        For I := Low(Arr) To High(Arr) Do
            Write(Arr[I], ' ');
    End;
End;

Var
    InputArray: TArr;
    ArrayLength: Integer;

Begin
   PrintTask();
   ReadArray(InputArray, ArrayLength);
   PrintInputArray(InputArray);
   SortArray(InputArray);
   PrintResult(InputArray);
   Readln;
End.

