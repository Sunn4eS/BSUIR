Unit MainForm;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Clipbrd,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
    Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.Grids;

Type
    TMatrix = Array Of Array Of Integer;
    // TStepArr = Array [1..2] Of Array Of Integer;
    TVector = Array [1 .. 2] Of Array [1 .. 2] Of Real;
    ERRORS_LIST = (CORRECT, RANGE_ERR, NUM_ERR, NOT_READABLE, NOT_WRITEABLE,
      FILE_EMPTY, EXTRA_DATA);

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
        EnterNEdit: TEdit;
        EnterNLabel: TLabel;
        SaveTextFile: TSaveTextFileDialog;
        OutGrid: TStringGrid;
        OutLabel: TLabel;
        Procedure DeveloperMenuClick(Sender: TObject);
        Procedure InstructionMenuClick(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure EnterNEditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);

        Procedure GetDataFromFile(Var F: TextFile; Sender: TObject);
        Function FileReading(Var F: TextFile): ERRORS_LIST;
        Procedure ResultButtonClick(Sender: TObject);

        Procedure EnterNEditChange(Sender: TObject);
        Procedure QuitMenuClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);

        Procedure EnterNEditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);

        Procedure EnterNEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure EnterNEditExit(Sender: TObject);

        Procedure EnterNEditClick(Sender: TObject);

        Procedure SaveMenuClick(Sender: TObject);
        Procedure OpenMenuClick(Sender: TObject);
        Procedure StringGridMouseActivate(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y, HitTest: Integer;
          Var MouseActivate: TMouseActivate);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure MainFunction();

    Private

        { Private declarations }
    Public
        { Public declarations }
    End;

Const
    ERRORS: Array [ERRORS_LIST] Of String = ('',
      'Значение не попадает в диапазон!',
      'Проверьте корректность ввода данных!', 'Файл закрыт для чтения!',
      'Файл закрыт для записи!', 'Файл пуст!', 'Лишние данные!');
    DIGITS = ['0' .. '9'];
    NO_ZERO_DIGITS = ['1' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_N = 1;
    MAX_N = 15;
    MAX_SIGNS = 4;

    ALPHABET = ['A' .. 'Z', 'a' .. 'z'];

Var
    MainTaskForm: TMainTaskForm;

Implementation

Uses
    Math;

{$R *.dfm}

Var
    Saved: Boolean = True;
    PerformCloseQuery: Boolean = True;
    CtrlPressed: Boolean = False;

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
    ResultButton.Enabled := False;
    TaskLabel.Caption := 'Данная программа находит решение головоломки' + #13#10
      + '"Ханойская башня" с n количеством дисков' + #13#10 + '';

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

Procedure TMainTaskForm.EnterNEditContextPopup(Sender: TObject;
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
    If (Length(Edit.Text) > 0) And (Edit.Text[1] = ',') Then
        Edit.Text := '';
End;

Procedure TMainTaskForm.EnterNEditExit(Sender: TObject);
Begin
    GiveZeroOrNone(EnterNEdit);
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

Function CheckFileData(Var F: TextFile): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
    Value: Integer;

Begin
    ERRORS := CORRECT;
    Reset(F);

    While (ERRORS = CORRECT) And Not EOLN(F) Do
    Begin

        Try
            Read(F, Value);
        Except
            ERRORS := NUM_ERR;
        End;
        If ERRORS = CORRECT Then
            ERRORS := IsCorrectRange(Value, MIN_N + 1, MAX_N);
    End;
    If Not EOF(F) Then
        ERRORS := EXTRA_DATA;
    CloseFile(F);
    CheckFileData := ERRORS;
End;

Procedure TMainTaskForm.GetDataFromFile(Var F: TextFile; Sender: TObject);
Var
    NumStr: String;

Begin

    Reset(F);
    Readln(F, NumStr);
    EnterNEdit.Text := NumStr;

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
        ResultButton.Enabled := True;
    FileReading := ERRORS;
End;

Procedure TMainTaskForm.OpenMenuClick(Sender: TObject);
Var
    Error: ERRORS_LIST;
    F: TextFile;
    Num, FileName: String;

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

Procedure FillGridFromMatrix(ResMatrix: TMatrix; OutGrid: TStringGrid);
Var
    I, J, MaxI, MaxJ: Integer;
    Counter: Integer;
Begin
    MaxI := High(ResMatrix[0]);
    MaxJ := High(ResMatrix);
    Counter := 0;
    For I := 0 To MaxJ Do
    Begin
        Inc(Counter);
        OutGrid.Cells[I + 1, 0] := Concat(IntToStr(Counter), ' Шаг');
    End;

    OutGrid.Cells[0, 0] := '/';
    OutGrid.Cells[0, 1] := 'Откуда';
    OutGrid.Cells[0, 2] := 'Куда';

    For I := 0 To MaxI Do
    Begin
        For J := 0 To MaxJ Do
        Begin
            OutGrid.Cells[J + 1, I + 1] := IntToStr(ResMatrix[J, I]);
        End;
    End;
End;

Procedure FillGrid(Columns: Integer; Grid: TStringGrid);
Var
    I, J: Integer;
    NumArr: TMatrix;
Begin

    If Columns > 4 Then
    Begin
        Grid.Width := (Grid.DefaultColWidth + 3) * 4;
        Grid.Height := Grid.DefaultRowHeight * 4;
    End
    Else
    Begin
        Grid.Width := (Grid.DefaultColWidth) * (Columns + 1);
        Grid.Height := (Grid.DefaultRowHeight * 4);
    End;
    Grid.Enabled := True;
    Grid.ColCount := Columns + 2;
    Grid.RowCount := 3;
    Grid.FixedCols := 1;
    Grid.FixedRows := 1;
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

Procedure TMainTaskForm.EnterNEditChange(Sender: TObject);

Begin

    If (EnterNEdit.Text = '') OR (EnterNEdit.Text = '1') Then
    Begin
        Saved := True;
        SaveMenu.Enabled := False;
        OutGrid.Visible := False;
        ClearGrid(OutGrid);
        ResultButton.Enabled := False;
    End
    Else
    Begin
        ResultButton.Enabled := True;
        ClearGrid(OutGrid);
    End;

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
                Rewrite(F);
                For I := 0 To OutGrid.ColCount Do
                Begin
                    For J := 0 To OutGrid.ColCount Do
                    Begin
                        Write(F, OutGrid.Cells[I, J]);
                        If J < OutGrid.ColCount - 1 Then
                            Write(F, ' ');
                    End;
                    Writeln(F);
                End;

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
            For I := 0 To OutGrid.ColCount Do
            Begin
                For J := 0 To OutGrid.ColCount Do
                Begin
                    Write(F, OutGrid.Cells[I, J], ' ');
                End;
                Writeln(F);
            End;
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

Procedure BlockClick(Edit: TEdit);
Begin
    If Edit.SelStart <> Length(Edit.Text) Then
        Edit.SelStart := Length(Edit.Text);
End;

Procedure MoveDisk(FromStick, ToStick: Integer; Var StepArr: TMatrix;
  Var Counter: Integer);
Begin
    StepArr[Counter][0] := FromStick;
    StepArr[Counter][1] := ToStick;
    Inc(Counter);
End;

Procedure HanoiTower(N, FromStick, ToStick, BufStick: Integer;
  Var StepArr: TMatrix; Var Counter: Integer);
Begin
    If N > 0 Then
    Begin
        HanoiTower(N - 1, FromStick, BufStick, ToStick, StepArr, Counter);
        MoveDisk(FromStick, ToStick, StepArr, Counter);
        HanoiTower(N - 1, BufStick, ToStick, FromStick, StepArr, Counter);
    End;
End;

Procedure TMainTaskForm.MainFunction();
Var
    StepArr: TMatrix;
    N: Byte;
    Len: Double;
    Counter: Integer;
Begin
    Counter := 0;
    N := StrToInt(EnterNEdit.Text);
    SetLength(StepArr, Round(Power(2, N)) - 1, 2);
    HanoiTower(N, 1, 3, 2, StepArr, Counter);
    FillGrid(High(StepArr), OutGrid);
    FillGridFromMatrix(StepArr, OutGrid);

End;

Procedure TMainTaskForm.EnterNEditClick(Sender: TObject);
Begin
    BlockClick(EnterNEdit);
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
Begin
    MainFunction();

    OutGrid.Visible := True;
    OutGrid.Enabled := True;

    If Not IsGridFull(OutGrid) Then
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

Procedure TMainTaskForm.StringGridMouseActivate(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
  Var MouseActivate: TMouseActivate);
Begin
    Clipboard.Clear;
End;

End.
