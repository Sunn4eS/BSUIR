unit MainForm;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, clipbrd,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
    Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.Grids;

type
    TEStringGrid = Class(TStringGrid);
    TMatrix = Array Of Array Of Integer;
    TVector = Array [1 .. 2] Of Array [1 .. 2] of Real;
    ERRORS_LIST = (CORRECT, RANGE_ERR, NUM_ERR, NOT_READABLE, NOT_WRITEABLE,
      FILE_EMPTY, LINE_ERR, ORDER_ERR, SAME_COORD, CROSS_SIDE, ON_ONE_SIDE,
      NOT_CONVEX);

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
        EnterNLabel: TLabel;
        ArrLabel: TLabel;
        SaveTextFile: TSaveTextFileDialog;
        StringGrid: TStringGrid;
    OutGrid: TStringGrid;
    OutLabel: TLabel;
    OutEdit: TEdit;
    EnterMEdit: TEdit;
    InputPlaceGrid: TStringGrid;
        procedure DeveloperMenuClick(Sender: TObject);
        procedure InstructionMenuClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure EnterNEditContextPopup(Sender: TObject; MousePos: TPoint;
          var Handled: Boolean);

        Procedure GetDataFromFile(Var F: TextFile; Sender: TObject);
        Function FileReading(Var F: TextFile): ERRORS_LIST;
        procedure ResultButtonClick(Sender: TObject);

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
        procedure StringGridMouseActivate(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y, HitTest: Integer;
          var MouseActivate: TMouseActivate);
        function FormHelp(Command: Word; Data: NativeInt;
          var CallHelp: Boolean): Boolean;
        Procedure CheckEditContent (Edit1, Edit2: TEdit);
    procedure EnterMEditChange(Sender: TObject);
    procedure EnterMEditClick(Sender: TObject);
    procedure EnterMEditContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure EnterMEditExit(Sender: TObject);
    procedure EnterMEditKeyPress(Sender: TObject; var Key: Char);
    procedure EnterMEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure InputPlaceGridKeyPress(Sender: TObject; var Key: Char);
    procedure InputPlaceGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure InputPlaceGridMouseActivate(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate);
    procedure InputPlaceGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);

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
      'Неверный порядок матрицы!', 'Введенные координаты равны!',
      'Стороны многоугольника пересекаются!',
      'Стороны многоугольника лежат на одной прямой!',
      'Многоугольник не является выпуклым!');
    DIGITS = ['0' .. '9'];
    NO_ZERO_DIGITS = ['1' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_N = 1;
    MAX_N = 10;
    MIN_X = -100;
    MAX_X = 100;
    MAX_SIGNS = 4;

    ALPHABET = ['A' .. 'Z', 'a' .. 'z'];
    MIN_F = 3;
    MAX_F = 20;

    Length_Of_Arr = 2;

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



procedure TMainTaskForm.InstructionMenuClick(Sender: TObject);
Var
    InstructionForm: TInstructionForm;
begin
    InstructionForm := TInstructionForm.Create(Self);
    InstructionForm.ShowModal;
    InstructionForm.Free;
end;

procedure TMainTaskForm.FormCreate(Sender: TObject);
begin
    ResultButton.Enabled := False;
    TaskLabel.Caption := '';

end;

function TMainTaskForm.FormHelp(Command: Word; Data: NativeInt;
  var CallHelp: Boolean): Boolean;
begin
    CallHelp := False;
    InstructionMenuClick(Self);
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

procedure TMainTaskForm.EnterNEditContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
    Handled := True;
end;

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
    Num, I, J, Cols, Rows: Integer;
     Str, Mark: String;
    Numbers: TArray<String>;
Begin
    ERRORS := CORRECT;
    J := 0;
    I := 0;
    Reset(F);

    while (ERRORS = CORRECT) And Not EOLN(F) do
    Begin

        try
            Read(F, Value);
        Except
            ERRORS := NUM_ERR;
        end;
        If ERRORS = CORRECT Then
            ERRORS := IsCorrectRange(Value, MIN_F, MAX_F);
    End;

    Num := Value;
    Readln(F);
    While (ERRORS = CORRECT) And (Not EOF(F)) Do
    Begin
        while (ERRORS = CORRECT) And Not EOLN(F) do
        Begin

           Read(F, Str);
            Str := Trim(Str);
            Numbers := Str.Split([' ']);
            for Mark In Numbers do
            begin
                if TryStrToInt(Mark, Value) then
                Begin
                    ERRORS := IsCorrectRange(Value, MIN_X, MAX_X);
                End
                Else
                    ERRORS := NUM_ERR;
                Inc(I);
            end;
        End;
        if (I <> Num) then
            ERRORS := ORDER_ERR;
        I := 0;
        Readln(F);
        Inc(J);
    End;
    if ((I) <> Num) And (ERRORS = CORRECT) And (J <> Num) then
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
    EnterNEdit.Text := NumStr;
    While Not EOF(F) Do
    Begin
        while Not EOLN(F) do
        Begin
              Read(F, NumStr);
            NumStr := Trim(NumStr);
            Numbers := NumStr.Split([' ']);
            for Mark In Numbers do
            begin
                if TryStrToInt(Mark, Num) then
                Begin
                    StringGrid.Cells[I , J] := IntToStr(Num);
                End;
                Inc(I);
            end;
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
    if EOF(F) then
        ERRORS := FILE_EMPTY;
    CloseFile(F);
//    if (ERRORS = CORRECT) then
//        ERRORS := CheckNumOfLines(F);
    if (ERRORS = CORRECT) then
        ERRORS := CheckFileData(F);
    if (ERRORS = CORRECT) then
        GetDataFromFile(F, Self);
    if ERRORS = CORRECT then
        ResultButton.Enabled := True;
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

Function FillArrayFromStringGrid(CoordGrid: TStringGrid): TMatrix;
Const
    NumsRow = 1;
Var
    I: Integer;
    CoordArr: TMatrix;
    J: Integer;
Begin
    SetLength(CoordArr, CoordGrid.ColCount, CoordGrid.RowCount);

    For I := 0 To CoordGrid.ColCount - 1 Do
    Begin
        for J := 0 to CoordGrid.RowCount - 1 do
        Begin
            CoordArr[I, J] := StrtoInt(CoordGrid.Cells[J, I]);
        End;
    End;
    Result := CoordArr;
End;

Procedure FillGridFromMatrix (ResMatrix: TMatrix; OutGrid: TStringGrid);
Var
    I, J: Integer;
Begin
    For J := 0 To High(ResMatrix) Do
    Begin
        for I := 0 to High(ResMatrix) do
        Begin
            OutGrid.Cells[I, J] := IntToStr(ResMatrix[J, I]);
        End;
    End;
End;

Procedure FillGrid(NOrder, MOrder: Integer; Grid: TStringGrid);
Var
    I, J: Integer;
    NumArr: TMatrix;
Begin

    If MOrder > 4 Then
    Begin
        Grid.Width := (Grid.DefaultColWidth + 3) * 4;
        Grid.Height := Grid.DefaultRowHeight * 4;
    End
    Else
    Begin
        Grid.Width := (Grid.DefaultColWidth) * MOrder;
        Grid.Height := (Grid.DefaultRowHeight * (MOrder + 1));
    End;
    Grid.Enabled := True;
    Grid.ColCount := MOrder;
    Grid.RowCount := NOrder;
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

Procedure CreateMatrixOfOccurrences(Var OccMatrix: TMatrix);
var
    I, J: Integer;
Begin
    for I := 0 to MainTaskForm.StringGrid.RowCount do
        for J := 0 to MainTaskForm.StringGrid.ColCount do
            OccMatrix[I, J] := 0;
End;

Procedure TraversingMatrix (Matrix: TMatrix; I, J: Integer);
//Var
   // I, J: Integer;
Begin


End;


Procedure MainFunction();
Var
    Matrix, OccMatrix: TMatrix;
Begin
    Matrix := FillArrayFromStringGrid(MainTaskForm.StringGrid);
    CreateMatrixOfOccurrences(OccMatrix);

End;

Procedure TMainTaskForm.CheckEditContent (Edit1, Edit2: TEdit );
Begin
    if (Edit1.Text = '') Or (Edit1.Text = '1') Or (Edit2.Text = '') Or (Edit2.Text = '1') then
    Begin
        Saved := True;
        SaveMenu.Enabled := False;
        StringGrid.Visible := False;
        InputPlaceGrid.Visible := False;
        ClearGrid(StringGrid);
        ClearGrid(OutGrid);
        ClearGrid(InputPlaceGrid);
        ResultButton.Enabled := False;
    End
    Else
    Begin
        StringGrid.Visible := True;
        ClearGrid(OutGrid);
        ClearGrid(StringGrid);
        FillGrid(StrtoInt(Edit1.Text),StrtoInt(Edit2.Text),  StringGrid);
    End;

End;

procedure TMainTaskForm.EnterMEditChange(Sender: TObject);
begin
    CheckEditContent(EnterNEdit, EnterMEdit);
end;

Procedure BlockClick(Edit: TEdit);
Begin
    If Edit.SelStart <> Length(Edit.Text) Then
        Edit.SelStart := Length(Edit.Text);
End;

procedure TMainTaskForm.EnterMEditClick(Sender: TObject);
begin
    BlockClick(EnterMEdit);
end;

procedure TMainTaskForm.EnterMEditContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
    Handled := True;
end;

procedure TMainTaskForm.EnterMEditExit(Sender: TObject);
begin
    GiveZeroOrNone(EnterMEdit);
end;

procedure TMainTaskForm.EnterNEditChange(Sender: TObject);

begin
    CheckEditContent(EnterNEdit, EnterMEdit);
end;

procedure TMainTaskForm.SaveMenuClick(Sender: TObject);
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
                for I := 0 to OutGrid.ColCount do
                Begin
                    for J := 0 to OutGrid.ColCount do
                    Begin
                        Write(F, OutGrid.Cells[I, J], ' ');
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
              for I := 0 to OutGrid.ColCount do
              Begin
                    for J := 0 to OutGrid.ColCount do
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

procedure TMainTaskForm.EnterNEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    CheckShftAndArrows(Key, Shift);
end;

procedure TMainTaskForm.EnterNEditKeyPress(Sender: TObject; var Key: Char);
begin
    CheckComboButtons(Key, EnterNEdit);
    CheckInput(EnterNEdit.Text, Key, MIN_N, MAX_N);
end;

procedure TMainTaskForm.EnterMEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    CheckShftAndArrows(Key, Shift);
end;

procedure TMainTaskForm.EnterMEditKeyPress(Sender: TObject; var Key: Char);
begin
    CheckComboButtons(Key, EnterMEdit);
    CheckInput(EnterMEdit.Text, Key, MIN_N, MAX_N);
end;

procedure TMainTaskForm.EnterNEditClick(Sender: TObject);
begin
    BlockClick(EnterNEdit);
end;

Function IsGridFull(StringGrid: TStringGrid; From, Till: Integer): Boolean;
var
    I, J, EmptyCount: Integer;
begin
    EmptyCount := 0;
    For I := From to Till do
    begin
        For J := From to Till do
        begin
            if (StringGrid.Cells[I, J] = '') Or (StringGrid.Cells[I, J] = '-') then
                Inc(EmptyCount);
        end;
    end;
    Result := EmptyCount = 0;
end;

procedure TMainTaskForm.ResultButtonClick(Sender: TObject);
Var
    ResMatrix: TMatrix;
    NumsGrid: TEStringGrid;
begin

    FillGrid(StringGrid.ColCount, StringGrid.RowCount, OutGrid);
   // ResMatrix := SortMatrix(StringGrid.ColCount);
    FillGridFromMatrix(ResMatrix, OutGrid) ;
    //OutGrid.InplaceEditor.ReadOnly := True;
    OutGrid.Visible := True;
    OutGrid.Enabled := True;
    Saved := False;
    SaveMenu.Enabled := True;

    if Not IsGridFull(OutGrid, 0, OutGrid.ColCount - 1) then
    Begin
        Saved := True;
        SaveMenu.Enabled := False;
    End
    Else
    Begin
        Saved := False;
        SaveMenu.Enabled := True;
    End;
   // OutGrid.FixedCols := StringGrid.ColCount;
   // OutGrid.FixedRows := StringGrid.RowCount;

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
        Key := NONE;
    if (StringGrid.Cells[StringGrid.Col, StringGrid.Row] = '-') And
      ((Not CharInSet(Key, NO_ZERO_DIGITS)) Or (Key = '-')) And
      (Key <> BACKSPACE) then
        Key := NONE;
    if (Key = '-') And (StringGrid.InplaceEditor.SelStart > 0) then
        Key := NONE;
    if (Pos('-', StringGrid.Cells[StringGrid.Col, StringGrid.Row]) = 1) And
      (StringGrid.InplaceEditor.SelStart = 0) And (Key = '0') then
        Key := NONE;
    if (Length(StringGrid.Cells[StringGrid.Col, StringGrid.Row]) > 0) and
      (StringGrid.Cells[StringGrid.Col, StringGrid.Row] = '0') And
      (Key <> BACKSPACE) Then
        Key := NONE;
    if (StringGrid.Cells[StringGrid.Col, StringGrid.Row] <> '') And (StringGrid.InplaceEditor.SelStart = 0) And (Key = #8) then
        Key := NONE;

End;

Procedure CanPressButton (StringGrid: TStringGrid);
Begin
    if IsGridFull(StringGrid, 0, StringGrid.ColCount - 1) And (MainTaskForm.EnterNEdit.Text <> '') And (MainTaskForm.EnterMEdit.Text <> '') Then
        MainTaskForm.ResultButton.Enabled := True
    Else
        MainTaskForm.ResultButton.Enabled := False;
End;

procedure TMainTaskForm.StringGridSetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: string);
begin
    CanPressButton (StringGrid);
end;

Procedure CheckCoordsOfInputGrid(InputPlaceGrid: TStringGrid; Key: Char; Const MAX: Integer);


var
    Value: Integer;
    I1, I2, J1, J2: Integer;
    ERRORS: ERRORS_LIST;
    MAX_N_ROW, MAX_M_COL, MIN_N_ROW, MIN_M_COL: Integer;
begin
    ERRORS := CORRECT;

    MAX_N_ROW := StrToInt(MainTaskForm.EnterNEdit.Text);
    MAX_M_COL := StrToInt(MainTaskForm.EnterMEdit.Text);
    MIN_M_COL := 0;
    MIN_N_ROW := 0;

    I1 := StrToInt(InputPlaceGrid.Cells[1,1]);
    J1 := StrToInt(InputPlaceGrid.Cells[2,1]);

    I2 := StrToInt(InputPlaceGrid.Cells[1,2]);
    J2 := StrToInt(InputPlaceGrid.Cells[2,2]);

    ERRORS := IsCorrectRange(I1, MIN_N_ROW, MAX_N_ROW);
    if (InputPlaceGrid.Col = 1) then
    Begin
        If CORRECT <> IsCorrectRange(StrToInt(InputPlaceGrid.Cells[InputPlaceGrid.Col, InputPlaceGrid.Row]), 0, MAX_N_ROW) Then
            Key := NONE;
    End;

    if (InputPlaceGrid.Col = 2) then
    Begin
        If CORRECT <> IsCorrectRange(StrToInt(InputPlaceGrid.Cells[InputPlaceGrid.Col, InputPlaceGrid.Row]), 0, MAX_M_COL) Then
            Key := NONE;
    End;



end;

procedure TMainTaskForm.InputPlaceGridKeyPress(Sender: TObject; var Key: Char);
Var
    NumsGrid: TEStringGrid;
    Value: Integer;
    Text: String;
Begin
    NumsGrid := TEStringGrid(Sender);
    CheckComboButtonsGrid(Key, NumsGrid);
    Value := StrToInt(InputPlaceGrid.Cells[InputPlaceGrid.Col, InputPlaceGrid.Row]);
    CheckCoordsOfInputGrid (InputPlaceGrid, Key, StrToInt(EnterMEdit.Text));
end;

procedure TMainTaskForm.InputPlaceGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
    CanPressButton (InputPlaceGrid);

end;

procedure TMainTaskForm.StringGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
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
end;

procedure TMainTaskForm.InputPlaceGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    CheckShftAndArrows(Key, Shift);
end;


procedure TMainTaskForm.InputPlaceGridMouseActivate(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin
    Clipboard.clear;
end;



procedure TMainTaskForm.StringGridMouseActivate(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin
    Clipboard.clear;
end;

end.
