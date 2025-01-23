Program Lab2_3;
Uses
    System.SysUtils;

Type
    TMatrix = Array [1..30, 1..10] Of Integer;
    TGoodMen = Array [1..30] of Integer;
Const
    MIN_MARK = 0;
    MAX_MARK = 10;
    FIRST_STUDENT = 1;
    LAST_STUDENT = 30;
    LAST_COLUMN = 10;
    FIRST_COLUMN = 1;

Procedure PrintTask();
Begin
    WriteLn('������ ��������� ������� ������ ���������� �� �������.');
    WriteLn;
End;

Function ChooseFileInput(): Boolean;
Var
    IsFileInput: Integer;
    IsCorrect, Choose: Boolean;
Begin
    IsFileInput := 0;
    IsCorrect := False;
    Choose := False;
    Repeat
        WriteLn('�� ������ ������� ������� ����� ����? (�� - ', 1, ' / ��� - ', 0, ')');
        Try
            ReadLn(IsFileInput);
            IsCorrect := True;
        Except
            WriteLn('������������ �����!');
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
                WriteLn('������������ �����!');
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
        Writeln('�������� �� �������� � ��������!');
        IsCorrect := False;
    End;
    CheckArea := IsCorrect;
End;

//�������� �� ���� � �����
Function ReadPathToFile() : String;
Var
    PathToFile: String;
    IsCorrect: Boolean;
Begin
    PathToFile := '';
    IsCorrect := False;
    Repeat
        Write('������� ���� � ����� � ����������� .txt � ��������, � ������� ����� ������ ��������������� �������[', MIN_MARK, ':', MAX_MARK,']: ');

        ReadLn(PathToFile);
        If ExtractFileExt(PathToFile) = '.txt' Then
            IsCorrect := True
        Else
        Begin
            WriteLn('���������� ����� �� .txt!');
            IsCorrect := False;
        End;
    Until IsCorrect;
    ReadPathToFile := PathToFile;
End;

//���������� �� ����
Function IsExists(PathToFile: String) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    If FileExists(PathToFile) Then
        IsCorrect := True;
    IsExists := IsCorrect;
End;

//����� �� ���������� ����
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

//����� �� �������� � ����
Function IsAbleToWriting(PathToFile: String) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := True;
    If FileIsReadOnly(PathToFile) Then
        IsCorrect := False;
    IsAbleToWriting := IsCorrect;
End;

//������ �� ����
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
    Mark: Integer;
    IsCorrect: Boolean;
Begin
    Mark := 0;
    IsCorrect := True;
    Reset(F);
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
                IsCorrect := CheckArea(Mark, MIN_MARK, MAX_MARK);
        End;
        ReadLn(F);
    End;
    CloseFile(F);
    IsRightFileNums := IsCorrect;
End;

//�������� �� ������
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
            Writeln('��������� ������������ ����� ���� � �����!');
        End;
        If IsCorrect And Not IsAbleToReading(F) Then
        Begin
            IsCorrect := False;
            Writeln('���� ������ ��� ������!');
        End;
        If IsCorrect And IsEmpty(F) Then
        Begin
            IsCorrect := False;
            WriteLn('���� ����!');
        End;
        If IsCorrect And Not IsRightFileNums(F) Then
        Begin
            IsCorrect := False;
            WriteLn('������������ ��� ������ ������ �����!');
        End;
    Until IsCorrect;
End;

//�������� �� ���� � ����
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
            Writeln('��������� ������������ ����� ���� � �����!');
        End;
        If IsCorrect And Not IsAbleToWriting(PathToFile) Then
        Begin
            IsCorrect := False;
            WriteLn('���� ������ ��� ������!');
        End;
    Until IsCorrect;
End;

//������ ������� �� �����
Function ReadFileMatrix(Var F: TextFile) : TMatrix;
Var
    Matrix: TMatrix;
    Row, Col: Integer;
Begin
    Reset(F);
    Readln(F);
    For Row := FIRST_STUDENT To LAST_STUDENT Do
    Begin
        For Col := FIRST_COLUMN To LAST_COLUMN Do
            Read(F, Matrix[Row][Col]);
        Readln(F);
    End;
    CloseFile(F);
    ReadFileMatrix := Matrix
End;

// ������ ������� �� �������
Function ReadConsoleMatrix() : TMatrix;
Var
    Matrix: TMatrix;
    Row, Col: Integer;
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    For Row := FIRST_STUDENT To LAST_STUDENT Do
        For Col := FIRST_COLUMN To LAST_COLUMN Do
            Begin
                Repeat
                    Write('������� ������ ', (Row), ' �������� �� ', (Col), ' ����:');
                    Try
                        Readln(Matrix[Row][Col]);
                        IsCorrect := True;
                    Except
                        Writeln('��������� ������������ ����� ������!');
                        IsCorrect := False;
                    End;
                    If IsCorrect Then
                        IsCorrect := CheckArea(Matrix[Row][Col], MIN_MARK, MAX_MARK);
                Until IsCorrect;
            End;
    ReadConsoleMatrix := Matrix;
End;

Procedure ReadMatrix(Var Matrix: TMatrix);
Var
    RF: TextFile;
Begin
    If ChooseFileInput() Then
    Begin
        GetFileNormalReading(RF);
        Matrix := ReadFileMatrix(RF);
    End
    Else
        Matrix := ReadConsoleMatrix();
End;

Function FindGoodMen (Var Matrix: TMatrix; Var GoodMen: TGoodMen): TGoodMen;
Var
    GoodMarks: Boolean;
    Row, Col: Integer;
Begin
    Row := 0;
    Col := 0;
    GoodMarks := True;
    For Row := FIRST_STUDENT To LAST_STUDENT Do
    Begin
        For Col := FIRST_COLUMN To LAST_COLUMN Do
        Begin
            If Matrix[Row][Col] < 9 Then
                GoodMarks := False;
        End;
        If GoodMarks Then
            GoodMen[Row] := Row + 1;
        GoodMarks := True;
    End;
    FindGoodMen := GoodMen;
End;

Function ChooseFileOutput() : Boolean;
Var
    IsFileOutput: Integer;
    IsCorrect, Choose: Boolean;
Begin
    IsFileOutput := 0;
    IsCorrect := False;
    Choose := False;
    Repeat
        WriteLn('�� ������ �������� ������� ����� ����? (�� - ', 1, ' / ��� - ', 0, ')');
        Try
            ReadLn(IsFileOutput);
            IsCorrect := True;
        Except
            WriteLn('������������ �����!');
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
                WriteLn('������������ �����!');
                IsCorrect := False;
            End;
        End;
    Until IsCorrect;
    ChooseFileOutput := Choose;
End;

Procedure PrintConsoleResult(GoodMen: TGoodMen);
Var
    Row: Integer;
Begin
    Row := 0;
    WriteLn('������ ����������:');

    For Row := FIRST_STUDENT To LAST_STUDENT Do
    Begin
        If GoodMen[Row] > 0  Then
            Write(GoodMen[Row], ' ');
    End;
End;

Procedure PrintFileResult(Var F: TextFile; GoodMen: TGoodMen);
Var
    Row: Integer;
Begin
    Append(F);
    Row := 0;
    WriteLn(F, '������ ����������:');
    For Row := FIRST_STUDENT To LAST_STUDENT Do
    Begin
        If GoodMen[Row] > 0  Then
            Write(F, GoodMen[Row], ' ');
    End;
    CloseFile(F);
End;

Procedure PrintResult(Var GoodMen: TGoodMen);
Var
    WF: TextFile;
Begin
    If ChooseFileOutput() Then
    Begin
        GetFileNormalWriting(WF);
        PrintFileResult(WF, GoodMen);
    End
    Else
        PrintConsoleResult(GoodMen);
End;

Var
    Matrix: TMatrix;
    GoodMen: TGoodMen;

Begin
    PrintTask();
    ReadMatrix(Matrix);
    FindGoodMen(Matrix, GoodMen);

    PrintResult(GoodMen);
    ReadLn;
End.

