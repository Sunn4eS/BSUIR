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

Type
    TPrimeNum = Array Of Integer;

Const
    DIGITS = ['0' .. '9'];
    BACKSPACE = #8;
    NONE = #0;

Type
    TStringGridEx = Class(TStringGrid);

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
    EnterNLabel: TLabel;
    StringGridLabel: TLabel;
    Task: TLabel;

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
    procedure ResultButtonClick(Sender: TObject);
    function FormHelp(Command: Word; Data: NativeInt;
      var CallHelp: Boolean): Boolean;
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
    MAX_N = 10000;
    MIN = 2;
    MAX = 10000;

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

Procedure FillGrid(ColNum: Integer; Grid: TStringGrid; PrimeNum: TPrimeNum);
Var
    I: Integer;
Begin
    Grid.ColCount := ColNum;
    If ColNum > 5 Then
    Begin
        Grid.Width := (Grid.DefaultColWidth + 3) * 5;
        Grid.Height := Grid.DefaultRowHeight * 3 - 5;
    End
    Else
    Begin
        Grid.Width := (Grid.DefaultColWidth + 4) * ColNum;
        Grid.Height := (Grid.DefaultRowHeight + 4) * 2;
    End;
    For I := 0 To ColNum - 1 Do
        Grid.Cells[I, 0] := '№' + IntToStr(I + 1);
    For I := 0 To ColNum - 1 Do
        Grid.Cells[I, 1] := IntToStr(PrimeNum[I]);

End;

Procedure ClearGrid(Grid: TStringGrid);
Var
    J, I: Integer;
Begin
    For I := 0 To Grid.ColCount - 1 Do
        For J := 0 To Grid.RowCount - 1 Do
            Grid.Cells[I, J] := '';
    Grid.ColCount := 0;
End;

Procedure TMainForm.EnterNEditChange(Sender: TObject);
Var
    Num: Integer;
Begin
    If (EnterNEdit.Text <> '') And (EnterNEdit.Text <> '1') And TryStrToInt(EnterNEdit.Text, Num) Then
        ResultButton.Enabled := True
    Else
        ResultButton.Enabled := False;

    StringGridLabel.Visible := False;
    NumsStringGrid.Visible := False;
    ClearGrid(NumsStringGrid);


        IsSaved := SAVE;
        SaveOption.Enabled := False;

End;

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



Function IsAllCellFill(Grid: TStringGrid; ColCount: Integer): Boolean;
Const
    NumsRow = 1;
Var
    IsFilled: Boolean;
        Col: Integer;
Begin
    IsFilled := MainForm.EnterNEdit.Text <> '';
    Col := 0;
    While IsFilled And (Col < ColCount) Do
    Begin
        If (MainForm.NumsStringGrid.Cells[Col, NumsRow] = '') Then
            IsFilled := False;
        Inc(Col);
    End;
    IsAllCellFill := IsFilled;
End;

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
    Arr: Array Of Integer;
    I: Integer;
Begin
    Reset(F);
    Error := ReadFileNum(F, Num, MIN_N + 1, MAX_N);
    If Error = CORRECT Then
    Begin
        EnterNEdit.Text := IntToStr(Num);


    End;
    If (Error = CORRECT) And Not EOF(F) Then
            Error := EXTRA_DATA;
    CloseFile(F);
    ReadFileData := Error;
End;


Function FindAmountOfPrimeNum (Num: Integer) : Integer;
Var
    I, J, AmountOfNum: Integer;
    Remainder: Real;
    IsPrimeNum: Boolean;
Begin
    AmountOfNum := 0;
    For I := MIN To Num Do
    Begin
        IsPrimeNum := True;
        For J := MIN To I Do
        Begin
            Remainder := I Mod J;
            If (Remainder = 0) And (I <> J) Then
                IsPrimeNum := False;
        End;
        If IsPrimeNum Then
            Inc(AmountOfNum);
    End;
    FindAmountOfPrimeNum := AmountOfNum;
End;

Procedure FindPrimeNum (Num: Integer; AmountOfNum: Integer; Var PrimeNum: TPrimeNum);
Var
    I, J, K: Integer;
    Remainder: Real;
    IsPrimeNum: Boolean;
Begin
    SetLength(PrimeNum, AmountOfNum);
    K := 0;
    For I := MIN To Num Do
    Begin
        IsPrimeNum := True;
        For J := MIN To I Do
        Begin
            Remainder := I Mod J;
            If (Remainder = 0) And (I <> J) Then
            IsPrimeNum := False;
        End;
        If IsPrimeNum Then
        Begin
            PrimeNum[K] := I;
            Inc(K);
        End;
    End;
End;

procedure TMainForm.ResultButtonClick(Sender: TObject);
Var
    I, Num: Integer;
    PrimeNum: TPrimeNum;
Begin
    Num := StrToInt(EnterNEdit.Text);
    FindPrimeNum(Num, FindAmountOfPrimeNum(Num), PrimeNum);
    FillGrid(FindAmountOfPrimeNum(Num), NumsStringGrid, PrimeNum);
    NumsStringGrid.Visible := True;
    StringGridLabel.Visible := True;

        IsSaved := UNSAVE;
        SaveOption.Enabled := True;

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
    I: Integer;
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
                Write(F, #13#10, 'Все простые числа не превоcходящие число ', EnterNEdit.Text , ': ');
                For I := 0 To NumsStringGrid.ColCount - 1 Do
                    Write(F, NumsStringGrid.Cells[I, 1], ', ');

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
            Write(F, 'Все простые числа не превоcходящие число ', EnterNEdit.Text , ': ');
                For I := 0 To NumsStringGrid.ColCount - 1 Do
                    Write(F, NumsStringGrid.Cells[I, 1], ', ');
            CloseFile(F);
            IsSaved := SAVE;
        End;

    End;
End;

End.
