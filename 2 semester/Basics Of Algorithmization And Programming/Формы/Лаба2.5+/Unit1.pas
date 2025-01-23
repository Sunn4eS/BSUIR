Unit Unit1;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Unit2, Unit3, Vcl.StdCtrls,
    Vcl.Grids;

Type
    ERRORS_CODE = (CORRECT, INCORRECT_RANGE, EXTRA_DATA, IS_NOT_READABLE,
      IS_NOT_WRITEABLE, INCORRECT_DATA_IN_FILE, INCORRECT_NUMS_AMOUNT);
    TSAVE = (SAVE, UNSAVE, PROBLEMSAVE);

Const
    DIGITS = ['0' .. '9'];
    BACKSPACE = #8;
    NONE = #0;

Type
    TStringGridEx = Class(TStringGrid);

    TMatrix = Array Of Array Of Integer;

    TArr = Array Of Integer;

    TMainForm = Class(TForm)
        MainMenu1: TMainMenu;
        FileTab: TMenuItem;
        OpenOption: TMenuItem;
        SaveOption: TMenuItem;
        LineSeparator: TMenuItem;
        ExitOption: TMenuItem;
        InstructionTab: TMenuItem;
        DeveloperTab: TMenuItem;
        OpenFile: TOpenDialog;
        SaveFile: TSaveDialog;
        EnterNEdit: TEdit;
        NumsStringGrid: TStringGrid;
        ResultButton: TButton;
        ResultEdit: TEdit;
    EnterNLabel: TLabel;
    StringGridLabel: TLabel;
    Task: TLabel;
    EnterMEdit: TEdit;
    EnterMLabel: TLabel;
    Label1: TLabel;

        Procedure CheckFields();
        Procedure CompareMinAndMax(ArrMinLine, ArrMaxColumn: TArr);
        Procedure FindResult(Matrix: TMatrix);
        Function ReadFileData(Var F: TextFile; Sender: TObject): ERRORS_CODE;
        Procedure InstructionTabClick(Sender: TObject);
        Procedure SaveOnClick(Sender: TObject);
        Procedure DeveloperOnClick(Sender: TObject);
        Procedure ExitOnClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure OpenOnClick(Sender: TObject);
        Procedure EnterNEditChange(Sender: TObject);
        Procedure EnterNEditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure NOnKeyPress(Sender: TObject; Var Key: Char);
    procedure EnterNEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure NumsStringGridKeyPress(Sender: TObject; var Key: Char);
    procedure NumsStringGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure NumsStringGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure ResultEditChange(Sender: TObject);
    procedure ResultButtonClick(Sender: TObject);
    function FormHelp(Command: Word; Data: NativeInt;
      var CallHelp: Boolean): Boolean;
    procedure FormCreate(Sender: TObject);
    procedure EnterMEditChange(Sender: TObject);
    procedure EnterMEditContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure EnterMEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EnterMEditKeyPress(Sender: TObject; var Key: Char);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    MainForm: TMainForm;

Implementation

{$R *.dfm}

Var
    PerformCloseQuery: Boolean = True;
    IsSaved: TSAVE = SAVE;

Const
    ERRORS: Array [ERRORS_CODE] Of String = ('',
      'Значение не попадает в диапазон!', 'Лишние данные в файле!',
      'Файл закрыт для чтения!', 'Файл закрыт для записи!',
      'Некорректный тип данных в файле!', 'Неправильное количество чисел в файле!');
    MIN_N = 1;
    MAX_N = 5;
    MIN_NUM = -99;
    MAX_NUM = 100;

Function IsValidRange(Text: String; MIN, MAX: Integer): Boolean;
Var
    IsValidInput: Boolean;
    Num: Real;
Begin
    IsValidInput := True;
    Num := StrToFloat(Text);
    If (Num < MIN) Or (Num > MAX) Then
        IsValidInput := False;
    IsValidRange := IsValidInput;
End;

Procedure TMainForm.DeveloperOnClick(Sender: TObject);
Var
    DeveloperForm: TDeveloperForm;
Begin
    DeveloperForm := TDeveloperForm.Create(Self);
    DeveloperForm.ShowModal;
    DeveloperForm.Free;
End;

Procedure TMainForm.InstructionTabClick(Sender: TObject);
Var
    InstructionForm: TInstructionForm;
Begin
    InstructionForm := TInstructionForm.Create(Self);
    InstructionForm.ShowModal;
    InstructionForm.Free;
End;

Procedure FillGrid(RowNum: Integer; ColNum: Integer; Grid: TStringGrid);
Var
    I: Integer;
Begin
    Grid.ColCount := ColNum;
    Grid.RowCount := RowNum;
    Grid.Width := (Grid.DefaultColWidth + 4 - Grid.GridLineWidth) * Grid.ColCount;
    Grid.Height := (Grid.DefaultRowHeight + 4 - Grid.GridLineWidth) * Grid.RowCount;
    Grid.Enabled := True;
End;

Procedure ClearGrid(Grid: TStringGrid);
Var
    J, I: Integer;
Begin
    For I := 0 To Grid.ColCount - 1 Do
        For J := 0 To Grid.RowCount - 1 Do
            Grid.Cells[I, J] := '';
    Grid.Enabled := False;
End;

Procedure TMainForm.CheckFields();
Var
    Num: Integer;
Begin
    If TryStrToInt(EnterNEdit.Text, Num) And TryStrToInt(EnterMEdit.Text, Num) And IsValidRange(EnterNEdit.Text, MIN_N + 1, MAX_N) And
      IsValidRange(EnterMEdit.Text, MIN_N + 1, MAX_N) Then
    Begin
        StringGridLabel.Visible := True;
        NumsStringGrid.Visible := True;
        ClearGrid(NumsStringGrid);
        FillGrid(StrToInt(EnterNEdit.Text), StrToInt(EnterMEdit.Text), NumsStringGrid);
    End
End;

procedure TMainForm.EnterMEditChange(Sender: TObject);
Var
    Num: Integer;
begin
    If (EnterMEdit.Text = '') Or (EnterMEdit.Text = '1') Or Not TryStrToInt(EnterNEdit.Text, Num) Then
    Begin
        StringGridLabel.Visible := False;
        NumsStringGrid.Visible := False;
        ClearGrid(NumsStringGrid);
    End
    Else
    Begin
        CheckFields();
    End;
    ResultEdit.Text := '';
End;

procedure TMainForm.EnterMEditContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
    Handled := True;
end;

procedure TMainForm.EnterMEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    If (Key = VK_UP) Then
        SelectNext(EnterMEdit, False, True);
    If (Key = VK_DOWN) Then
        SelectNext(EnterMEdit, True, True);
    If (Key = VK_DELETE) Then
        Key := 0;
    If ((SsShift In Shift) Or (SsCtrl In Shift)) And
      Not((Key = VK_RIGHT) Or (Key = VK_LEFT)) Then
        Key := 0;
end;

Procedure ComponentKeyPress(Var Key: Char; SelStart, SelLength: Integer;
  Text: String; Const MIN, MAX: Integer);
Var
    IsValidInput: Boolean;
Begin
    IsValidInput := (CharInSet(Key, DIGITS) Or (Key = BACKSPACE));
    If (SelLength > 0) And (SelLength < Length(Text)) Then
        Key := NONE;
    If (SelLength = Length(Text)) And (Key = '0') And (Length(Text) <> 0) Then
        Key := NONE;
    If (SelStart = 0) And (SelLength < Length(Text)) And (Key = '0') Then
        Key := NONE;
    If (SelStart = 1) And (Length(Text) > 1) And (Text[2] = '0') And
      (Key = BACKSPACE) Then
        Key := NONE;
    If (Length(Text) = 0) And (Key = '0') Then
        Key := NONE
    Else If (IsValidInput) And (Key <> BACKSPACE) Then
        IsValidInput := IsValidRange(Text + Key, MIN, MAX);
    If Not IsValidInput Then
        Key := NONE;
End;

procedure TMainForm.EnterMEditKeyPress(Sender: TObject; var Key: Char);
Var
    SelStart, SelLength: Integer;
    Text: String;
Begin
    SelStart := EnterMEdit.SelStart;
    SelLength := EnterMEdit.SelLength;
    Text := EnterMEdit.Text;
    ComponentKeyPress(Key, SelStart, SelLength, Text, MIN_N, MAX_N);
End;

Procedure TMainForm.EnterNEditChange(Sender: TObject);
Var
    Num: Integer;
Begin;
    If (EnterNEdit.Text = '') Or (EnterNEdit.Text = '1') Or Not TryStrToInt(EnterNEdit.Text, Num) Then
    Begin
        StringGridLabel.Visible := False;
        NumsStringGrid.Visible := False;
        ClearGrid(NumsStringGrid);
    End
    Else
    Begin
        CheckFields();
    End;
    ResultEdit.Text := '';
End;

Procedure ComponentKeyPressGrid(Var Key: Char; SelStart, SelLength: Integer;
  Text: String; Const MIN, MAX: Integer);
Var
    IsValidInput: Boolean;
Begin
    IsValidInput := (CharInSet(Key, DIGITS) Or (Key = BACKSPACE)) Or (Key = '-');
    If (SelLength > 0) And (SelLength < Length(Text)) Then
        Key := NONE;
    If (SelLength = Length(Text)) And (Key = '0') And (Length(Text) <> 0) Then
        Key := NONE;
    If (SelStart = 0) And (SelLength < Length(Text)) And ((Key = '0') Or (Key = '-')) Then
        Key := NONE;
    if (Pos('-', Text) = 1) And (Key = '-') then
        Key := NONE;
    If (Length(Text) > 0) And (Key = '-') Then
        Key := None;
    If (Length(Text) = 1)  and (Text[1] = '-') And (Key = '0') Then
        Key := NONE;
    If (SelStart = 0) And (Length(Text) > 0) And (SelLength < Length(Text)) And ((Text[1] = '-') Or (Text[1] = '0')) Then
        Key := None;

    If (Length(Text) > 0) And (Text[1] = '0') And (SelStart = 1) And (Key <> BACKSPACE) Then
        Key := NONE;
            
    If (SelStart = 1) And (Length(Text) > 1) And (Text[2] = '0') And
      (Key = BACKSPACE) Then
        Key := NONE;
    If (SelStart = 2) And (Length(Text) > 2) And (Text[1] = '-') And (Text[3] = '0') And
      (Key = BACKSPACE) Then
        Key := NONE;
    If (IsValidInput) And (Key <> BACKSPACE) And (Key <> '-') And (Key <> NONE)Then
        IsValidInput := IsValidRange(Text + Key, MIN, MAX);
    If Not IsValidInput Then
        Key := NONE;

End;

Procedure TMainForm.EnterNEditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    Handled := True;
End;

procedure TMainForm.EnterNEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    If (Key = VK_UP) Then
        SelectNext(EnterNEdit, False, True);
    If (Key = VK_DOWN) Then
        SelectNext(EnterNEdit, True, True);
    If (Key = VK_DELETE) Then
        Key := 0;
    If ((SsShift In Shift) Or (SsCtrl In Shift)) And
      Not((Key = VK_RIGHT) Or (Key = VK_LEFT)) Then
        Key := 0;
end;

Procedure TMainForm.NOnKeyPress(Sender: TObject; Var Key: Char);
Var
    SelStart, SelLength: Integer;
    Text: String;
Begin
    SelStart := EnterNEdit.SelStart;
    SelLength := EnterNEdit.SelLength;
    Text := EnterNEdit.Text;
    ComponentKeyPress(Key, SelStart, SelLength, Text, MIN_N, MAX_N);
End;

procedure TMainForm.NumsStringGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    If (Key = VK_DELETE) Then
        Key := 0;
    If ((SsShift In Shift) Or (SsCtrl In Shift)) And
      Not((Key = VK_RIGHT) Or (Key = VK_LEFT)) Then
        Key := 0;
end;

Function IsAllCellFill(Grid: TStringGrid): Boolean;
Const
    NumsRow = 1;
Var
    IsFilled: Boolean;
    Col, Row, Num: Integer;
Begin
    IsFilled := MainForm.EnterNEdit.Text <> '';
    Row := 0;
    While isFilled And (Row < Grid.RowCount) do
    Begin
        Col := 0;
        While IsFilled And (Col < Grid.ColCount) Do
        Begin
            If (MainForm.NumsStringGrid.Cells[Col, Row] = '') Or Not TryStrToInt(MainForm.NumsStringGrid.Cells[Col, Row], Num)Then
                IsFilled := False;
            Inc(Col);
        End;
        Inc(Row);
    End;
    IsAllCellFill := IsFilled;
End;

Procedure TMainForm.NumsStringGridKeyPress(Sender: TObject; Var Key: Char);
Var
    NumsGrid: TStringGridEx;
    SelStart, SelLength: Integer;
    Text: String;
Begin
    NumsGrid := TStringGridEx(Sender);
    If Assigned(NumsGrid.InplaceEditor) Then
    Begin
        SelStart := NumsGrid.InplaceEditor.SelStart;
        SelLength := NumsGrid.InplaceEditor.SelLength;
        Text := NumsGrid.InplaceEditor.Text;
        ComponentKeyPressGrid(Key, SelStart, SelLength, Text, MIN_NUM, MAX_NUM);
    End;
end;

procedure TMainForm.NumsStringGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
    ResultButton.Enabled := IsAllCellFill(NumsStringGrid);
    ResultEdit.Text := '';
end;

Procedure TMainForm.ExitOnClick(Sender: TObject);
Var
    Confirmation: Integer;
Begin
    PerformCloseQuery := False;
    If (IsSaved = UNSAVE) Then
    Begin
        Confirmation := Application.MessageBox
          ('Вы не сохранили файл, хотите ли сохранить?', 'Выход',
          MB_YESNOCANCEl + MB_ICONQUESTION + MB_DEFBUTTON2);
        Case Confirmation Of
            MrYes:
                Begin
                    SaveOnClick(Sender);
                    If IsSaved = SAVE Then
                        Close
                    Else
                        ExitOnClick(Sender);
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

Procedure TMainForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
    Confirmation: Integer;
Begin
    If PerformCloseQuery Then
    Begin
        If (IsSaved = UNSAVE) Then
        Begin
            Confirmation := Application.MessageBox
              ('Вы не сохранили файл, хотите ли сохранить?', 'Выход',
              MB_YESNOCANCEl + MB_ICONQUESTION + MB_DEFBUTTON2);
            Case Confirmation Of
                MrYes:
                    Begin
                        SaveOnClick(Sender);
                        If IsSaved = SAVE Then
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

procedure TMainForm.FormCreate(Sender: TObject);
begin
    //Task.Caption := 'Данная программа определяет емкости систем' + #13#10 + 'конденсаторов, которые получаются  последовательным' + #13#10 + 'и параллельным соединением исходных конденсаторов.'
end;

function TMainForm.FormHelp(Command: Word; Data: NativeInt;
  var CallHelp: Boolean): Boolean;
begin
    CallHelp := false;
end;

Function IsReadable(Var F: TextFile): ERRORS_CODE;
Var
    Error: ERRORS_CODE;
Begin
    Error := CORRECT;
    Try
        Try
            Reset(F);
        Finally
            CloseFile(F);
        End;
    Except
        Error := IS_NOT_READABLE;
    End;
    IsReadable := Error;
End;

Function ReadFileNum(Var F: TextFile; Var Num: Integer; Const MIN, MAX: Integer): ERRORS_CODE;
Var
    Error: ERRORS_CODE;
Begin
    Error := CORRECT;
    Try
        Read(F, Num);
    Except
        Error := INCORRECT_DATA_IN_FILE;
    End;
    If (Error = CORRECT) And Not(IsValidRange(IntToStr(Num), MIN, MAX)) Then
        Error := INCORRECT_RANGE;
    ReadFileNum := Error;
End;

Function TMainForm.ReadFileData(Var F: TextFile; Sender: TObject): ERRORS_CODE;
Var
    Error: ERRORS_CODE;
    Num: Integer;
    Matrix: TMatrix;
    I, J: Integer;
Begin
    Reset(F);
    Error := ReadFileNum(F, Num, MIN_N + 1, MAX_N);
    If Error = CORRECT Then
    Begin
        EnterNEdit.Text := IntToStr(Num);
        Error := ReadFileNum(F, Num, MIN_N + 1, MAX_N);
    End;
    If Error = CORRECT Then
    Begin
        EnterMEdit.Text := IntToStr(Num);
    End;    

    SetLength(Matrix, StrToInt(EnterNEdit.Text), StrToInt(EnterMEdit.Text));

    For I:= 0 To NumsStringGrid.RowCount - 1 Do
    Begin
        J:= 0;
        While (Error = CORRECT) And Not EOF(F) And (J < NumsStringGrid.ColCount) Do
        Begin
            Error := ReadFileNum(F, Matrix[I, J], MIN_NUM, MAX_NUM);
            Inc(J);
        End;
    End;
    If (Error = CORRECT) And (J <> NumsStringGrid.ColCount) And (I <> NumsStringGrid.RowCount) Then
        Error := INCORRECT_NUMS_AMOUNT;
    
    If Error = CORRECT Then
    Begin
        For I:= 0 To NumsStringGrid.RowCount - 1 Do
        Begin
            For J := 0 To NumsStringGrid.ColCount - 1 Do
            MainForm.NumsStringGrid.Cells[J, I] := IntToStr(Matrix[I, J]);
            MainForm.ResultButton.Enabled := True;
         End;
    End;
    If (Error = CORRECT) And Not EOF(F) Then
        Error := EXTRA_DATA;
    CloseFile(F);
    ReadFileData := Error;
End;

Function ReadArrOfMinLine(Matrix: TMatrix; Lines, Columns: Integer) : TArr;
Var
    Arr: TArr;
    I, J, MinLine: Integer;
Begin
    SetLength(Arr, Lines);
    For I := 0 To Lines - 1 Do
    Begin
        MinLine := Matrix[I][0];
        For J := 0 To Columns - 1 Do
        Begin
            If Matrix[I][J] < MinLine Then
                MinLine := Matrix[I][J];
        End;
        Arr[I] := MinLine;
    End;
    ReadArrOfMinLine := Arr;
End;

Function ReadArrOfMaxColumn(Matrix: TMatrix; Lines, Columns: Integer) : TArr;
Var
    Arr: TArr;
    I, J, MaxColumn: Integer;
Begin
    SetLength(Arr, Columns);
    For I := 0 To Columns - 1 Do
    Begin
        MaxColumn := Matrix[0][I];
        For J := 0 To Lines - 1 Do
        Begin
            If Matrix[J][I] > MaxColumn Then
                MaxColumn := Matrix[J][I];
        End;
        Arr[I] := MaxColumn;
    End;
    ReadArrOfMaxColumn := Arr;
End;

Procedure TMainForm.CompareMinAndMax(ArrMinLine, ArrMaxColumn: TArr);
Var
    I, J, K: Integer;
    SaddlePoint: Boolean;
Begin
    K := 0;
    SaddlePoint := False;
    For I := Low(ArrMinLine) To High(ArrMinLine) Do
        For J := Low(ArrMaxColumn) To High(ArrMaxColumn) Do
        Begin
            If ArrMinLine[I] = ArrMaxColumn[J] Then
            Begin
                Inc(K);
                If SaddlePoint Then
                    ResultEdit.Text := ResultEdit.Text + ', ';
                ResultEdit.Text := ResultEdit.Text + 'a_' + IntToStr(I + 1) + IntToStr(J + 1) + ' = ' + IntToStr(ArrMinLine[I]);
                SaddlePoint := True;
            End;
        End;
    If Not SaddlePoint Then
        ResultEdit.Text := 'Седловых точек в данной матрице нет';
End;

Procedure TMainForm.FindResult(Matrix: TMatrix);
Begin
    CompareMinAndMax(ReadArrOfMinLine(Matrix, NumsStringGrid.RowCount, NumsStringGrid.ColCount), ReadArrOfMaxColumn(Matrix, NumsStringGrid.RowCount, NumsStringGrid.ColCount));
End;

procedure TMainForm.ResultButtonClick(Sender: TObject);
Var
    Matrix: TMatrix;
    I, J: Integer;
Begin
    ResultEdit.Text := '';
    SetLength(Matrix, NumsStringGrid.RowCount, NumsStringGrid.ColCount);
    For I := 0 To NumsStringGrid.RowCount - 1 Do
        For J := 0 To NumsStringGrid.ColCount - 1 Do
            Matrix[I][J] := StrToInt(NumsStringGrid.Cells[J, I]);
    FindResult(Matrix);
end;

procedure TMainForm.ResultEditChange(Sender: TObject);
begin
    If ResultEdit.Text = '' Then
    Begin
        IsSaved := SAVE;
        SaveOption.Enabled := False;
        ResultEdit.Enabled := False;
    End
    Else
    Begin
        IsSaved := UNSAVE;
        SaveOption.Enabled := True;
        ResultEdit.Enabled := True;
    End;
end;

Procedure TMainForm.OpenOnClick(Sender: TObject);
Var
    Error: ERRORS_CODE;
    F: TextFile;
    FileName: String;
Begin
    If OpenFile.Execute Then
    Begin
        FileName := OpenFile.FileName;
        AssignFile(F, FileName);
        Error := IsReadable(F);
        If Error = CORRECT Then
            Error := ReadFileData(F, Sender);
        If Error <> CORRECT Then
            Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка',
              MB_OK Or MB_ICONINFORMATION);
    End;
End;

Function IsWriteable(Var F: TextFile): ERRORS_CODE;
Var
    Error: ERRORS_CODE;
Begin
    Error := CORRECT;
    Try
        Try
            Append(F);
        Finally
            CloseFile(F);
        End;
    Except
        Error := Is_NOT_WRITEABLE;
    End;
    IsWriteable := Error;
End;

Procedure TMainForm.SaveOnClick(Sender: TObject);
Var
    Error: ERRORS_CODE;
    F: TextFile;
    FileName: String;
Begin
    If SaveFile.Execute Then
    Begin
        FileName := SaveFile.FileName;
        FileName := ChangeFileExt(FileName, '.txt');
        AssignFile(F, FileName);
        If FileExists(FileName) Then
        Begin
            Error := IsWriteable(F);
            If Error = CORRECT Then
            Begin
                Append(F);
                Write(F, #13#10 + 'Все седловые точки заданной матрицы: ' + ResultEdit.Text);
                CloseFile(F);
                IsSaved := SAVE;
            End;
            If Error <> CORRECT Then
            Begin
                Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка',
                  MB_OK Or MB_ICONINFORMATION);
                IsSaved := UNSAVE;
            End;
        End
        Else
        Begin
            Rewrite(F);
            Write(F, 'Все седловые точки заданной матрицы: ' + ResultEdit.Text);
            CloseFile(F);
            IsSaved := SAVE;
        End;

    End;
End;

End.
