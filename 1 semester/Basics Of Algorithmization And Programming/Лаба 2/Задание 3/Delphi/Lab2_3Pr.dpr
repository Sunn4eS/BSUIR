Program Lab2_3Pr;
uses
  System.SysUtils;

Type
    TMatrix = Array Of Array Of Integer;
Const
    MIN_O = 1;
    MAX_O = 10;
    MIN_MAT = -1000000;
    MAX_MAT = 1000000;
    YES = 1;
    NO = 2;

Procedure  OutputTask();
Begin
    WriteLn('Данная программа печатает номера отличников:' + #13#10);
End;




Function ChooseInputMethod() : Boolean;
Var
    IsFileInput: Integer;
    IsCorrect, Choose: Boolean;
Begin
    Repeat
        IsCorrect := True;
        Writeln('Вы хотите вводить таблицу оценок через файл? (Да - ', 1, ' / Нет - ', 0, ')');
        Try
            Readln(IsFileInput);
        Except
            Writeln('Некорректный выбор!');
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
    ChooseInputMethod := Choose;
End;



Function  CheckUserArea(Mark: Integer) : Boolean;
Const
    MIN = 0;
    MAX = 10;

Begin
    CheckUserArea :=  (Mark < MIN) Or (Mark > MAX);
End;




Function ReadUserN(Num: Integer; MIN, MAX: Integer) : Integer;
Var
    IsCorrect: Boolean;
Begin
    Repeat
        Write('Введите порядок матрицы N[', MIN, '; ', MAX, ']: ');
        Try
            Readln(Num);
            IsCorrect := True;
        Except
            Writeln('Проверьте корректность ввода данных!');
            IsCorrect := False;
        End;
        If IsCorrect Then
            IsCorrect := CheckUserArea(Num, MIN, MAX);
    Until IsCorrect;
    ReadUserN := Num;
End;






Function ReadUserMatrix(Num: Integer; Row, Col, MIN, MAX: Integer) : Integer;
Var
    IsCorrect: Boolean;
Begin
    Repeat
        Write('Введите в ', (Row + 1), ' строке ', (Col + 1), ' столбце элемент[', MIN, '; ', MAX,  ']: ');
        Try
            Readln(Num);
            IsCorrect := True;
        Except
            Writeln('Проверьте корректность ввода данных!');
            IsCorrect := False;
        End;
        If IsCorrect Then
            IsCorrect := CheckUserArea(Num, MIN, MAX);
    Until IsCorrect;
    ReadUserMatrix := Num;
End;




Function ReadPathToFile() : String;
Var
    IsCorrect: Boolean;
    PathToFile: String;
Begin
    Repeat
        Write('Введите путь к файлу с расширением .txt с матрицей, у которой разряд не должен превышать ', MAX_O, ', а её элементы должны лежать в пределе[', MIN_MAT, ': ', MAX_MAT,']: ');
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
    If FileExists(PathToFile) Then
        IsCorrect := True
    Else
        IsCorrect := False;
    IsExists := IsCorrect;
End;






Function IsAbleToReading(Var F: TextFile) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    Try
        Reset(F);
        CloseFile(F);
        IsCorrect := True;
    Except
        IsCorrect := False;
    End;
    IsAbleToReading := IsCorrect;
End;





Function IsAbleToWriting(PathToFile: String) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    If FileIsReadOnly(PathToFile) Then
        IsCorrect := False
    Else
        IsCorrect := True;
    IsAbleToWriting := IsCorrect
End;





Function IsEmpty(Var F: TextFile) : Boolean;
Var
    Buf: Char;
    Size: Integer;
    IsCorrect: Boolean;
Begin
    Reset(F);
    Size := 0;
    If Not EOF(F) Then
        Size := 1;
    CloseFile(F);
    If Size = 0 Then
        IsCorrect := True
    Else
        IsCorrect := False;
    IsEmpty := IsCorrect;
End;





Function ReadOrder(Var F: TextFile) : Integer;
Var
    Buf: Char;
    IsCorrect: Boolean;
    Order: Integer;
Begin
    IsCorrect := True;
    Reset(F);
    Try
        Read(F, Order);
    Except
        Writeln('Неправильный порядок матрицы!');
        IsCorrect := False;
    End;
    If IsCorrect Then
    Begin
        IsCorrect := CheckUserArea(Order, MIN_O, MAX_O);
    End;
    If IsCorrect Then
    Begin
        Readln(F, Buf);
        If Buf <> #13 Then
        Begin
            IsCorrect := False;
            Writeln('Неправильный порядок матрицы!');
        End;
    End;
    CloseFile(F);
    If Not IsCorrect Then
        Order := -1;
    ReadOrder := Order;
End;





Function IsRightNums(Var F: TextFile) : Boolean;
Var
    K: Integer;
    IsCorrect: Boolean;
Begin
    IsCorrect := True;
    Reset(F);
    Readln(F);
    While IsCorrect And Not EOF(F) Do
    Begin
        While IsCorrect And Not EOLN(F) Do
        Begin
            Try
                Read(F, K);
            Except
                IsCorrect := False;
                WriteLn('Некорректный тип данных внутри файла!');
            End;
            If IsCorrect Then
                IsCorrect := CheckUserArea(K, MIN_MAT, MAX_MAT);
        End;
        ReadLn(F);
    End;
    CloseFile(F);
    IsRightNums := IsCorrect;
End;




Function IsOrdersEqual(Var F: TextFile; Order: Integer) : Boolean;
Var
    Rows, Cols, K: Integer;
    IsCorrect: Boolean;
Begin
    Rows := 0;
    Reset(F);
    Readln(F);
    IsCorrect := True;
    While IsCorrect And Not EOF(F) Do
    Begin
      Cols := 0;
      While IsCorrect And Not EOLN(F) Do
      Begin
          Read(F, K);
          Inc(Cols);
          IsCorrect := CheckUserArea(Cols, MIN_O, MAX_O);
      End;
      If IsCorrect Then
      Begin
          Readln(F);
          Inc(Rows);
          CheckUserArea(Rows, MIN_O, MAX_O);
          If Cols <> Order Then
              IsCorrect := False;
      End;
    End;
    CloseFile(F);
    If IsCorrect And (Not Rows = Order) Then
        IsCorrect := False;
    IsOrdersEqual := IsCorrect;
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
    ReadFileMatrix := Matrix;
End;






Function ReadFile(Var F: TextFile) : TMatrix;
Var
    IsCorrect: Boolean;
    PathToFile: String;
    Order: Integer;
    Matrix: TMatrix;
Begin
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
        If IsCorrect And Not IsAbleToWriting(PathToFile) Then
        Begin
            IsCorrect := False;
            WriteLn('Файл закрыт для записи!');
        End;
        If IsCorrect And IsEmpty(F) Then
        Begin
            IsCorrect := False;
            WriteLn('Файл пуст!');
        End;
        If IsCorrect Then
        Begin
            Order := ReadOrder(F);
            If Order = -1 Then
                IsCorrect := False;
        End;
        If IsCorrect And Not IsRightNums(F) Then
            IsCorrect := False;
        If IsCorrect And Not IsOrdersEqual(F, Order) Then
        Begin
            IsCorrect := False;
            Writeln('Значения порядков не равны!');
        End;
    Until IsCorrect;
    Matrix := ReadFileMatrix(F, Order);
    ReadFile := Matrix;
End;




Procedure AddAnswerToFile(Var F: TextFile; CountCorrectRows: Integer);
Begin
    Append(F);
    WriteLn(F);
    WriteLn(F, 'Количество строк, имеющих перестановки элементов от 1 до порядка матрицы: ', CountCorrectRows);
    CloseFile(F);
End;





Function ReadConsole() : TMatrix;
Var
    Row, Col, Order: Integer;
    Matrix: TMatrix;
Begin
    Order := ReadUserN(Order, MIN_O, MAX_O);
    SetLength(Matrix, Order, Order);
    For Row := Low(Matrix) To High(Matrix) Do
        For Col := Low(Matrix) To High(Matrix) Do
            Matrix[Row][Col] := ReadUserMatrix(Matrix[Row][Col], Row, Col, MIN_MAT, MAX_MAT);
    ReadConsole := Matrix;
End;





Function Sort(Matrix: TMatrix) : TMatrix;
Var
    Row, I, J, PreviousMaxIndex, Buf: Integer;
Begin
    PreviousMaxIndex := High(Matrix) - 1;
    For Row := Low(Matrix) To High(Matrix) Do
        For I := Low(Matrix) To High(Matrix) Do
            For J := Low(Matrix) To PreviousMaxIndex - I Do
                If Matrix[Row][J] > Matrix[Row][J + 1] Then
                Begin
                    Buf := Matrix[Row][J];
                    Matrix[Row][J] := Matrix[Row][J + 1];
                    Matrix[Row][J + 1] := Buf;
                End;
    Sort := Matrix;
End;





Function CalcCorrectRows(Matrix: TMatrix) : Integer;
Var
    Count, I, Row: Integer;
    IsCorrect: Boolean;
Begin
    Count := 0;
    For Row := Low(Matrix) To High(Matrix) Do
    Begin
        IsCorrect := True;
        I := 0;
        While (IsCorrect) And (I <= High(Matrix)) Do
        Begin
            If (Matrix[Row][I] <> I + 1) Then
                IsCorrect := False;
            Inc(I);
        End;
        If IsCorrect Then
            Inc(Count);
    End;
    CalcCorrectRows := Count;
End;






Procedure FreeMemory(Matrix: TMatrix);
Begin
    Matrix := Nil;
End;




Function GetResultFromFile() : Integer;
Var
    F: TextFile;
    Matrix: TMatrix;
    CountCorrectRows: Integer;
Begin
    Matrix := ReadFile(F);
    Matrix := Sort(Matrix);
    CountCorrectRows := CalcCorrectRows(Matrix);
    FreeMemory(Matrix);
    AddAnswerToFile(F, CountCorrectRows);
    GetResultFromFile := CountCorrectRows;
End;





Function GetResultFromConsole() : Integer;
Var
    Matrix: TMatrix;
    CountCorrectRows: Integer;
Begin
    Matrix := ReadConsole();
    Matrix := Sort(Matrix);
    CountCorrectRows := CalcCorrectRows(Matrix);
    FreeMemory(Matrix);
    GetResultFromConsole := CountCorrectRows;
End;





Procedure PrintResult(Count: Integer);
Begin
    WriteLn;
    WriteLn('Количество строк, имеющих перестановки элементов от 1 до N: ', Count);
End;





Var
    CountCorrectRows: Integer;
Begin
    OutputTask();
    If ChooseInputMethod() Then
        CountCorrectRows := GetResultFromFile()
    Else
        CountCorrectRows := GetResultFromConsole();
    PrintResult(CountCorrectRows);
    Readln;
End.
