Program Lab3_1;

Uses
    System.SysUtils;

Const
    MIN_LENGTH = 1;
    MAX_LENGTH = 1000;

Procedure PrintTask();
Begin
    WriteLn('Данная программа находит место последнего вхождения первой строки во вторую:' + #13#10);
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
        WriteLn('Вы хотите вводить строки через файл? (Да - ', 1, ' / Нет - ', 0, ')');
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
Function CheckLength(Str: String) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := True;
    If (Length(Str) < MIN_LENGTH) Or (Length(Str) > MAX_LENGTH) Then
    Begin
        Writeln('Значение не попадает в диапазон!');
        IsCorrect := False;
    End;
    CheckLength := IsCorrect;
End;
Function ReadPathToFile() : String;
Var
    PathToFile: String;
    IsCorrect: Boolean;
Begin
    PathToFile := '';
    IsCorrect := True;
    Repeat
        IsCorrect := True;
        Write('Введите путь к файлу с расширением .txt:');
        ReadLn(PathToFile);
        If ExtractFileExt(PathToFile) <> '.txt' Then
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
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    Reset(F);
    If EOF(F) Then
        IsCorrect := True;
    CloseFile(F);
    IsEmpty := IsCorrect;
End;
Function IsRightFileString(Var F: TextFile) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    Reset(F);
    Readln(F);
    If EOF(F) Then
        IsCorrect := True;
    Readln(F);
    If Not EOF(F) Then
        IsCorrect := True;
    CloseFile(F);
    IsRightFileString := IsCorrect;
End;
Procedure GetFileNormalReading(Var F: TextFile);
Var
    PathToFile: String;
    IsCorrect: Boolean;
Begin
    PathToFile := '';
    Repeat
        IsCorrect := True;
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
        If IsCorrect And IsRightFileString(F) Then
        Begin
            IsCorrect := False;
            WriteLn('Количество строк не совпадает!');
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
Function ReadFileString(Var F: TextFile) : String;
Var
    Str: String;
Begin
    Str := '';
    ReadLn(F, Str);
    ReadFileString := Str;
End;
Function ReadConsoleString(Num: Integer) : String;
Var
    Str: String;
    IsCorrect: Boolean;
Begin
    Str := '';
    IsCorrect := False;
    Repeat
        Write('Введите строку номер ', Num, ' [', MIN_LENGTH, ' : ', MAX_LENGTH, ']: ');
        Readln(Str);
        IsCorrect := CheckLength(Str);
    Until IsCorrect;
    ReadConsoleString := Str;
End;
Procedure ReadString(Var Str1: String; Var Str2: String);
Var
    RF: TextFile;
    IsCorrect: Boolean;
Begin
    Repeat
        IsCorrect := True;
        If ChooseFileInput() Then
        Begin
            GetFileNormalReading(RF);
            Reset(RF);
            Str1 := ReadFileString(RF);
            Str2 := ReadFileString(RF);
            CloseFile(RF);
        End
        Else
        Begin
            Str1 := ReadConsoleString(1);
            Str2 := ReadConsoleString(2);
        End;
        If Length(Str1) > Length(Str2) Then
        Begin
            IsCorrect := False;
            Writeln('Длинна не соответствует условию!');
        End;
    Until IsCorrect;
End;
Function FindLastOccurrence(Str1, Str2: String): Integer;
Var
    LengthOfStr2, LengthOfStr1, IndOfStr1, IndOfStr2, Place: Integer;
    EndOfStr1: Boolean;
Begin
    LengthOfStr1 := Length(Str1);
    LengthOfStr2 := Length(Str2);
    Place := 0;
    IndOfStr1 := 0;
    IndOfStr2 := 0;
    EndOfStr1 := False;
    While (LengthOfStr2 > 0) And (Place = 0) Do
    Begin
        If Str1[LengthOfStr1] = Str2[LengthOfStr2] Then
        Begin
            IndOfStr1 := LengthOfStr1;
            IndOfStr2 := LengthOfStr2;
            While (IndOfStr1 > 0) And (IndOfStr2 > 0) And (Str1[IndOfStr1] = Str2[IndOfStr2]) do
            Begin
                Dec(IndOfStr1);
                Dec(IndOfStr2);
            End;
            If (IndOfStr1 <> 0) Then
                EndOfStr1 := True;
            If (Not EndOfStr1) Then
                Place := IndOfStr2 + 1;
        End;
        Dec(LengthOfStr2);
    End;
    FindLastOccurrence := Place;
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
Procedure PrintConsoleResult(Place: Integer);
Begin
    Writeln('Номер позиции последнего вхождения строки st1 в строку st2 = ', Place);
End;
Procedure PrintFileResult(Var F: TextFile; Place: Integer);
Begin
    Append(F);
    WriteLn(F);
    Writeln(F, 'Номер позиции последнего вхождения строки st1 в строку st2 = ', Place);
    CloseFile(F);
End;
Procedure PrintResult(Place: Integer);
Var
    WF: TextFile;
Begin
    If ChooseFileOutput() Then
    Begin
        GetFileNormalWriting(WF);
        PrintFileResult(WF, Place);
    End
    Else
        PrintConsoleResult(Place);
End;
Var
    Str1, Str2: String;
    Place: Integer;

Begin
    PrintTask();
    ReadString(Str1, Str2);
    Place := FindLastOccurrence(Str1, Str2);
    PrintResult(Place);
    ReadLn;
End.

