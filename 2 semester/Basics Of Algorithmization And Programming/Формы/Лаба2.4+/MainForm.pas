unit MainForm;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
    Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.Grids;

type
    TEStringGrid = Class(TStringGrid);
    TArr = Array Of Integer;
    ERRORS_LIST = (CORRECT, RANGE_ERR, NUM_ERR, NOT_READABLE, NOT_WRITEABLE,
      FILE_EMPTY, LINE_ERR, ORDER_ERR);

    TMainTaskForm = class(TForm)
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
        OutEdit: TEdit;
        EnterNLabel: TLabel;
        ArrLabel: TLabel;
        OutLabel: TLabel;
        SaveTextFile: TSaveTextFileDialog;
        StringGrid: TStringGrid;
        procedure DeveloperMenuClick(Sender: TObject);
        procedure InstructionMenuClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure EnterNEditContextPopup(Sender: TObject; MousePos: TPoint;
          var Handled: Boolean);

        Procedure GetDataFromFile(Var F: TextFile; Sender: TObject);
        Function FileReading(Var F: TextFile): ERRORS_LIST;
        procedure ResultButtonClick(Sender: TObject);
        procedure OutEditChange(Sender: TObject);
        procedure EnterNEditChange(Sender: TObject);
        procedure QuitMenuClick(Sender: TObject);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

        procedure EnterNEditKeyDown(Sender: TObject; var Key: Word;
          Shift: TShiftState);

        procedure EnterNEditKeyPress(Sender: TObject; var Key: Char);
        procedure EnterNEditExit(Sender: TObject);

        procedure EnterNEditClick(Sender: TObject);

        procedure SaveMenuClick(Sender: TObject);
        procedure OpenMenuClick(Sender: TObject);

        procedure StringGridKeyPress(Sender: TObject; var Key: Char);
        procedure StringGridKeyDown(Sender: TObject; var Key: Word;
          Shift: TShiftState);

        procedure StringGridSetEditText(Sender: TObject; ACol, ARow: Integer;
          const Value: string);
        procedure StringGridContextPopup(Sender: TObject; MousePos: TPoint;
          var Handled: Boolean);
        procedure StringGridMouseDown(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
    function FormHelp(Command: Word; Data: NativeInt;
      var CallHelp: Boolean): Boolean;


    private

        { Private declarations }
    public
        { Public declarations }
    end;

Const
    ERRORS: Array [ERRORS_LIST] Of String = ('',
      'Значение не попадает в диапазон!',
      'Проверьте корректность ввода данных!', 'Файл закрыт для чтения!',
      'Файл закрыт для записи!', 'Файл пуст!', 'Неверное число строк в файле',
      'Неверный порядок!');
    DIGITS = ['0' .. '9'];
    NO_ZERO_DIGITS = ['1' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_N = 1;
    MAX_N = 100;
    MIN_X = -100;
    MAX_X = 100;
    MAX_SIGNS = 4;
    LINES = 2;
    ALPHABET = ['A' .. 'Z', 'a' .. 'z'];

var
    MainTaskForm: TMainTaskForm;

implementation

{$R *.dfm}

Var
    Saved: Boolean = True;
    PerformCloseQuery: Boolean = True;
    CtrlPressed: Boolean = False;



procedure TMainTaskForm.DeveloperMenuClick(Sender: TObject);
Var
    DeveloperForm: TDeveloperForm;
begin
    DeveloperForm := TDeveloperForm.Create(Self);
    DeveloperForm.ShowModal;
    DeveloperForm.Free;
end;

procedure TMainTaskForm.FormCreate(Sender: TObject);
begin
    ResultButton.Enabled := False;
    TaskLabel.Caption :=
      'Данная программа проверяет является ли последовательность' + #13#10 + 'невозрастающей.';

end;

function TMainTaskForm.FormHelp(Command: Word; Data: NativeInt;
  var CallHelp: Boolean): Boolean;
begin
    CallHelp := False;
    InstructionMenuClick(Self)
end;

procedure TMainTaskForm.InstructionMenuClick(Sender: TObject);
Var
    InstructionForm: TInstructionForm;
begin
    InstructionForm := TInstructionForm.Create(Self);
    InstructionForm.ShowModal;
    InstructionForm.Free;
end;

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
Procedure FillArrayFromStringGrid(NumsStringGrid: TStringGrid;
  Var NumsArr: TArr);
Const
    NumsRow = 1;
Var
    I: Integer;
Begin
    SetLength(NumsArr, NumsStringGrid.ColCount);
    For I := 0 To High(NumsArr) Do
        NumsArr[I] := StrtoInt(NumsStringGrid.Cells[I, NumsRow]);
End;
procedure TMainTaskForm.EnterNEditContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
    Handled := True;
end;
/////////////////////////////////////
Procedure IsSequenceNonGrowing(StringGrid: TStringGrid);
Var
    NonGrowing: Boolean;
    Ind: Integer;
    Arr: TArr;
Begin
    NonGrowing := True;
    FillArrayFromStringGrid(StringGrid, Arr);


    NonGrowing := True;
    For Ind := 0 To (High(Arr)- 1) Do
    Begin
        If Arr[Ind] < Arr[Ind + 1] Then
        Begin
            NonGrowing := False;

        End;
    End;
    if NonGrowing then
         MainTaskForm.OutEdit.Text := 'Последовательность является невозрастающей.'
    Else
        MainTaskForm.OutEdit.Text := 'Последовательность не является невозрастающей.'
End;


Procedure GiveZeroOrNone(Edit: TEdit);
Var
    Num: Double;
Begin
    if TryStrToFloat(Edit.Text, Num) And (Num = 0) then
        Edit.Text := '0';
    If (Length(Edit.Text) > 0) And (Edit.Text[1] = ',') Then
        Edit.Text := '';
End;

procedure TMainTaskForm.EnterNEditExit(Sender: TObject);
begin
    GiveZeroOrNone(EnterNEdit);
end;

Function IsCorrectRange(Value: Integer; Const MIN, MAX: Real): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
Begin
    ERRORS := CORRECT;

    if ((Value < MIN) Or (Value > MAX)) then
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
    while Not EOF(F) do
    Begin
        Readln(F, Str);
        Inc(I);
    End;
    CloseFile(F);
    if I <> NUM_OF_LINES then
        Error := LINE_ERR;
    CheckNumOfLines := Error;
End;

Function GoodNum(Var F: TextFile; Const MAX, MIN: Integer): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
    Value: Integer;
Begin
    While (ERRORS = CORRECT) And Not EOLN(F) Do
    Begin
        Try
            Read(F, Value);
        Except
            ERRORS := NUM_ERR;
        End;
        If ERRORS = CORRECT Then
            ERRORS := IsCorrectRange(Value, MIN_X, MAX_X)
    End;
End;

Function CheckFileData(Var F: TextFile): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
    Value: Integer;
    Num, I: Integer;
Begin
    ERRORS := CORRECT;
    Reset(F);

    while (ERRORS = CORRECT) And Not EOLN(F) do
    Begin

        try
            Read(F, Value);
        Except
            ERRORS := NUM_ERR;
        end;
        If ERRORS = CORRECT Then
            ERRORS := IsCorrectRange(Value, MIN_X, MAX_X);

    End;

    Num := Value;
    Readln(F);

    while (ERRORS = CORRECT) And Not EOLN(F) do
    Begin

        try
            Read(F, Value);
        Except
            ERRORS := NUM_ERR;
        end;
        ERRORS := IsCorrectRange(Value, MIN_X, MAX_X);
        Inc(I);
    End;
    if ((I) <> Num) And (ERRORS = CORRECT) then
        ERRORS := ORDER_ERR;

    CloseFile(F);
    CheckFileData := ERRORS;
End;

Procedure TMainTaskForm.GetDataFromFile(Var F: TextFile; Sender: TObject);
Var
    NumStr: String;
    Num, I: Integer;
Begin
    I := 0;
    Reset(F);
    Readln(F, NumStr);
    EnterNEdit.Text := NumStr;
    While Not EOLN(F) Do
    Begin
        Read(F, Num);
        StringGrid.Cells[I, 1] := IntToStr(Num);
        Inc(I);
    End;
    CloseFile(F);
End;

// допилить несколько чисел
Function TMainTaskForm.FileReading(Var F: TextFile): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
Begin
    ERRORS := CORRECT;
    Reset(F);
    if EOF(F) then
        ERRORS := FILE_EMPTY;
    CloseFile(F);
    if (ERRORS = CORRECT) then
        ERRORS := CheckNumOfLines(F, LINES);
    if (ERRORS = CORRECT) then
        ERRORS := CheckFileData(F);
    if (ERRORS = CORRECT) then
        GetDataFromFile(F, Self);

    FileReading := ERRORS;
End;

procedure TMainTaskForm.OpenMenuClick(Sender: TObject);
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

procedure TMainTaskForm.OutEditChange(Sender: TObject);
begin

    if OutEdit.Text = '' then
    Begin
        Saved := True;
        SaveMenu.Enabled := False;
        OutEdit.Enabled := False;
    End
    Else
    Begin
        Saved := False;
        SaveMenu.Enabled := True;
        OutEdit.Enabled := True;
    End;

End;



Procedure FillGrid(ColNum: Integer; Grid: TStringGrid);
Var
    I, J: Integer;
    NumArr: TArr;
Begin
    SetLength(NumArr, ColNum);
    If ColNum > 5 Then
    Begin
        Grid.Width := (Grid.DefaultColWidth + 3) * 5;
        Grid.Height := Grid.DefaultRowHeight * 3;
    End
    Else
    Begin
        Grid.Width := (Grid.DefaultColWidth + 3) * ColNum;
        Grid.Height := (Grid.DefaultRowHeight + 4) * 2;
    End;
    Grid.Enabled := True;
    Grid.ColCount := ColNum;

    For I := 0 To ColNum - 1 Do
    Begin
        Grid.Cells[I, 0] := IntToStr(I + 1);
    End;
End;

Procedure ClearGrid(Grid: TStringGrid);
Var
    J, I: Integer;
Begin
    For I := 0 To Grid.ColCount - 1 Do
        For J := 0 To Grid.RowCount - 1 Do
            Grid.Cells[I, J] := '';
    Grid.ColCount := 0;
    Grid.Enabled := False;
End;

procedure TMainTaskForm.EnterNEditChange(Sender: TObject);
Var
    ArrayLength: Integer;
begin

    OutEdit.Text := '';

    If (EnterNEdit.Text = '') Or (EnterNEdit.Text = '1') Then
    Begin

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
        FillGrid(StrtoInt(EnterNEdit.Text), StringGrid);
    End;

end;

procedure TMainTaskForm.SaveMenuClick(Sender: TObject);
Var
    Error: ERRORS_LIST;
    F: TextFile;
    FileName: String;
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

procedure TMainTaskForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
                mrYes:
                    Begin
                        SaveMenuClick(Sender);
                        If Saved = True Then
                            CanClose := True
                        Else
                            FormCloseQuery(Sender, CanClose);
                    End;
                mrNo:
                    CanClose := True;
                mrCancel:
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

procedure TMainTaskForm.QuitMenuClick(Sender: TObject);
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
            mrYes:
                Begin
                    SaveMenuClick(Sender);
                    If Saved = True Then
                        Close
                    Else
                        QuitMenuClick(Sender);
                End;
            mrNo:
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

var
    Value: Integer;
    ERRORS: ERRORS_LIST;
begin
    Value := 0;
    ERRORS := CORRECT;
    if TryStrToInt(Text + Key, Value) then
    Begin
        ERRORS := IsCorrectRange(Value, MIN, MAX);
        if ERRORS <> CORRECT then
        Begin
            Key := #0;
        End;
    End;
end;

Procedure CheckComboButtons(Var Key: Char; Edit: TEdit);
Begin
    if (Key = #22) or ((Key = 'v') and (GetKeyState(VK_CONTROL) < 0)) then
        Key := #0;
    If Not CharInSet(Key, DIGITS) And (Key <> #8) Then
        Key := #0;

End;

Procedure CheckShftAndArrows(var Key: Word; Shift: TShiftState);
Begin
    if (Key = VK_INSERT) and (Shift = [ssShift]) then
        Key := 0;
    If (Key = VK_LEFT) Or (Key = VK_UP) Then
        Key := 0
    Else If (Key = VK_RIGHT) Or (Key = VK_DOWN) Then
        Key := 0;
End;

procedure TMainTaskForm.EnterNEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    CheckShftAndArrows(Key, Shift);
end;

procedure TMainTaskForm.EnterNEditKeyPress(Sender: TObject; var Key: Char);
begin
    CheckComboButtons(Key, EnterNEdit);
    CheckInput(EnterNEdit.Text, Key, MIN_N, MAX_N);
end;

Procedure BlockClick(Edit: TEdit);
Begin
    If Edit.SelStart <> Length(Edit.Text) Then
        Edit.SelStart := Length(Edit.Text);
End;

procedure TMainTaskForm.EnterNEditClick(Sender: TObject);
begin
    BlockClick(EnterNEdit);
end;

Function IsGridFull(StringGrid: TStringGrid): Boolean;
var
    I, J, EmptyCount: Integer;
begin
    EmptyCount := 0;
    For I := 0 to StringGrid.ColCount - 1 do
    begin

        begin
            if StringGrid.Cells[I, 1] = '' then
                Inc(EmptyCount);
        end;
    end;
    Result := EmptyCount = 0;
end;

procedure TMainTaskForm.ResultButtonClick(Sender: TObject);
begin
    IsSequenceNonGrowing(StringGrid);
end;

Procedure CheckComboButtonsGrid(Var Key: Char; StringGrid: TEStringGrid);

Begin
    if (Key = #22) or ((Key = 'v') and (GetKeyState(VK_CONTROL) < 0)) then
        Key := NONE;
    If Not CharInSet(Key, DIGITS) And (Key <> #8) And (Key <> '-') Then
        Key := NONE;
    if (Pos('-', StringGrid.Cells[StringGrid.Col, StringGrid.Row]) = 1) And
      (StringGrid.InplaceEditor.SelStart = 0) then
        Key := NONE;
    if (Key = '0') And (Length(StringGrid.Cells[StringGrid.Col, StringGrid.Row])
      > 0) And (StringGrid.InplaceEditor.SelStart = 0) then
        Key := #0;
    if (StringGrid.Cells[StringGrid.Col, StringGrid.Row] = '-') And
      ((Not CharInSet(Key, NO_ZERO_DIGITS)) Or (Key = '-')) And
      (Key <> BACKSPACE) then
        Key := #0;
    if (Key = '-') And (StringGrid.InplaceEditor.SelStart > 0) then
        Key := NONE;
    if (Pos('-', StringGrid.Cells[StringGrid.Col, StringGrid.Row]) = 1) And
      (StringGrid.InplaceEditor.SelStart = 0) And (Key = '0') then
        Key := NONE;
    if (Length(StringGrid.Cells[StringGrid.Col, StringGrid.Row]) > 0) and
      (StringGrid.Cells[StringGrid.Col, StringGrid.Row] = '0') And
      (Key <> BACKSPACE) Then
    begin
        Key := NONE;
    end;
End;

procedure TMainTaskForm.StringGridSetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: string);
begin
    if IsGridFull(StringGrid) And (EnterNEdit.Text <> '') Then
        ResultButton.Enabled := True
    Else
        ResultButton.Enabled := False;
    if Not IsGridFull(StringGrid) then
        OutEdit.Text := '';
end;

procedure TMainTaskForm.StringGridContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
Var
    PopGrid: TEStringGrid;
begin
    Handled := True;
    PopGrid := TEStringGrid(Sender);
    PopGrid.PopupMenu := Nil;

end;

procedure TMainTaskForm.StringGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Var
    NumsGrid: TEStringGrid;
    SelStart, SelLength: Integer;
    Text: String;
begin
    NumsGrid := TEStringGrid(Sender);
    CheckShftAndArrows(Key, Shift);

End;

procedure TMainTaskForm.StringGridKeyPress(Sender: TObject; var Key: Char);
Var
    NumsGrid: TEStringGrid;
    SelStart, SelLength: Integer;
    Text: String;
Begin
    NumsGrid := TEStringGrid(Sender);
    CheckComboButtonsGrid(Key, NumsGrid);
    CheckInput(StringGrid.Cells[StringGrid.Col, StringGrid.Row], Key,
      MIN_X, MAX_X);

    NumsGrid := TEStringGrid(Sender);
    If Assigned(NumsGrid.InplaceEditor) Then
    Begin
        SelStart := NumsGrid.InplaceEditor.SelStart;
        SelLength := NumsGrid.InplaceEditor.SelLength;
        Text := NumsGrid.InplaceEditor.Text;
    End;

end;

procedure TMainTaskForm.StringGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if Button = mbRight then
    Begin
        StringGrid.Perform(WM_CANCELMODE, 0, 0);
        Abort;
    End;

end;

end.
