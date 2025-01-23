Unit MainForm;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Clipbrd,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
    Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.Grids;

Type
    TEStringGrid = Class(TStringGrid);
    TMatrix = Array Of Array Of Integer;
    ERRORS_LIST = (CORRECT, RANGE_ERR, NUM_ERR, NOT_READABLE, NOT_WRITEABLE,
      FILE_EMPTY, LINE_ERR, ORDER_ERR);

    TMainTaskForm = Class(TForm)
        MainFormMenu: TMainMenu;
        FileMenu: TMenuItem;
        InstructionMenu: TMenuItem;
        DeveloperMenu: TMenuItem;
        OpenMenu: TMenuItem;
        SaveMenu: TMenuItem;
        N1: TMenuItem;
        QuitMenu: TMenuItem;
        TaskLabel: TLabel;
        ResultButton: TButton;
        OpenFile: TOpenDialog;
        EnterMEdit: TEdit;
        EnterNLabel: TLabel;
        ArrLabel: TLabel;
        SaveTextFile: TSaveTextFileDialog;
        StringGrid: TStringGrid;
        OutLabel: TLabel;
        EnterNEdit: TEdit;
        I1Edit: TEdit;
        J1Edit: TEdit;
        I2Edit: TEdit;
        J2Edit: TEdit;
        StartLabel: TLabel;
        EndLabel: TLabel;
        OutEdit: TEdit;
        Procedure DeveloperMenuClick(Sender: TObject);
        Procedure InstructionMenuClick(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure EnterMEditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure IsEnterEditsEmpty(EditM, EditN: TEdit);

        Procedure GetDataFromFile(Var F: TextFile; Sender: TObject);
        Function FileReading(Var F: TextFile): ERRORS_LIST;
        Procedure ResultButtonClick(Sender: TObject);

        Procedure EnterMEditChange(Sender: TObject);
        Procedure QuitMenuClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);

        Procedure EnterMEditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);

        Procedure EnterMEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure EnterMEditClick(Sender: TObject);

        Procedure SaveMenuClick(Sender: TObject);
        Procedure OpenMenuClick(Sender: TObject);

        Procedure StringGridKeyPress(Sender: TObject; Var Key: Char);
        Procedure StringGridKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);

        Procedure StringGridSetEditText(Sender: TObject; ACol, ARow: Integer;
          Const Value: String);
        Procedure StringGridMouseActivate(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y, HitTest: Integer;
          Var MouseActivate: TMouseActivate);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure EnterNEditChange(Sender: TObject);
        Procedure EnterNEditClick(Sender: TObject);
        Procedure EnterNEditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure EnterNEditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure EnterNEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure J1EditChange(Sender: TObject);
        Procedure I1EditChange(Sender: TObject);
        Procedure I2EditChange(Sender: TObject);
        Procedure J2EditChange(Sender: TObject);
        Procedure I1EditClick(Sender: TObject);
        Procedure J1EditClick(Sender: TObject);
        Procedure I2EditClick(Sender: TObject);
        Procedure J2EditClick(Sender: TObject);
        Procedure I1EditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure J1EditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure I2EditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure J2EditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure I1EditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure J1EditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure I2EditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure J2EditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure I1EditKeyPress(Sender: TObject; Var Key: Char);
        Procedure J1EditKeyPress(Sender: TObject; Var Key: Char);
        Procedure I2EditKeyPress(Sender: TObject; Var Key: Char);
        Procedure J2EditKeyPress(Sender: TObject; Var Key: Char);
        Procedure ButtonOn(I1, J1, I2, J2: TEdit);
        Procedure MainFunc();
        Procedure MakeUnVisibleAndClear(I1, J1, I2, J2: TEdit);
        Procedure MakeVisible(I1, J1, I2, J2: TEdit);

    Private

        { Private declarations }
    Public
        { Public declarations }
    End;

Const
    ERRORS: Array [ERRORS_LIST] Of String = ('',
      'Значение не попадает в диапазон!',
      'Проверьте корректность ввода данных!', 'Файл закрыт для чтения!',
      'Файл закрыт для записи!', 'Файл пуст!', 'Неверное число строк в файле',
      'Неверный порядок матрицы!');
    DIGITS = ['0' .. '9'];
    NO_ZERO_DIGITS = ['1' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_N = 2;
    MAX_N = 4;
    MIN_X = -99;
    MAX_X = 100;
    ALPHABET = ['A' .. 'Z', 'a' .. 'z'];

Var
    MainTaskForm: TMainTaskForm;

Implementation

{$R *.dfm}

Var
    Saved: Boolean = True;
    PerformCloseQuery: Boolean = True;
    CtrlPressed: Boolean = False;
    MaxSum: Integer = 0;
    Steps: TMatrix;
    Matrix: TMatrix;
    Path: String;
    PathLength: Integer;
    StepCounter: Integer = 0;

Procedure TMainTaskForm.DeveloperMenuClick(Sender: TObject);
Var
    DeveloperForm: TDeveloperForm;
Begin
    DeveloperForm := TDeveloperForm.Create(Self);
    DeveloperForm.ShowModal;
    DeveloperForm.Free;
End;

Procedure TMainTaskForm.FormCreate(Sender: TObject);
Begin
    MakeUnVisibleAndClear(I1Edit, J1Edit, I2Edit, J2Edit);
End;

Function TMainTaskForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    InstructionMenuClick(Self);
End;

Procedure TMainTaskForm.InstructionMenuClick(Sender: TObject);
Var
    InstructionForm: TInstructionForm;
Begin
    InstructionForm := TInstructionForm.Create(Self);
    InstructionForm.ShowModal;
    InstructionForm.Free;
End;

Function IsReadable(Var F: TextFile): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
Begin
    ERRORS := CORRECT;
    Try
        Try
            Reset(F);
        Finally
            CloseFile(F);
        End;
    Except
        ERRORS := NOT_READABLE;
    End;
    IsReadable := ERRORS;
End;

Procedure TMainTaskForm.EnterMEditContextPopup(Sender: TObject;
  MousePos: TPoint; Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure GiveZeroOrNone(Edit: TEdit);
Var
    Num: Double;
Begin
    If TryStrToFloat(Edit.Text, Num) And (Num = 0) Then
        Edit.Text := '0';
End;

Function IsCorrectRange(Value: Integer; Const MIN, MAX: Real): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
Begin
    ERRORS := CORRECT;

    If ((Value < MIN) Or (Value > MAX)) Then
    Begin
        ERRORS := RANGE_ERR;
    End;
    IsCorrectRange := ERRORS;
End;

Function CheckNumOfLines(Var F: TextFile; Const NUM_OF_LINES: Integer)
  : ERRORS_LIST;
Var
    I: Integer;
    Str: String;
    Error: ERRORS_LIST;
Begin
    I := 0;
    Str := '';
    Error := CORRECT;
    Reset(F);
    While Not EOF(F) Do
    Begin
        Readln(F, Str);
        Inc(I);
    End;
    CloseFile(F);
    If I <> NUM_OF_LINES Then
        Error := LINE_ERR;
    CheckNumOfLines := Error;
End;

Function CheckFileData(Var F: TextFile): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
    Value: Integer;
    Num, I, J, Cols, Rows: Integer;
    Str, StrNum, Mark: String;
    Numbers: TArray<String>;
Begin
    ERRORS := CORRECT;
    J := 0;
    I := 0;
    Rows := 0;
    Cols := 0;
    Str := ' ';
    Reset(F);

    While (ERRORS = CORRECT) And Not EOLN(F) Do
    Begin

        Try
            Read(F, Value);
        Except
            ERRORS := NUM_ERR;
        End;
        If ERRORS = CORRECT Then
            ERRORS := IsCorrectRange(Value, MIN_N, MAX_N);
    End;

    Cols := Value;
    Readln(F);

    While (ERRORS = CORRECT) And Not EOLN(F) Do
    Begin
        Try
            Read(F, Value);
        Except
            ERRORS := NUM_ERR;
        End;
        If ERRORS = CORRECT Then
            ERRORS := IsCorrectRange(Value, MIN_N, MAX_N);
    End;

    Rows := Value;
    Readln(F);
    If ERRORS = CORRECT Then
    Begin
        For I := 1 To 2 Do
        Begin
            ReadLn(F, StrNum);
            If TryStrToInt(StrNum, Value) Then
            Begin
                ERRORS := IsCorrectRange(Value, 1, Rows);
            End
            Else
                ERRORS := NUM_ERR;

        End;
        I := 0;
    End;
    If ERRORS = CORRECT Then
    Begin
        For I := 1 To 2 Do
        Begin
            Readln(F, StrNum);
            If TryStrToInt(StrNum, Value) Then
            Begin
                ERRORS := IsCorrectRange(Value, 1, Cols);
            End
            Else
                ERRORS := NUM_ERR;

        End;
        I := 0;
    End;

    Str := ' ';
    While (ERRORS = CORRECT) And Not EOF(F) And (Str <> '') Do
    Begin
        While (ERRORS = CORRECT) And Not EOLN(F) Do
        Begin
            ReadLn(F, StrNum);
            StrNum := Trim(StrNum);
            Numbers := StrNum.Split([' ']);
            For Mark In Numbers Do
            Begin
                If TryStrToInt(Mark, Value) Then
                Begin
                    ERRORS := IsCorrectRange(Value, MIN_X, MAX_X);
                End
                Else
                    ERRORS := NUM_ERR;
                Inc(I);
            End;
            If (I <> Cols) Then
                ERRORS := ORDER_ERR;
            I := 0;
            Inc(J);
        End;

        Read(F, Str);
    End;

    If ((I) <> Cols) And (ERRORS = CORRECT) And (J <> Rows) Then
        ERRORS := ORDER_ERR;

    CloseFile(F);
    CheckFileData := ERRORS;
End;

Procedure TMainTaskForm.GetDataFromFile(Var F: TextFile; Sender: TObject);
Var
    NumStr, Mark: String;
    Numbers: TArray<String>;
    Num, I, J: Integer;
Begin
    I := 0;
    J := 0;
    Reset(F);
    Readln(F, NumStr);
    EnterMEdit.Text := NumStr;
    Readln(F, NumStr);
    EnterNEdit.Text := NumStr;
    Readln(F, NumStr);
    I1Edit.Text := NumStr;
    Readln(F, NumStr);
    I2Edit.Text := NumStr;
    Readln(F, NumStr);
    J1Edit.Text := NumStr;
    Readln(F, NumStr);
    J2Edit.Text := NumStr;
    While Not EOF(F) Do
    Begin
        While Not EOLN(F) Do
        Begin
            Read(F, NumStr);
            NumStr := Trim(NumStr);
            Numbers := NumStr.Split([' ']);
            For Mark In Numbers Do
            Begin
                If TryStrToInt(Mark, Num) Then
                Begin
                    StringGrid.Cells[I, J] := IntToStr(Num);
                End;
                Inc(I);
            End;
        End;
        I := 0;
        Readln(F);
        Inc(J);
    End;

    CloseFile(F);
End;

Function TMainTaskForm.FileReading(Var F: TextFile): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
Begin
    ERRORS := CORRECT;
    Reset(F);
    If EOF(F) Then
        ERRORS := FILE_EMPTY;
    CloseFile(F);
    If (ERRORS = CORRECT) Then
        ERRORS := CheckFileData(F);
    If (ERRORS = CORRECT) Then
        GetDataFromFile(F, Self);
    If ERRORS = CORRECT Then
    Begin
        ResultButton.Enabled := True;
        MakeVisible(I1Edit, J1Edit, I2Edit, J2Edit);
    End;
    FileReading := ERRORS;
End;

Procedure TMainTaskForm.OpenMenuClick(Sender: TObject);
Var
    Error: ERRORS_LIST;
    F: TextFile;
    FileName: String;

Begin
    If OpenFile.Execute Then
    Begin
        FileName := OpenFile.FileName;
        AssignFile(F, FileName);
        Error := IsReadable(F);
        If Error = CORRECT Then
            Error := FileReading(F);
        If Error <> CORRECT Then
            Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка',
              MB_OK Or MB_ICONINFORMATION);
    End;
End;

Function FillArrayFromStringGrid(MatrixGrid: TStringGrid): TMatrix;
Var
    I: Integer;
    Matrix: TMatrix;
    J: Integer;
Begin
    SetLength(Matrix, MatrixGrid.RowCount, MatrixGrid.ColCount);

    For J := 0 To MatrixGrid.ColCount - 1 Do
    Begin
        For I := 0 To MatrixGrid.RowCount - 1 Do
        Begin
            Matrix[I, J] := StrtoInt(MatrixGrid.Cells[J, I]);
        End;
    End;
    Result := Matrix;
End;

Procedure FillGrid(OrderM, OrderN: Integer; Grid: TStringGrid);
Var
    I, J: Integer;
    NumArr: TMatrix;
Begin
    Grid.Width := (Grid.DefaultColWidth + 3) * OrderM;
    Grid.Height := (Grid.DefaultRowHeight + 4) * OrderN;
    Grid.Enabled := True;
    Grid.ColCount := OrderM;
    Grid.RowCount := OrderN;
End;

Procedure ClearGrid(Grid: TStringGrid);
Var
    J, I: Integer;
Begin
    For I := 0 To Grid.ColCount Do
        For J := 0 To Grid.RowCount Do
            Grid.Cells[I, J] := '';
    Grid.ColCount := 0;
    Grid.Enabled := False;
End;

Procedure TMainTaskForm.SaveMenuClick(Sender: TObject);
Var
    Error: ERRORS_LIST;
    F: TextFile;
    FileName: String;
    I, J: Integer;
Begin
    If SaveTextFile.Execute Then
    Begin
        FileName := SaveTextFile.FileName;
        FileName := ChangeFileExt(FileName, '.txt');
        AssignFile(F, FileName);
        If FileExists(FileName) Then
        Begin
            Error := IsReadable(F);
            If Error = CORRECT Then
            Begin
                Append(F);
                Write(F, OutEdit.Text);

                CloseFile(F);
                Saved := True;
            End;
            If Error <> CORRECT Then
            Begin
                Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка',
                  MB_OK Or MB_ICONINFORMATION);
                Saved := False;
            End;
        End
        Else
        Begin
            Rewrite(F);
            Write(F, OutEdit.Text);
            CloseFile(F);
            Saved := True;
        End;

    End;
End;

Procedure TMainTaskForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
    Confirmation: Integer;
Begin
    If PerformCloseQuery Then
    Begin
        If (Saved = False) Then
        Begin
            Confirmation := Application.MessageBox
              ('Вы не сохранили файл, хотите ли сохранить?', 'Выход',
              MB_YESNOCANCEl + MB_ICONQUESTION + MB_DEFBUTTON2);
            Case Confirmation Of
                MrYes:
                    Begin
                        SaveMenuClick(Sender);
                        If Saved = True Then
                            CanClose := True
                        Else
                            FormCloseQuery(Sender, CanClose);
                    End;
                MrNo:
                    CanClose := True;
                MrCancel:
                    CanClose := False;
            End;
        End
        Else
        Begin
            Confirmation := Application.MessageBox
              ('Вы действительно хотите выйти?', 'Выход',
              MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
            CanClose := Confirmation = IDYES;
        End;
    End;
End;

Procedure TMainTaskForm.QuitMenuClick(Sender: TObject);
Var
    Confirmation: Integer;
Begin
    PerformCloseQuery := False;
    If (Saved = False) Then
    Begin
        Confirmation := Application.MessageBox
          ('Вы не сохранили файл, хотите ли сохранить?', 'Выход',
          MB_YESNOCANCEl + MB_ICONQUESTION + MB_DEFBUTTON2);
        Case Confirmation Of
            MrYes:
                Begin
                    SaveMenuClick(Sender);
                    If Saved = True Then
                        Close
                    Else
                        QuitMenuClick(Sender);
                End;
            MrNo:
                Close;
        End;
    End
    Else
    Begin
        Confirmation := Application.MessageBox('Вы действительно хотите выйти?',
          'Выход', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
        If Confirmation = IDYES Then
            Close;
    End;
    PerformCloseQuery := True;
End;

Procedure CheckInput(Text: String; Var Key: Char; Const MIN, MAX: Real);

Var
    Value: Integer;
    ERRORS: ERRORS_LIST;
Begin
    Value := 0;
    ERRORS := CORRECT;
    If TryStrToInt(Text + Key, Value) Then
    Begin
        ERRORS := IsCorrectRange(Value, MIN, MAX);
        If ERRORS <> CORRECT Then
        Begin
            Key := #0;
        End;
    End;
End;

Function CreateZeroMatrix(StringGrid: TStringGrid): TMatrix;
Var
    I, J, HighI, HighJ: Integer;
    ZeroMatrix: TMatrix;
Begin
    HighI := StringGrid.RowCount;
    HighJ := StringGrid.ColCount;
    SetLength(ZeroMatrix, HighI, HighJ);
    For I := 0 To HighI - 1 Do
        For J := 0 To HighJ - 1 Do
            ZeroMatrix[I, J] := 0;
    CreateZeroMatrix := ZeroMatrix;
End;

Procedure FindMaxSumPath(M, N, I1, J1, I2, J2, CurrentSum: Integer;
  CurrentPath: String);
Begin
    If Not((I1 < 0) Or (I1 > M - 1) Or (J1 < 0) Or (J1 > N - 1) Or
      (Steps[I1, J1] >= 2)) Then
    Begin
        Inc(StepCounter);
        Inc(Steps[I1, J1]);
        Inc(CurrentSum, Matrix[I1, J1]);
        CurrentPath := CurrentPath + Format('(%d). [%d,%d]; ',
          [StepCounter, I1 + 1, J1 + 1]);
        
        If (I1 = I2) And (J1 = J2) Then
        Begin
            If CurrentSum > MaxSum Then
            Begin
                MaxSum := CurrentSum;
                Path := CurrentPath;
            End;
        End
        Else
        Begin
            FindMaxSumPath(M, N, I1, J1 + 1, I2, J2, CurrentSum, CurrentPath);
            FindMaxSumPath(M, N, I1 + 1, J1, I2, J2, CurrentSum, CurrentPath);
            FindMaxSumPath(M, N, I1, J1 - 1, I2, J2, CurrentSum, CurrentPath);
            FindMaxSumPath(M, N, I1 - 1, J1, I2, J2, CurrentSum, CurrentPath);
        End;
        Dec(Steps[I1, J1]);
        Dec(StepCounter);
        Delete(CurrentPath, Length(CurrentPath) - 6, 7);

    End;
End;

Procedure TMainTaskForm.MainFunc();
Var
    I1, J1, I2, J2: Integer;
Begin
    Matrix := FillArrayFromStringGrid(StringGrid);
    Steps := CreateZeroMatrix(StringGrid);
    I1 := StrtoInt(I1Edit.Text) - 1;
    J1 := StrtoInt(J1Edit.Text) - 1;
    I2 := StrtoInt(I2Edit.Text) - 1;
    J2 := StrtoInt(J2Edit.Text) - 1;
    FindMaxSumPath(StringGrid.RowCount, StringGrid.ColCount, I1, J1, I2, J2,
      MaxSum, Path);
    If Path <> '' Then
        OutEdit.Text := Path
    Else
        OutEdit.Text := 'Не удалось найти оптимальный путь';
    Path := '';

End;

Procedure CheckComboButtons(Var Key: Char; Edit: TEdit);
Begin
    If (Key = #22) Or ((Key = 'v') And (GetKeyState(VK_CONTROL) < 0)) Then
        Key := #0;
    If Not CharInSet(Key, DIGITS) And (Key <> #8) Then
        Key := #0;

End;

Procedure CheckShftAndArrows(Var Key: Word; Shift: TShiftState);
Begin
    If (Key = VK_INSERT) And (Shift = [SsShift]) Then
        Key := 0;
    If (Key = VK_LEFT) Or (Key = VK_UP) Then
        Key := 0
    Else If (Key = VK_RIGHT) Or (Key = VK_DOWN) Then
        Key := 0;
End;

Procedure TMainTaskForm.EnterMEditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TMainTaskForm.EnterMEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    CheckComboButtons(Key, EnterMEdit);
    CheckInput(EnterMEdit.Text, Key, MIN_N, MAX_N);
End;

Procedure TMainTaskForm.I1EditKeyPress(Sender: TObject; Var Key: Char);
Var
    MAX_N_EDIT: Integer;
Begin
    CheckComboButtons(Key, I1Edit);
    MAX_N_EDIT := StrtoInt(EnterNEdit.Text);
    CheckInput(I1Edit.Text, Key, 1, MAX_N_EDIT);
End;

Procedure TMainTaskForm.J1EditKeyPress(Sender: TObject; Var Key: Char);
Var
    MAX_M_EDIT: Integer;
Begin
    CheckComboButtons(Key, J1Edit);
    MAX_M_EDIT := StrtoInt(EnterMEdit.Text);
    CheckInput(J1Edit.Text, Key, 1, MAX_M_EDIT);

End;

Procedure TMainTaskForm.I2EditKeyPress(Sender: TObject; Var Key: Char);
Var
    MAX_N_EDIT: Integer;
Begin
    CheckComboButtons(Key, I2Edit);
    MAX_N_EDIT := StrtoInt(EnterNEdit.Text);
    CheckInput(I2Edit.Text, Key, 1, MAX_N_EDIT);
End;

Procedure TMainTaskForm.J2EditKeyPress(Sender: TObject; Var Key: Char);
Var
    MAX_M_EDIT: Integer;
Begin
    CheckComboButtons(Key, J2Edit);
    MAX_M_EDIT := StrtoInt(EnterMEdit.Text);
    CheckInput(J2Edit.Text, Key, 1, MAX_M_EDIT);

End;

Procedure TMainTaskForm.IsEnterEditsEmpty(EditM, EditN: TEdit);
Begin
    If (EditM.Text = '') Or (EditN.Text = '') Then
    Begin
        Saved := True;
        SaveMenu.Enabled := False;
        StringGrid.Visible := False;
        ArrLabel.Visible := False;
        ClearGrid(StringGrid);
        ResultButton.Enabled := False;
    End
    Else
    Begin
        StringGrid.Visible := True;
        ArrLabel.Visible := True;
        ClearGrid(StringGrid);
        FillGrid(StrtoInt(EditM.Text), StrtoInt(EditN.Text), StringGrid);
    End;
End;

Procedure TMainTaskForm.ButtonOn(I1, J1, I2, J2: TEdit);
Begin
    If (I1.Text = '') Or (J1.Text = '') Or (J2.Text = '') Or (I2.Text = '') Then
        ResultButton.Enabled := False
    Else
        ResultButton.Enabled := True;
End;

Procedure TMainTaskForm.MakeUnVisibleAndClear(I1, J1, I2, J2: TEdit);
Begin
    StartLabel.Visible := False;
    EndLabel.Visible := False;
    I1.Visible := False;
    J1.Visible := False;
    I2.Visible := False;
    J2.Visible := False;
    I1.Text := '';
    J1.Text := '';
    I2.Text := '';
    J2.Text := '';
End;

Procedure TMainTaskForm.MakeVisible(I1, J1, I2, J2: TEdit);
Begin
    StartLabel.Visible := True;
    EndLabel.Visible := True;
    I1.Visible := True;
    J1.Visible := True;
    I2.Visible := True;
    J2.Visible := True;
End;

Procedure TMainTaskForm.J1EditChange(Sender: TObject);
Begin
    ButtonOn(I1Edit, J1Edit, J2Edit, I2Edit);
End;

Procedure TMainTaskForm.J2EditChange(Sender: TObject);
Begin
    ButtonOn(I1Edit, J1Edit, J2Edit, I2Edit);
End;

Procedure TMainTaskForm.EnterNEditChange(Sender: TObject);
Begin
    IsEnterEditsEmpty(EnterMEdit, EnterNEdit);
    OutEdit.Text := '';
    MakeUnVisibleAndClear(I1Edit, J1Edit, I2Edit, J2Edit);
End;

Procedure TMainTaskForm.EnterMEditChange(Sender: TObject);
Begin
    IsEnterEditsEmpty(EnterMEdit, EnterNEdit);
    OutEdit.Text := '';
    MakeUnVisibleAndClear(I1Edit, J1Edit, I2Edit, J2Edit);
End;

Procedure TMainTaskForm.I1EditChange(Sender: TObject);
Begin
    ButtonOn(I1Edit, J1Edit, J2Edit, I2Edit);
End;

Procedure TMainTaskForm.I2EditChange(Sender: TObject);
Begin
    ButtonOn(I1Edit, J1Edit, J2Edit, I2Edit);
End;

Procedure BlockClick(Edit: TEdit);
Begin
    If Edit.SelStart <> Length(Edit.Text) Then
        Edit.SelStart := Length(Edit.Text);
End;

Procedure TMainTaskForm.J2EditClick(Sender: TObject);
Begin
    BlockClick(J2Edit)
End;

Procedure TMainTaskForm.J2EditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TMainTaskForm.J2EditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TMainTaskForm.J1EditClick(Sender: TObject);
Begin
    BlockClick(J1Edit)
End;

Procedure TMainTaskForm.J1EditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TMainTaskForm.J1EditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TMainTaskForm.EnterMEditClick(Sender: TObject);
Begin
    BlockClick(EnterNEdit);
End;

Procedure TMainTaskForm.I2EditClick(Sender: TObject);
Begin
    BlockClick(I2Edit)
End;

Procedure TMainTaskForm.I2EditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TMainTaskForm.I2EditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TMainTaskForm.EnterNEditClick(Sender: TObject);
Begin
    BlockClick(EnterNEdit);
End;

Procedure TMainTaskForm.I1EditClick(Sender: TObject);
Begin
    BlockClick(I1Edit)
End;

Procedure TMainTaskForm.I1EditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TMainTaskForm.I1EditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TMainTaskForm.EnterNEditContextPopup(Sender: TObject;
  MousePos: TPoint; Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TMainTaskForm.EnterNEditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TMainTaskForm.EnterNEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    CheckComboButtons(Key, EnterNEdit);
    CheckInput(EnterNEdit.Text, Key, MIN_N, MAX_N);
End;

Function IsGridFull(StringGrid: TStringGrid): Boolean;
Var
    I, J, EmptyCount: Integer;
Begin
    EmptyCount := 0;
    For I := 0 To StringGrid.ColCount - 1 Do
    Begin
        For J := 0 To StringGrid.RowCount - 1 Do
        Begin
            If (StringGrid.Cells[I, J] = '') Or
              (StringGrid.Cells[I, J] = '-') Then
                Inc(EmptyCount);
        End;
    End;
    Result := EmptyCount = 0;
End;

Procedure TMainTaskForm.ResultButtonClick(Sender: TObject);
Var
    ResMatrix: TMatrix;
Begin
    OutEdit.Text := '';
    MainFunc();
    Saved := False;
    SaveMenu.Enabled := True;

    If OutEdit.Text = '' Then
    Begin
        Saved := True;
        SaveMenu.Enabled := False;
    End
    Else
    Begin
        Saved := False;
        SaveMenu.Enabled := True;
    End;

End;

Procedure TMainTaskForm.StringGridSetEditText(Sender: TObject;
  ACol, ARow: Integer; Const Value: String);
Begin
    If IsGridFull(StringGrid) And (EnterNEdit.Text <> '') And
      (EnterMEdit.Text <> '') Then
    Begin
        MakeVisible(I1Edit, J1Edit, I2Edit, J2Edit);
    End
    Else
    Begin
        MakeUnVisibleAndClear(I1Edit, J1Edit, I2Edit, J2Edit);
        OutEdit.Text := '';
        Saved := True;
        SaveMenu.Enabled := False;
    End;
    OutEdit.Text := '';
    SaveMenu.Enabled := False;
End;

Procedure CheckComboButtonsGrid(Var Key: Char; StringGrid: TEStringGrid);
Begin

    If (Key = #22) Or ((Key = 'v') And (GetKeyState(VK_CONTROL) < 0)) Then
        Key := NONE;
    If Not CharInSet(Key, DIGITS) And (Key <> #8) And (Key <> '-') Then
        Key := NONE;
    If (Pos('-', StringGrid.Cells[StringGrid.Col, StringGrid.Row]) = 1) And
      (StringGrid.InplaceEditor.SelStart = 0) Then
        Key := NONE;
    If (Key = '0') And (Length(StringGrid.Cells[StringGrid.Col, StringGrid.Row])
      > 0) And (StringGrid.InplaceEditor.SelStart = 0) Then
        Key := #0;
    If (StringGrid.Cells[StringGrid.Col, StringGrid.Row] = '-') And
      ((Not CharInSet(Key, NO_ZERO_DIGITS)) Or (Key = '-')) And
      (Key <> BACKSPACE) Then
        Key := #0;
    If (Key = '-') And (StringGrid.InplaceEditor.SelStart > 0) Then
        Key := NONE;
    If (Pos('-', StringGrid.Cells[StringGrid.Col, StringGrid.Row]) = 1) And
      (StringGrid.InplaceEditor.SelStart = 0) And (Key = '0') Then
        Key := NONE;
    If (Length(StringGrid.Cells[StringGrid.Col, StringGrid.Row]) > 0) And
      (StringGrid.Cells[StringGrid.Col, StringGrid.Row] = '0') And
      (Key <> BACKSPACE) Then
    Begin
        Key := NONE;
    End;
    If (StringGrid.Cells[StringGrid.Col, StringGrid.Row] <> '') And
      (StringGrid.InplaceEditor.SelStart = 0) And (Key = #8) Then
        Key := #0;

End;

Procedure TMainTaskForm.StringGridKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TMainTaskForm.StringGridKeyPress(Sender: TObject; Var Key: Char);
Var
    NumsGrid: TEStringGrid;
Begin
    NumsGrid := TEStringGrid(Sender);
    CheckComboButtonsGrid(Key, NumsGrid);
    CheckInput(StringGrid.Cells[StringGrid.Col, StringGrid.Row], Key,
      MIN_X, MAX_X);
End;

Procedure TMainTaskForm.StringGridMouseActivate(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
  Var MouseActivate: TMouseActivate);
Begin
    Clipboard.Clear;
End;

End.
