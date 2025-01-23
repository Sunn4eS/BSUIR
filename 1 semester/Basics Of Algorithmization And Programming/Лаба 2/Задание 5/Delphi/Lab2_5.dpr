Program Lab2_5;
Uses
    System.SysUtils;
Type
    TMatrix = Array Of Array Of Integer;
    TArr = Array Of Integer;
Const
    MIN_MATRIX = 2;
    MAX_MATRIX = 100;
    MIN_ELEMENT = -100000;
    MAX_ELEMENT = 100000;

Procedure PrintTask();
Begin
    WriteLn('Данная программа находит седловую точку матрицы:', #13#10);
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
        WriteLn('Вы хотите вводить матрицу через файл? (Да - ', 1, ' / Нет - ', 0, ')');
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

Function CheckArea(Num: Integer; MIN, MAX: Integer) : Boolean;
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
        Write('Введите путь к файлу с расширением .txt с матрицей, у которой порядок не должен превышать ', MAX_MATRIX, ', а её элементы должны лежать в пределе[', MIN_ELEMENT, ' : ', MAX_ELEMENT,']: ');

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
    Order, Element: Integer;
    IsCorrect: Boolean;
Begin
    Buf := ' ';
    Order := 0;
    Element := 0;
    IsCorrect := True;
    Reset(F);
    Try
        Read(F, Order);
    Except
        IsCorrect := False;
    End;
    ReadLn(F, Buf);
    If Buf <> #13 Then
        IsCorrect := False;
    If IsCorrect Then
        IsCorrect := CheckArea(Order, MIN_MATRIX, MAX_MATRIX);
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
                IsCorrect := CheckArea(Element, MIN_ELEMENT, MAX_ELEMENT);
        End;
        ReadLn(F);
    End;
    CloseFile(F);
    IsRightFileNums := IsCorrect;
End;

Function IsOrdersEqual(Var F: TextFile) : Boolean;
Var
    Order, Rows, Cols, K: Integer;
    IsCorrect: Boolean;
Begin
    Order := 0;
    Rows := 0;
    Cols := 0;
    K := 0;
    IsCorrect := True;
    Reset(F);
    Readln(F, Order);
    While IsCorrect And Not EOF(F) Do
    Begin
      Cols := 0;
      While IsCorrect And Not EOLN(F) Do
      Begin
          Read(F, K);
          Inc(Cols);
      End;
      If IsCorrect Then
      Begin
          Readln(F);
          Inc(Rows);
          If Cols = Order Then
              IsCorrect := True;
      End;
    End;
    CloseFile(F);
    If IsCorrect Then
    Begin
        IsCorrect := CheckArea(Cols, MIN_MATRIX, MAX_MATRIX);
        IsCorrect := CheckArea(Rows, MIN_MATRIX, MAX_MATRIX);
    End;
    If IsCorrect And  (Rows <> Order) Then
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
            Writeln('Значения порядков не равны!');
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

Function ReadFileOrder(Var F: TextFile) : Integer;
Var
    Order: Integer;
Begin
    Order := 0;
    Reset(F);
    Read(F, Order);
    CloseFile(F);
    ReadFileOrder := Order;
End;

Function ReadFileMatrix(Var F: TextFile; Order: Integer) : TMatrix;
Var
    Matrix: TMatrix;
    Row, Col: Integer;
Begin
    SetLength(Matrix, Order, Order);
    Reset(F);
    Readln(F);
    For Row := Low(Matrix) To High(Matrix) Do
    Begin
        For Col := Low(Matrix[Row]) To High(Matrix[Row]) Do
            Read(F, Matrix[Row][Col]);
        Readln(F);
    End;
    CloseFile(F);
    ReadFileMatrix := Matrix
End;

Function ReadConsoleOrder() : Integer;
Var
    Order: Integer;
    IsCorrect: Boolean;
Begin
    Order := 0;
    IsCorrect := False;
    Repeat
        Write('Введите порядок матрицы [', MIN_MATRIX, '; ', MAX_MATRIX, ']: ');
        Try
            Readln(Order);
            IsCorrect := True;
        Except
            Writeln('Проверьте корректность ввода данных!');
            IsCorrect := False;
        End;
        If IsCorrect Then
            IsCorrect := CheckArea(Order, MIN_MATRIX, MAX_MATRIX);
    Until IsCorrect;
    ReadConsoleOrder := Order;
End;

Function ReadConsoleMatrix(Order: Integer) : TMatrix;
Var
    Matrix: TMatrix;
    Row, Col: Integer;
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    SetLength(Matrix, Order, Order);
    For Row := Low(Matrix) To High(Matrix) Do
        For Col := Low(Matrix) To High(Matrix) Do
            Repeat
                Write('Введите в ', (Row + 1), ' строке ', (Col + 1), ' столбце элемент[', MIN_ELEMENT, ' : ', MAX_ELEMENT, ']: ');
                Try
                    Readln(Matrix[Row][Col]);
                    IsCorrect := True;
                Except
                    Writeln('Проверьте корректность ввода данных!');
                    IsCorrect := False;
                End;
                If IsCorrect Then
                    IsCorrect := CheckArea(Matrix[Row][Col], MIN_ELEMENT, MAX_ELEMENT);
            Until IsCorrect;
    ReadConsoleMatrix := Matrix;
End;

Procedure ReadMatrix(Var Matrix: TMatrix; Var Order: Integer);
Var
    RF: TextFile;
Begin
    If ChooseFileInput() Then
    Begin
        GetFileNormalReading(RF);
        Order := ReadFileOrder(RF);
        Matrix := ReadFileMatrix(RF, Order);
    End
    Else
    Begin
        Order := ReadConsoleOrder();
        Matrix := ReadConsoleMatrix(Order);
    End;
End;

Function FindMinInLine(Matrix: TMatrix; Order: Integer): TArr;
Var
    MinInLine: TArr;
    Line, Column: Integer;
Begin
    Line := 0;
    Column := 0;
    SetLength(MinInLine, Order);
    For Line := Low(Matrix) To High(Matrix) Do
    Begin
        MinInLine[Line] := Matrix[Line][0];
        For Column := Low(Matrix) To High(Matrix) Do
        Begin
            If Matrix[Line][Column] < MinInLine[Line] Then
                MinInLine[line] := Matrix[Line][Column];
        End;
    End;
    FindMinInLine := MinInLine;
End;

Function FindMaxInColumn(Matrix: TMatrix; Order: Integer): TArr;
Var
    Line, Column: Integer;
    MaxInColumn: TArr;
Begin
    Line := 0;
    Column := 0;
    SetLength(MaxInColumn, Order);
    For Column := Low(Matrix) To High(Matrix) Do
    Begin
        MaxInColumn[Column] := Matrix[0][Column];
        For Line := Low(Matrix) To High(Matrix) Do
        Begin
            If Matrix[Line][Column] > MaxInColumn[Column] Then
                MaxInColumn[Column] := Matrix[Line][Column];
        End;
    End;
    FindMaxInColumn := MaxInColumn;
End;

Procedure FreeMemory(Var Matrix: TMatrix; Var MinInLine: TArr; Var MaxInLine: TArr);
Begin
    Matrix := Nil;
    MinInLine := Nil;
    MaxInLine := Nil;
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
        WriteLn('Вы хотите выводить ответ через файл? (Да - ', 1, ' / Нет - ', 0, ')');
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

Procedure PrintConsoleResult(MinInLine: TArr; MaxInColumn: TArr);
Var
    Line, Column: Integer;
    SaddlePoint: Boolean;
Begin
    Line := 0;
    Column := 0;
    SaddlePoint := False;
    For Line := Low(MaxInColumn) To High(MaxInColumn) Do
    Begin
        For Column := Low(MaxInColumn) To High(MaxInColumn) Do
        Begin
            If MinInLine[line] = MaxInColumn[Column] Then
            Begin
                Writeln('Седловая точка находиться на месте: ', line + 1, ' ', column + 1);
                Saddlepoint := True;
            End;
        End;
    End;
    If Not SaddlePoint Then
        Writeln('Нет седловой точки!');
End;

Procedure PrintFileResult(Var F: TextFile; MinInLine: TArr; MaxInColumn: TArr);
Var
    Line, Column: Integer;
    SaddlePoint: Boolean;
Begin
    SaddlePoint := False;
    Line := 0;
    Column := 0;
    Append(F);
    WriteLn(F);
    For Line := Low(MaxInColumn) To High(MaxInColumn) Do
    Begin
        For Column := Low(MaxInColumn) To High(MaxInColumn) Do
        Begin
            If MinInLine[line] = MaxInColumn[Column] Then
            Begin
                Writeln(F, 'Седловая точка находиться на месте: ', line + 1, ' ', column + 1);
                SaddlePoint := True;
            End;

        End;
    End;
    If Not SaddlePoint Then
        Writeln(F,'Нет седловой точки!');
    CloseFile(F);
End;

Procedure PrintResult(MinInLine, MaxInColumn: TArr);
Var
    WF: TextFile;
Begin
    If ChooseFileOutput() Then
    Begin
        GetFileNormalWriting(WF);
        PrintFileResult(WF, MinInLine, MaxInColumn);
    End
    Else
        PrintConsoleResult(MinInLine, MaxInColumn);
End;

Var
    Matrix: TMatrix;
    Order: Integer;
    MinInLine, MaxInColumn: TArr;
Begin
    Order := 0;
    PrintTask();
    ReadMatrix(Matrix, Order);
    MaxInColumn := FindMaxInColumn(Matrix, Order);
    MinInLine := FindMinInLine(Matrix, Order);
    PrintResult(MinInLine, MaxInColumn);
    FreeMemory(Matrix, MinInLine, MaxInColumn);
    ReadLn;
End.

