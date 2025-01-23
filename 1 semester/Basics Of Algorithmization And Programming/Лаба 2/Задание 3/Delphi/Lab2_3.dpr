Program Lab2_3;
uses
  System.SysUtils;

Type
    MarkMatrix =  Array [1..30, 1..10] Of Integer;
Const

    MIN_MARK = 0;
    MAX_MARK = 10;
    FirstStudent = 1;
    LastStudent = 30;
    LastColumn = 10;
    FirstColumn = 1;


// ����� �������
Procedure OutputTask();
Begin
    Writeln('������ ��������� ���������� ������ ���������� � ������ ��������.' + #13#10);
End;


// ������ �������� �������
Function ChooseInputMethod() : Boolean;
Var
    IsFileInput: Integer;
    IsCorrect, IsFileChosen: Boolean;
Begin
    IsFileInput := 0;
    IsCorrect := True;
    IsFileChosen := False;
    While IsCorrect Do
    Begin
        WriteLn('�� ������ ������� ������� ����� ����? (�� - ', 1, ' / ��� - ', 0, ')');
        Try
            ReadLn(IsFileInput);
            IsCorrect := False;
        Except
            WriteLn('������������ �����!');
        End;

        If Not IsCorrect Then
        Begin
            If IsFileInput = 1 Then
            Begin
                IsCorrect := False;
                IsFileChosen := True;
            End
            Else If IsFileInput = 0 Then
            Begin
                IsCorrect := False;
                IsFileChosen := False;
            End
            Else
            Begin
                IsCorrect := True;
                WriteLn('������������ �����!');
            End;
        End;
    End;
    ChooseInputMethod := IsFileChosen;
End;



// �������� ������ �� ��������

Function CheckMark(Mark: Integer): Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := True;
    If (Mark < MIN_MARK) Or (Mark > MAX_MARK) Then
    Begin
        Writeln('�������� �� �������� � ��������!');
        IsCorrect := False;
    End
    Else
        IsCorrect := True;
    CheckMark := IsCorrect;
End;


//������ ��� Matrix
Function ReadUserMarkMatrix(Row, Col: Integer): Integer;
Var
    IsCorrect: Boolean;
    IsMarkCorrect: Boolean;
    Matrix: MarkMatrix;

Begin
    Repeat
        Begin
            IsCorrect := True;
            Write('������� ������ ', (Row), ' �������� �� ', (Col), ' ����: ');
            Try
                Readln(Matrix[Row][Col]);
            Except
                Writeln('��������� ������������ ����� ������!');
                IsCorrect := False;
            End;
            IsMarkCorrect := CheckMark(Matrix[Row][Col]);
            If IsCorrect Then
            Begin
                If Not IsMarkCorrect Then
                Begin
                    Writeln('�������� �� ������� � ��������!');
                    IsCorrect := False;
                End;
            End;
        End;
    Until (IsCorrect);
    ReadUserMarkMatrix := Matrix[Row][Col];
End;




//������ ������� �� �������
Function ReadConsoleMatrix(Order: Integer) : MarkMatrix;
Var
    Matrix: MarkMatrix;
    Row, Col: Integer;
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    Row := 1;
    Col := 1;
    For Row := FirstStudent To LastStudent Do
        For Col := FirstColumn To LastColumn Do
            Matrix[Row][Col] := ReadUserMarkMatrix(Row, Col);
    ReadConsoleMatrix := Matrix;
End;




// �������� �����
// �� ����������
Function ReadPathFile(): String;
Var
    PathToFile: String;
    IsInCorrect: Boolean;
Begin
    PathToFile := '';
    IsInCorrect := True;
    While IsInCorrect Do
    Begin
        Write('������� ���� � ����� � ����������� .txt � ��������, � ������� �������� ������ ������ � �������[', MIN_MARK, ': ', MAX_MARK,']: ');
        ReadLn(PathToFile);
        If ExtractFileExt(PathToFile) = '.txt' Then
            IsIncorrect := False
        Else
            WriteLn('���������� ����� �� .txt!');
            IsInCorrect := True;
    End;
    ReadPathFile := PathToFile;
End;




// �� ����

Function IsFileExists(PathToFile: String): Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    If FileExists(PathToFile) Then
        IsCorrect := True;
    IsFileExists := IsCorrect;
End;


// ������ �� ��� ������
Function IsAbleForReading(Var F: TextFile): Boolean;
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
    IsAbleForReading := IsCorrect;
End;



// ������ �� ��� ������
Function IsAbleForWriting(PathToFile: String): Boolean;
Var
    IsCorrect: Boolean;

Begin
    IsCorrect := False;
    If FileIsReadOnly(PathToFile) Then
        IsCorrect := False;
    IsAbleForWriting := IsCorrect;
End;



// �������� ������ �� ����
Function IsFileEmpty(Var F: TextFile): Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    Reset(F);
    If Not EOF(F) Then
        IsCorrect := True;
    CloseFile(F);
    IsFileEmpty := IsCorrect;
End;





//�������� �� ������ ����� ������ � �����
Function IsRightFileNums(Var F: TextFile) : Boolean;
Var
    Buf: Char;
    Mark: Integer;
    IsCorrect: Boolean;
Begin
    Buf := ' ';
    Mark := 0;
    IsCorrect := True;
    Reset(F);
    Try
        Read(F, Mark);
    Except
        IsCorrect := False;
    End;
    ReadLn(F, Buf);
    If Buf <> #13 Then
        IsCorrect := False;
    If IsCorrect Then
        IsCorrect := CheckMark(Mark);
    While IsCorrect And Not EOF(F) Do
    Begin
        While IsCorrect And Not EOLN(F) Do
        Begin
            Try
                Read(F, Mark);
            Except
                IsCorrect := False;
            End;
            If IsCorrect Then
                IsCorrect := CheckMark(Mark);
        End;
        ReadLn(F);
    End;
    CloseFile(F);
    IsRightFileNums := IsCorrect;
End;














Function CheckAreaOfOrder(Num: Integer; Const MIN, MAX: Integer) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := True;
    If (Num < MIN) Or (Num > MAX) Then
    Begin
        Writeln('�������� �� �������� � ��������!');
        IsCorrect := False;
    End;
    CheckAreaOfOrder := IsCorrect;
End;


//



//�������� ������� �������
Function IsOrdersEqual(Var F: TextFile) : Boolean;
Var
    Students, Row, Columns, Col: Integer;
    IsCorrect: Boolean;
Begin
    Students := 1;
    Row := 1;
    Col := 1;
    Columns := 1;
    IsCorrect := True;
    Reset(F);
    Readln(F, Students);
    While IsCorrect And Not EOF(F) Do
    Begin
      Col := 1;
      While IsCorrect And Not EOLN(F) Do
      Begin
          Read(F, Columns);
          Inc(Col);
          IsCorrect := CheckAreaOfOrder(Col, FirstColumn, LastColumn);
      End;
      If IsCorrect Then
      Begin
          Readln(F);
          Inc(Row);
          IsCorrect := CheckAreaOfOrder(Row, FirstStudent, LastStudent);
          If Col <> Columns Then
              IsCorrect := False;
      End;
    End;
    CloseFile(F);
    If IsCorrect And (Not Row = Students) Then
        IsCorrect := False;
    IsOrdersEqual := IsCorrect;
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
            Writeln('��������� ������������ ����� ���� � �����!');
        End;
        If IsCorrect And Not IsAbleToReading(F) Then
        Begin
            IsCorrect := False;
            Writeln('���� ������ ��� ������!');
        End;
        If IsCorrect And Not IsAbleToWriting(PathToFile) Then
        Begin
            IsCorrect := False;
            WriteLn('���� ������ ��� ������!');
        End;
        If IsCorrect And IsEmpty(F) Then
        Begin
            IsCorrect := False;
            WriteLn('���� ����!');
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
            Writeln('�������� �������� �� �����!');
        End;
    Until IsCorrect;
    Matrix := ReadFileMatrix(F, Order);
    ReadFile := Matrix;
End;



//���������� ������ � ����
Procedure AddAnswerToFile(Var F: TextFile; CountCorrectRows: Integer);
Begin
    Append(F);
    WriteLn(F);
    WriteLn(F, '���������� �����, ������� ������������ ��������� �� 1 �� ������� �������: ',
            CountCorrectRows);
    CloseFile(F);
End;




// ��������� ��������
Procedure CompareOrder(Var F: TextFile; Var IsIncorrect: Boolean; Var FirstN: Integer; Var Matrix: MarkMatrix);
Var
    RowN, ColN, K: Integer;
Begin
    RowN := 0;
    If Not IsIncorrect Then
    Begin
        Reset(F);
        Readln(F);
        While (Not IsIncorrect) And (Not EOF(F)) Do
        Begin
            ColN := 0;
            While (Not IsIncorrect) And (Not EOLN(F)) Do
            Begin
                Try
                    Read(F, K);
                Except
                    IsIncorrect := True;
                    WriteLn('������������ ��� ������ ������ �����!');
                End;
                If Not IsIncorrect Then
                Begin
                    Inc(ColN);
                    CheckUserArea(ColN, MIN_N, MAX_N, IsIncorrect);
                End;
            End;
            If Not IsIncorrect Then
            Begin
                Readln(F);
                Inc(RowN);
                CheckUserArea(RowN, MIN_N, MAX_N, IsIncorrect);
                If ColN <> FirstN Then
                Begin
                    Writeln('�������� �������� �� �����!');
                    IsIncorrect := True;
                End;
            End;
        End;
        CloseFile(F);
        If Not IsIncorrect Then
        Begin
            If RowN = FirstN Then
                SetLength(Matrix, FirstN, FirstN)
            Else
            Begin
                Writeln('�������� �������� �� �����!');
                IsIncorrect := True;
            End;
        End;
    End;
End;




// ������ ����� ������� �� �����
Procedure ReadUserNumOfFile(Var F: TextFile; Var IsIncorrect: Boolean; Var FirstN: Integer; Var Matrix: MarkMatrix);
Var
    Row, Col: Integer;
Begin
    Row := 0;
    Col := 0;
    If Not IsIncorrect Then
    Begin
        Reset(F);
        Readln(F);
        While (Not IsIncorrect) And (Row < FirstN) Do
        Begin
            While (Not IsIncorrect) And (Col < FirstN) Do
            Begin
                Read(F, Matrix[Row][Col]);
                CheckUserArea(Matrix[Row][Col], MIN_MAT, MAX_MAT, IsIncorrect);
                Inc(Col);
            End;
            Readln(F);
            Col := 0;
            Inc(Row);
        End;
        CloseFile(F);
    End;
End;



// �������� � ������ �����������
Procedure CheckMatrixOfFile(Var F: TextFile; Var IsIncorrect: Boolean; Var Matrix: TMatrix);
Var
    FirstN: Integer;
Begin
    CheckOrder(F, IsIncorrect, FirstN);
    CompareOrder(F, IsIncorrect, FirstN, Matrix);
    ReadUserNumOfFile(F, IsIncorrect, FirstN, Matrix);
End;


// ���� ������� �� �����
Procedure ReadFile(Var F: TextFile; PathToFile: String; Var Matrix: MarkMatrix);
Var
    IsIncorrect: Boolean;
Begin
    IsIncorrect := True;
    While IsIncorrect Do
    Begin
        PathToFile := CheckFile(F, IsIncorrect, PathToFile);
        CheckMatrixOfFile(F, IsIncorrect, Matrix);
    End;
End;

//����� �� ���������� � ����
Procedure GetFileWriting(Var F: TextFile);
Var
    PathToFile: String;
    IsCorrect: Boolean;
Begin
    PathToFile := '';
    IsCorrect := True;
    Repeat
        PathToFile := ReadPathFile();
        AssignFile(F, PathToFile);
        If Not IsFileExists(PathToFile) Then
        Begin
            IsCorrect := False;
            Writeln('��������� ������������ ����� ���� � �����!');
        End;
        If IsCorrect And Not IsAbleForWriting(PathToFile) Then
        Begin
            IsCorrect := False;
            WriteLn('���� ������ ��� ������!');
        End;
    Until IsCorrect;
End;

//����� �� ��������� �� �����
Procedure GetFileReading(Var F: TextFile);
Var
    PathToFile: String;
    IsCorrect: Boolean;
Begin
    PathToFile := '';
    IsCorrect := True;
    Repeat
        PathToFile := ReadPathFile();
        AssignFile(F, PathToFile);
        If Not IsFileExists(PathToFile) Then
        Begin
            IsCorrect := False;
            Writeln('��������� ������������ ����� ���� � �����!');
        End;
        If IsCorrect And Not IsAbleForReading(F) Then
        Begin
            IsCorrect := False;
            Writeln('���� ������ ��� ������!');
        End;
        If IsCorrect And IsFileEmpty(F) Then
        Begin
            IsCorrect := False;
            WriteLn('���� ����!');
        End;
        If IsCorrect And Not IsRightFileNums(F) Then
        Begin
            IsCorrect := False;
            WriteLn('������������ ��� ������ ������ �����!');
        End;
        If IsCorrect And Not IsOrdersEqual(F) Then
        Begin
            IsCorrect := False;
            Writeln('�������� �������� �� �����!');
        End;
    Until IsCorrect;
End;



















// ������
// ��� �����
Procedure GetResultFromFile(Var CountCorrectRows: Integer; Matrix: TMatrix);
Var
    PathToFile: String;
    F: TextFile;
Begin
    ReadFile(F, PathToFile, Matrix);
    Sort(Matrix);
    CountCorrectRows := CalcCorrectRows(Matrix);
    AddAnswerToFile(F, CountCorrectRows);
End;




// ��� �����
Procedure GetResultFromConsole(Var CountCorrectRows: Integer; Matrix: TMatrix);
Begin
    ReadConsole(Matrix);
    Sort(Matrix);
    CountCorrectRows := CalcCorrectRows(Matrix);
End;



// ����� ����������
Procedure PrintResult(Count: Integer);
Begin
    WriteLn;
    WriteLn('���������� �����, ������� ������������ ��������� �� 1 �� N: ', Count);
End;



// �������
Var
    Matrix: MarkMatrix;
    CountCorrectRows: Integer;
Begin
    OutputTask();
    If ChooseInputMethod() Then

        GetResultFromFile(CountCorrectRows, Matrix)

    Else

        GetResultFromConsole(CountCorrectRows, Matrix);

    PrintResult(CountCorrectRows);
    Readln;
End.
