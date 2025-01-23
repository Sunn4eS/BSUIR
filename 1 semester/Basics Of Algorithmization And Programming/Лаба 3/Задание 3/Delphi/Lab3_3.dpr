Program Lab3_3;
Uses
    System.SysUtils;
Type
    TMatrix = Array Of Array Of Integer;
    TArr = Array Of Integer;
    ERRORS_LIST = (CORRECT, RANGE_ERR, NUM_ERR, NOT_TXT, NOT_EXIST, NOT_READABLE, NOT_WRITEABLE, ORDER_ERR, CHOICE_ERR, FILE_EMPTY);
Const
    MIN_MATRIX = 2;
    MAX_MATRIX = 10;
    MIN_ELEMENT = -100000;
    MAX_ELEMENT = 100000;
    FILE_CHOICE = 1;
    CONSOLE_CHOICE = 2;
    ERRORS: Array [ERRORS_LIST] Of String = ('', 'Значение не попадает в диапазон!', 'Проверьте корректность ввода данных!', 'Расширение не txt!', 'Проверьте корректность ввода пути к файлу!', 'Файл закрыт для чтения!', 'Файл закрыт для записи!', 'Значения порядков не равны!', 'Проверьте корректность выбора!', 'Файл пуст!');

Procedure PrintTask();
Begin
    WriteLn('Данная программа располагает строки матрицы по возрастанию эелементов побочной диагонали исходной матрицы', #13#10);
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
    WriteLn('Вы хотите вводить матрицу через файл? (Да - ', 1, ' / Нет - ', 2, ')');
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
Function ReadOrder(Var F: TextFile; Num: Integer): Integer;
Var
    Buf, Order, Rows, Cols: Integer;
    Errors: ERRORS_LIST;
Begin
    Order := 0;

    Errors := CORRECT;
    If Num = 2 Then
    Begin
        Write('Введите порядок матрицы [', MIN_MATRIX, '; ', MAX_MATRIX, ']: ');
        Order := CheckNum(MIN_MATRIX, MAX_MATRIX);
    End
    Else
    Begin
        Errors := CORRECT;
        Rows := 1;
        Cols := 0;
        Buf := 0;
        Reset(F);
        Readln(F, Order);
        If CheckArea(Order, MIN_MATRIX, MAX_MATRIX) <> CORRECT Then
        Begin
            Errors := ORDER_ERR;
            CloseFile(F);
        End
        Else
        Begin
            While (ERRORS = CORRECT) And (Not EOF(F)) Do
            Begin
                Cols := 0;
                While (ERRORS = CORRECT) And (Not EOLN(F)) Do
                Begin

                    try
                        Read(F, Buf);
                    except
                        Errors := NUM_ERR;
                    end;
                    Inc(Cols);
                End;
                If Errors = CORRECT Then
                Begin
                    Readln(F, Buf);
                    Inc(Rows);
                    If Cols = Order Then
                        Errors := CORRECT;
                End;
            End;
            CloseFile(F);
            If Errors = CORRECT Then
            Begin
                Errors := CheckArea(Rows, MIN_MATRIX, MAX_MATRIX);
                Errors := CheckArea(Cols, MIN_MATRIX, MAX_MATRIX);
            End;
            If (Errors = CORRECT) And ((Rows Or Cols) <> Order) Then
                Errors := ORDER_ERR;
        End;
    End;
    If Errors <> CORRECT Then
        PrintError(Errors);
    If Errors = CORRECT Then
        ReadOrder := Order;
End;
Procedure ReadMatrix(Var Matrix: TMatrix; Var Order: Integer);
Var
    RF: TextFile;
    Errors: ERRORS_LIST;
    IsCorrect, FromFile: Boolean;
    OrderCheck: Integer;
    Row, Col: Integer;
Begin
    OrderCheck := 0;
    FromFile := ChooseFileInput();
    If FromFile Then
    Begin
        Repeat
            IsCorrect := True;
            FileReading(RF);
            Order := ReadOrder(RF,1);
            OrderCheck := Order;
            If OrderCheck = 0 Then
                IsCorrect := False;
            Reset(RF);
            Readln(RF);
        Until (IsCorrect);
    End
    Else
        Order := ReadOrder(RF, 2);
    SetLength(Matrix, Order, Order);
    For Row := Low(Matrix) To High(Matrix) Do
    Begin
        For Col := Low(Matrix[Row]) To High(Matrix[Row]) Do
        Begin
            If FromFile Then
            Begin
                Read(RF, Matrix[Row][Col]);
                Errors := CheckArea(Matrix[Row][Col], MIN_ELEMENT, MAX_ELEMENT);
            End
            Else
            Begin
                Write('Введите в ', (Row + 1), ' строке ', (Col + 1), ' столбце элемент[', MIN_ELEMENT, ' : ', MAX_ELEMENT, ']: ');
                Matrix[Row][Col] := CheckNum(MIN_ELEMENT, MAX_ELEMENT);
            End;
        End;
        If FromFile Then
            Readln(RF);
    End;
    If FromFile Then
        CloseFile(RF);
End;
Procedure SwapMatrixColumns(DiagonalJ: TMatrix; Col1, Col2: Integer);
Var
    I, Temp: Integer;
begin
    For I := 0 To High(DiagonalJ) Do
    Begin
        Temp := DiagonalJ[I][Col1];
        DiagonalJ[I][Col1] := DiagonalJ[I][Col2];
        DiagonalJ[I][Col2] := Temp;
    End;
End;
Function CreateMatrixOfDiagonalElements (Matrix:TMatrix): TMatrix;
Var
    Diagonal: TMatrix;
    I: Integer;
Begin
    Setlength(Diagonal, 2, High(Matrix) + 1);
    For I := 0 To High(Matrix) Do
    Begin
        Diagonal[0][I] := Matrix[I][High(Matrix) - I];
        Diagonal[1][I] := I;
    End;
    CreateMatrixOfDiagonalElements := Diagonal;
End;
Function SortDiagonal(Diagonal: TMatrix): TMatrix;
Var
    J, I, MinInColumn, NumOfColumn: Integer;
Begin
    For J := 0 To Length(Diagonal[0]) - 1 Do
    Begin
        I := J + 1;
        MinInColumn := Diagonal[0][J];
        NumOfcolumn := J;
        While (I < Length(Diagonal[0])) Do
        Begin
            If MinInColumn > Diagonal[0][I] Then
            Begin
                MinInColumn := Diagonal[0][I];
                NumOfColumn := I;
            End;
            Inc(I);
        End;
        If NumOfColumn <> J Then
        SwapMatrixColumns(Diagonal, J, NumOfColumn);
    End;
    SortDiagonal := Diagonal;
End;
Procedure MoveLines(ResMatrix, Matrix: TMatrix; NewLine, PrevLine: Integer);
Begin
    ResMatrix[PrevLine] := Matrix[NewLine];
End;
Function SortMatrix(Matrix, Diagonal: TMatrix; N: Integer): TMatrix;
Var
    ResMatrix: TMatrix;
    I, NewLine: Integer;
Begin
    ResMatrix := Copy(Matrix);
    NewLine := 0;
    For I := 0 To Length(Diagonal[1]) - 1 Do
    Begin
        NewLine := Diagonal[1][I];
        MoveLines(ResMatrix, Matrix, NewLine, I);
    End;
    SortMatrix := ResMatrix;
End;
Procedure FreeMemory(Var Matrix: TMatrix; Var ResMatrix: TMatrix; Var DiagonalJ: TMatrix);
Begin
    Matrix := Nil;
    ResMatrix := Nil;
    DiagonalJ := Nil;
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
Procedure PrintResult(ResMatrix: TMatrix);
Var
    Line, Column: Integer;
    F: TextFile;
    PrintToFile: Boolean;
Begin
    Line := 0;
    Column := 0;
    PrintToFile := ChooseFileOutput();
    If PrintToFile Then
    Begin
        FileWriting(F);
        Append(F);
        Writeln(F, 'Отсортированная Матрица:');
    End
    Else
        Writeln('Отсортированная Матрица:');
    For Line := 0 To High(ResMatrix) Do
    Begin
        For Column := 0 To High(ResMatrix) Do
        Begin
            If PrintToFile Then
                Write(F, ResMatrix[Line][Column], ' ')
            Else
                Write(ResMatrix[Line][Column], ' ');
        End;
        If PrintToFile Then
            Writeln(F)
        Else
            Writeln;
    End;
    If PrintToFile Then
        CloseFile(F);
End;
Var
    F: TextFile;
    Order: Integer;
    Matrix, Diagonal, ResMatrix: TMatrix;

Begin
    PrintTask();
    ReadMatrix(Matrix, Order);
    Diagonal := CreateMatrixOfDiagonalElements(Matrix);
    Diagonal := SortDiagonal(Diagonal);
    ResMatrix := SortMatrix(Matrix, Diagonal, Order);
    PrintResult(ResMatrix);
    FreeMemory(Matrix, ResMatrix, Diagonal);
    ReadLn;
End.

