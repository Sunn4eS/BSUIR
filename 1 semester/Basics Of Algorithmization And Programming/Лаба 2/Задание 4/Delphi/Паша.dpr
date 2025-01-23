Program Lab2_4;
Uses
  System.SysUtils;

Type
    TArr = Array Of Integer;
Const
    MIN_LENGTH = 2;
    MAX_LENGTH = 1000;
    MIN_ELEMENT = -10000;
    MAX_ELEMENT = 10000;

Procedure PrintTask();
Begin
    WriteLn('Данная программа проверяет невозрастающая ли последовательность:' + #13#10);
End;
Function ChooseFileInput() : Boolean;
Var
    IsFileInput: Integer;
    IsCorrect, Choose: Boolean;
Begin
    IsFileInput := 0;
    IsCorrect := False;
    Choose := False;
    Repeat
        WriteLn('Вы хотите вводить последовательность через файл? (Да - ', 1, ' / Нет - ', 0, ')');
        Try
            ReadLn(IsFileInput);
            IsCorrect := True;
        Except
            WriteLn('Некорректный выбор!');
            IsCorrect := False;
        End;
        If IsCorrect Then
        Begin
            If IsFileInput = 1 Then
                Choose := True
            Else If IsFileInput = 0 Then
                Choose := False
            Else
            Begin
                WriteLn('Некорректный выбор!');
                IsCorrect := False;
            End;
        End;
    Until IsCorrect;
    ChooseFileInput := Choose;
End;

Function CheckArea(Num: Integer; Const MIN, MAX: Integer) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := True;
    If (Num < MIN) Or (Num > MAX) Then
    Begin
        Writeln('Значение не попадает в диапазон!');
        IsCorrect := False;
    End;
    CheckArea := IsCorrect;
End;

Function ReadPathToFile() : String;
Var
    PathToFile: String;
    IsCorrect: Boolean;
Begin
    PathToFile := '';
    IsCorrect := False;
    Repeat
        Write('Введите путь к файлу с расширением .txt с последовательностью, у которой количество членов должно быть не меньше ', MIN_LENGTH, ' и не больше ', MAX_LENGTH, ' а элементы должны быть в диапазоне [', MIN_ELEMENT, ':', MAX_ELEMENT,']: ');
        ReadLn(PathToFile);
        If ExtractFileExt(PathToFile) = '.txt' Then
            IsCorrect := True
        Else
        Begin
            WriteLn('Расширение файла не .txt!');
            IsCorrect := False;
        End;
    Until IsCorrect;
    ReadPathToFile := PathToFile;
End;

Function IsExists(PathToFile: String) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    If FileExists(PathToFile) Then
        IsCorrect := True;
    IsExists := IsCorrect;
End;

Function IsAbleToReading(Var F: TextFile) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := True;
    Try
        Reset(F);
        CloseFile(F);
    Except
        IsCorrect := False;
    End;
    IsAbleToReading := IsCorrect;
End;

Function IsAbleToWriting(PathToFile: String) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := True;
    If FileIsReadOnly(PathToFile) Then
        IsCorrect := False;
    IsAbleToWriting := IsCorrect;
End;

Function IsEmpty(Var F: TextFile) : Boolean;
Var
    Size: Integer;
    IsCorrect: Boolean;
Begin
    Size := 0;
    IsCorrect := False;
    Reset(F);
    If Not EOF(F) Then
        Size := 1;
    CloseFile(F);
    If Size = 0 Then
        IsCorrect := True;
    IsEmpty := IsCorrect;
End;

Function IsRightFileNums(Var F: TextFile) : Boolean;
Var
    Buf: Char;
    NumOfElements, Element: Integer;
    IsCorrect: Boolean;
Begin
    Buf := ' ';
    NumOfElements := 0;
    Element := 0;
    IsCorrect := True;
    Reset(F);
    Try
        Read(F, NumOfElements);
    Except
        IsCorrect := False;
    End;
    ReadLn(F, Buf);
    If Buf <> #13 Then
        IsCorrect := False;
    If IsCorrect Then
        IsCorrect := CheckArea(NumOfElements, MIN_LENGTH, MAX_LENGTH);
    While IsCorrect And Not EOF(F) Do
    Begin
        While IsCorrect And Not EOLN(F) Do
        Begin
            Try
                Read(F, Element);
            Except
                IsCorrect := False;
            End;
            If IsCorrect Then
                IsCorrect := CheckArea(ElEMENT, MIN_ELEMENT, MAX_ELEMENT);
        End;
        ReadLn(F);
    End;
    CloseFile(F);
    IsRightFileNums := IsCorrect;
End;

Function IsOrdersEqual(Var F: TextFile) : Boolean;
Var
    Length, Element, NumOfElements: Integer;
    IsCorrect: Boolean;
Begin
    NumOfElements := 0;
    Length := 0;
    Element := 0;
    IsCorrect := True;
    Reset(F);
    Readln(F, NumOfElements);
    While IsCorrect And Not EOF(F) Do
    Begin
        Read(F, Element);
        Inc(Length);
        IsCorrect := CheckArea(Length, 0 , MAX_LENGTH);
        If Length <> NumOfElements Then
            IsCorrect := True
    End;
    CloseFile(F);
    If IsCorrect And (NumOfElements <> Length) Then
        IsCorrect := False;
    IsOrdersEqual := IsCorrect;
End;

Procedure GetFileNormalReading(Var F: TextFile);
Var
    PathToFile: String;
    IsCorrect: Boolean;
Begin
    PathToFile := '';
    IsCorrect := True;
    Repeat
        PathToFile := ReadPathToFile();
        AssignFile(F, PathToFile);
        If Not IsExists(PathToFile) Then
        Begin
            IsCorrect := False;
            Writeln('Проверьте корректность ввода пути к файлу!');
        End;
        If IsCorrect And Not IsAbleToReading(F) Then
        Begin
            IsCorrect := False;
            Writeln('Файл закрыт для чтения!');
        End;
        If IsCorrect And IsEmpty(F) Then
        Begin
            IsCorrect := False;
            WriteLn('Файл пуст!');
        End;
        If IsCorrect And Not IsRightFileNums(F) Then
        Begin
            IsCorrect := False;
            WriteLn('Некорректный тип данных внутри файла!');
        End;
        If IsCorrect And Not IsOrdersEqual(F) Then
        Begin
            IsCorrect := False;
            Writeln('Длины не равны!');
        End;
    Until IsCorrect;
End;


Procedure GetFileNormalWriting(Var F: TextFile);
Var
    PathToFile: String;
    IsCorrect: Boolean;
Begin
    PathToFile := '';
    IsCorrect := True;
    Repeat
        PathToFile := ReadPathToFile();
        AssignFile(F, PathToFile);
        If Not IsExists(PathToFile) Then
        Begin
            IsCorrect := False;
            Writeln('Проверьте корректность ввода пути к файлу!');
        End;
        If IsCorrect And Not IsAbleToWriting(PathToFile) Then
        Begin
            IsCorrect := False;
            WriteLn('Файл закрыт для записи!');
        End;
    Until IsCorrect;
End;



Function ReadFileLengthOfArr(Var F: TextFile) : Integer;
Var
    NumOfElements: Integer;
Begin
    NumOfElements := 0;
    Reset(F);
    Read(F, NumOfElements);
    CloseFile(F);
    ReadFileLengthOfArr := NumOfElements;
End;


Function ReadFileArr(Var F: TextFile; NumOfElements: Integer) : TArr;
Var
    Arr: TArr;
    Num: Integer;
Begin
    Num := 0;
    SetLength(Arr, NumOfElements);
    Reset(F);
    Readln(F);
    For Num := Low(Arr) To High(Arr) Do
        Read(F, Arr[Num]);

    CloseFile(F);
    ReadFileArr := Arr;
End;
Function ReadConsoleLengthOfArr() : Integer;
Var
    NumOfElements: Integer;
    IsCorrect: Boolean;
Begin
    NumOfElements := 0;
    IsCorrect := False;
    Repeat
        Write('Введите длину числовой последовательности[', MIN_LENGTH, ' : ', MAX_LENGTH, ']: ');
        Try
            Readln(NumOfElements);
            IsCorrect := True;
        Except
            Writeln('Проверьте корректность ввода данных!');
            IsCorrect := False;
        End;
        If IsCorrect Then
            IsCorrect := CheckArea(NumOfElements, MIN_LENGTH, MAX_LENGTH);
    Until IsCorrect;
    ReadConsoleLengthOfArr := NumOfElements;
End;

Function ReadConsoleArr(NumOfElements: Integer) : TArr;
Var
    Arr: TArr;
    Num, Row, Col: Integer;
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    SetLength(Arr, NumOfElements);
    For Num := Low(Arr) To High(Arr) Do
            Repeat
                Write('Введите  ', (Num + 1), ' член последовательности [', MIN_ELEMENT, ' : ', MAX_ELEMENT, ']: ');
                Try
                    Readln(Arr[Num]);
                    IsCorrect := True;
                Except
                    Writeln('Проверьте корректность ввода данных!');
                    IsCorrect := False;
                End;
                If IsCorrect Then
                    IsCorrect := CheckArea(Arr[Num], MIN_ELEMENT, MAX_ELEMENT);
            Until IsCorrect;
    ReadConsoleArr := Arr;
End;

Procedure ReadArr(Var Arr: TArr; Var NumOfElements: Integer);
Var
    RF: TextFile;
Begin
    If ChooseFileInput() Then
    Begin
        GetFileNormalReading(RF);
        NumOfElements := ReadFileLengthOfArr(RF);
        Arr := ReadFileArr(RF, NumofElements);
    End
    Else
    Begin
        NumOfElements := ReadConsoleLengthOfArr();
        Arr := ReadConsoleArr(NumOfElements);
    End;
End;

Function IsSequenceNonGrowing(Var Arr: TArr): Boolean;
Var
    NonGrowing: Boolean;
    Ind: Integer;
Begin
    NonGrowing := True;
    For Ind := Low(Arr) To (High(Arr) - 1) Do
    Begin
        If Arr[Ind] < Arr[Ind + 1] Then
            NonGrowing := False
    End;
    IsSequenceNonGrowing := NonGrowing;
End;

Procedure FreeMemory(Var Arr: TArr);
Begin
    Arr := Nil;
End;

Function ChooseFileOutput() : Boolean;
Var
    IsFileOutput: Integer;
    IsCorrect, Choose: Boolean;
Begin
    IsFileOutput := 0;
    IsCorrect := False;
    Choose := False;
    WriteLn;
    Repeat
        WriteLn('Вы хотите выводить результат через файл? (Да - ', 1, ' / Нет - ', 0, ')');
        Try
            ReadLn(IsFileOutput);
            IsCorrect := True;
        Except
            WriteLn('Некорректный выбор!');
            IsCorrect := False;
        End;
        If IsCorrect Then
        Begin
            If IsFileOutput = 1 Then
                Choose := True
            Else If IsFileOutput = 0 Then
                Choose := False
            Else
            Begin
                WriteLn('Некорректный выбор!');
                IsCorrect := False;
            End;
        End;
    Until IsCorrect;
    ChooseFileOutput := Choose;
End;

Procedure PrintConsoleResult( Var NonGrowing: Boolean);

Begin
    If NonGrowing Then
        Writeln('Последовательность является невозрастающей')
    Else
        Writeln('Последовательность не соответствует условию');
End;

Procedure PrintFileResult(Var F: TextFile; Var NonGrowing: Boolean);

Begin
    Append(F);
    WriteLn(F);
    If NonGrowing Then
        Writeln('Последовательность является невозрастающей')
    Else
        Writeln('Последовательность не соответствует условию');
    CloseFile(F);
End;
Procedure PrintResult(NonGrowing: Boolean);
Var
    WF: TextFile;
Begin
    If ChooseFileOutput() Then
    Begin
        GetFileNormalWriting(WF);
        PrintFileResult(WF, NonGrowing);
    End
    Else
        PrintConsoleResult(NonGrowing);
End;
Var

    NumOfElements: Integer;
    Arr: TArr;
    NonGrowing: Boolean;

Begin
    NumOfElements:= 0;
    NonGrowing := True;

    PrintTask();
    ReadArr(Arr, NumOfElements);
    NonGrowing := IsSequenceNonGrowing(Arr);
    PrintResult(NonGrowing);
    FreeMemory(Arr);
    ReadLn;
End.

