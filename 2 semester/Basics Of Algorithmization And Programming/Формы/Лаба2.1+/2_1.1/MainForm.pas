unit MainForm;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, clipbrd,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
    Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.Grids;

type
    TEStringGrid = Class(TStringGrid);
    TArr = Array Of Array Of Integer;
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
        procedure StringGridMouseActivate(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y, HitTest: Integer;
          var MouseActivate: TMouseActivate);
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
      'Неверный порядок!', 'Введенные координаты равны!',
      'Стороны многоугольника пересекаются!',
      'Стороны многоугольника лежат на одной прямой!',
      'Многоугольник не является выпуклым!');
    DIGITS = ['0' .. '9'];
    NO_ZERO_DIGITS = ['1' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_N = 1;
    MAX_N = 20;
    MIN_X = -100;
    MAX_X = 100;
    MAX_SIGNS = 4;
    LINES = 3;
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

procedure TMainTaskForm.FormCreate(Sender: TObject);
begin
    ResultButton.Enabled := False;
    TaskLabel.Caption :=
      'Данная программа вычисляет площать многоугольника' + #13#10;

end;

function TMainTaskForm.FormHelp(Command: Word; Data: NativeInt;
  var CallHelp: Boolean): Boolean;
begin
    CallHelp := False;
    InstructionMenuClick(Self);
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
Begin
    ERRORS := CORRECT;
    J := 1;
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

            try
                Read(F, Value);
            Except
                ERRORS := NUM_ERR;
            end;
            ERRORS := IsCorrectRange(Value, MIN_X, MAX_X);
            Inc(I);
        End;
        if (I <> Num) then
            ERRORS := ORDER_ERR;
        I := 0;
        Readln(F);
        Inc(J);
    End;
    if ((I) <> Num) And (ERRORS = CORRECT) And (J <> LINES) then
        ERRORS := ORDER_ERR;

    CloseFile(F);
    CheckFileData := ERRORS;
End;

Procedure TMainTaskForm.GetDataFromFile(Var F: TextFile; Sender: TObject);
Var
    NumStr: String;
    Num, I, J: Integer;
Begin
    I := 1;
    J := 1;
    Reset(F);
    Readln(F, NumStr);
    EnterNEdit.Text := NumStr;
    { While Not EOLN(F) Do
      Begin
      Read(F, Num);
      StringGrid.Cells[I, 1] := IntToStr(Num);
      Inc(I);
      End; }

    While Not EOF(F) Do
    Begin
        while Not EOLN(F) do
        Begin
            Read(F, Num);
            StringGrid.Cells[I, J] := IntToStr(Num);
            Inc(I);
        End;
        I := 1;
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
    if (ERRORS = CORRECT) then
        ERRORS := CheckNumOfLines(F, LINES);
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

Function FillArrayFromStringGrid(CoordGrid: TStringGrid): TArr;
Const
    NumsRow = 1;
Var
    I: Integer;
    CoordArr: TArr;
    J: Integer;
Begin
    SetLength(CoordArr, CoordGrid.ColCount - 1, CoordGrid.RowCount - 1);

    For I := 1 To CoordGrid.ColCount - 1 Do
    Begin
        for J := 1 to CoordGrid.RowCount - 1 do
        Begin
            CoordArr[I - 1, J - 1] := StrtoInt(CoordGrid.Cells[I, J]);
        End;
    End;
    Result := CoordArr;
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
        Grid.Height := Grid.DefaultRowHeight * 4;
    End
    Else
    Begin
        Grid.Width := (Grid.DefaultColWidth + 3) * ColNum;
        Grid.Height := (Grid.DefaultRowHeight * 4);
    End;
    Grid.Enabled := True;
    Grid.ColCount := ColNum + 1;
    Grid.FixedCols := 1;
    Grid.Cells[0, 0] := '\';

    For I := 0 To ColNum - 1 Do
    Begin
        Grid.Cells[0, 2] := 'Y';
        Grid.Cells[I + 1, 0] := IntToStr(I + 1);
        Grid.Cells[0, 1] := 'X';
    End;
End;

Procedure ClearGrid(Grid: TStringGrid);
Var
    J, I: Integer;
Begin
    For I := 1 To Grid.ColCount Do
        For J := 1 To Grid.RowCount Do
            Grid.Cells[I, J] := '';
    Grid.ColCount := 0;
    Grid.Enabled := False;
End;

Procedure MainSquare();
Const
    LengthOfArr = 2;

Var
    N, I, J, SameLine1, SameLine2, SameCoordinate1, SameCoordinate2: Integer;
    Coordinates: TArr;
    Error: Errors_List;
    Vector: Array [1 .. 2] Of Array [1 .. 2] Of Real;
    IsCorrect, NotConvex, OnSameLine, Intersection, SameCoordinate: Boolean;
    CurrCrossProduct, PrevCrossProduct, X, MaxX, MinX, MAX_X_1, MIN_X_1, Max_Y, Min_Y, Mid_y, Mid_X, VectorMultiplication, SquareOfFigure: Real ;

Begin
    PrevCrossProduct := 0;
    NotConvex := True;
    OnSameLine := True;
    Intersection := False;
    N := StrtoInt(MainTaskForm.EnterNEdit.Text);
    Coordinates := FillArrayFromStringGrid(MainTaskForm.StringGrid);

   
    SameCoordinate := False;
    For I := Low(Coordinates) To High(Coordinates) Do
    // Проверка на совпадение координат
    Begin
        For J := I + 1 To High(Coordinates) Do
        Begin
            If (Coordinates[I, 0] = Coordinates[J, 0]) And
              (Coordinates[I, 1] = Coordinates[J, 1]) Then
            Begin
                SameCoordinate1 := I + 1;
                SameCoordinate2 := J + 1;
                Application.MessageBox
                  (PWideChar('Введенные координаты ' + IntToStr(SameCoordinate1)
                  + ' и ' + IntToStr(SameCoordinate2) + ' равны!'), 'Ошибка',
                  MB_OK Or MB_ICONINFORMATION);
            End;
        End;
    End;
    if Not SameCoordinate then
    Begin
        For I := Low(Coordinates) To High(Coordinates) Do
        // Проверка на пересечение сторон
        Begin
            For J := I + 2 To High(Coordinates) Do
            Begin
                Vector[1, 1] := Coordinates[(I + 1) Mod N, 0] - Coordinates
                  [I Mod N, 0]; // Длина вектора 1 по X
                Vector[1, 2] := Coordinates[(I + 1) Mod N, 1] - Coordinates
                  [I Mod N, 1]; // Длина вектора 1 по Y
                Vector[2, 1] := Coordinates[(J + 1) Mod N, 0] - Coordinates
                  [J Mod N, 0]; // Длина вектора 2 по X
                Vector[2, 2] := Coordinates[(J + 1) Mod N, 1] - Coordinates
                  [J Mod N, 1]; // Длина вектора 2 по Y
                CurrCrossProduct :=
                  (Vector[1, 1] * Vector[2, 2] - Vector[2, 1] * Vector[1, 2]);
                If CurrCrossProduct <> 0 Then
                Begin
                    X := (Coordinates[I Mod N, 0] * Vector[1, 2] * Vector[2, 1]
                      - // Формула прямой через 2 точки. Я приравнял Y у двух формул и выразил X
                      Coordinates[J Mod N, 0] * Vector[2, 2] * Vector[1, 1] +
                      Vector[1, 1] * Vector[2, 1] * (Coordinates[J Mod N,
                      1] - Coordinates[I Mod N, 1])) / -CurrCrossProduct;

                    If Coordinates[(I + 1) Mod N, 0] - Coordinates[I Mod N, 0]
                      = 0 Then // Проверка на нахождение в диапозоне 1
                    Begin
                        If Coordinates[(J + 1) Mod N, 0] > Coordinates
                          [J Mod N, 0] Then
                        Begin
                            MaxX := Coordinates[(J + 1) Mod N, 0];
                            MinX := Coordinates[J Mod N, 0];
                        End
                        Else
                        Begin
                            MaxX := Coordinates[J Mod N, 0];
                            MinX := Coordinates[(J + 1) Mod N, 0];
                        End;
                    End
                    Else // Проверка на нахождение в диапозоне 2
                    Begin
                        If Coordinates[(I + 1) Mod N, 0] > Coordinates
                          [I Mod N, 0] Then
                        Begin
                            MaxX := Coordinates[(I + 1) Mod N, 0];
                            MinX := Coordinates[I Mod N, 0];
                        End
                        Else
                        Begin
                            MaxX := Coordinates[I Mod N, 0];
                            MinX := Coordinates[(I + 1) Mod N, 0];
                        End;
                    End;
                    If (X > MinX) And (X < MaxX) Then
                        Intersection := True;
                End;
            End;
        End;

        If Intersection = True Then
            Application.MessageBox
              (PWideChar('Стороны многоугольника пересекаются!'), 'Ошибка',
              MB_OK Or MB_ICONINFORMATION);
        If Intersection = False Then
        Begin
            For I := Low(Coordinates) To High(Coordinates) Do
            // Проверка на выпуклость
            Begin
                Vector[1, 1] := Coordinates[(I + 1) Mod N, 0] - Coordinates
                  [I Mod N, 0]; // Длина вектора 1 по X
                Vector[1, 2] := Coordinates[(I + 1) Mod N, 1] - Coordinates
                  [I Mod N, 1]; // Длина вектора 1 по Y
                Vector[2, 1] := Coordinates[(I + 2) Mod N, 0] - Coordinates
                  [(I + 1) Mod N, 0]; // Длина вектора 2 по X
                Vector[2, 2] := Coordinates[(I + 2) Mod N, 1] - Coordinates
                  [(I + 1) Mod N, 1]; // Длина вектора 2 по Y
                CurrCrossProduct :=
                  (Vector[1, 1] * Vector[2, 2] - Vector[2, 1] * Vector[1, 2]);
                // X1*Y2-X2*Y1   Векторное произведение векторов
                If (CurrCrossProduct * PrevCrossProduct < 0) Then
                    NotConvex := False;
                If CurrCrossProduct = 0 Then
                // Проверяю чтобы стороны не лежали на одной прямой
                Begin
                    OnSameLine := False;
                    SameLine1 := I + 1;
                    SameLine2 := (I + 2) Mod N;
                End;
                PrevCrossProduct := CurrCrossProduct;
            End;
        End;

        If Intersection = False Then
        Begin
            If OnSameLine = False Then
                Application.MessageBox
                  (PWideChar('Cтороны ' + IntToStr(SameLine1) + ' и ' +
                  IntToStr(SameLine2) +
                  ' многоугольника лежат на одной прямой!'), 'Ошибка',
                  MB_OK Or MB_ICONINFORMATION)

        End;
    End;

    If (Not SameCoordinate) And (Error = CORRECT) Then
    Begin

        MAX_X_1 := Coordinates[0, 0];
        MIN_X_1 := Coordinates[0, 0];
        Max_Y := Coordinates[0, 1];
        Min_Y := Coordinates[0, 1];

        For I := Low(Coordinates) To High(Coordinates) Do
        Begin
            If Coordinates[I, 0] < MIN_X Then
                MIN_X_1 := Coordinates[I, 0];
            If Coordinates[I, 0] > MAX_X Then
                MAX_X_1 := Coordinates[I, 0];
            If Coordinates[I, 1] < Min_Y Then
                Min_Y := Coordinates[I, 1];
            If Coordinates[I, 1] > Max_Y Then
                Max_Y := Coordinates[I, 1];
        End;

        Mid_X := (MIN_X + MAX_X) / 2;
        Mid_Y := (Min_Y + Max_Y) / 2;

        For I := Low(Coordinates) To High(Coordinates) Do
        Begin
            Vector[1, 1] := Coordinates[(I + 1) Mod N, 0] - Mid_X;
            Vector[1, 2] := Coordinates[(I + 1) Mod N, 1] - Mid_Y;
            Vector[2, 1] := Coordinates[(I + 2) Mod N, 0] - Mid_X;
            Vector[2, 2] := Coordinates[(I + 2) Mod N, 1] - Mid_Y;
            VectorMultiplication :=  abs(Vector[1, 1] * Vector[2, 2] - Vector[2, 1] * Vector[1, 2]);

            SquareOfFigure := SquareOfFigure + (0.5 * (VectorMultiplication));
        End;

    End;
    If Error = CORRECT Then
    Begin
        MainTaskForm.OutEdit.Text :=
          ('Площадь многоугольника = ' + FloatToStr(SquareOfFigure));
    End
    Else
    Begin
        Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка',
          MB_OK Or MB_ICONINFORMATION);
    End;

    Coordinates := Nil;

End;

procedure TMainTaskForm.EnterNEditChange(Sender: TObject);
Var
    ArrayLength: Integer;
begin

    OutEdit.Text := '';

    If (EnterNEdit.Text = '') OR (EnterNEdit.Text = '1') Or
      (EnterNEdit.Text = '2') Then
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
        For J := 0 to StringGrid.RowCount - 1 do
        begin
            if (StringGrid.Cells[I, J] = '') Or (StringGrid.Cells[I, J] = '-') then
                Inc(EmptyCount);
        end;
    end;
    Result := EmptyCount = 0;
end;

procedure TMainTaskForm.ResultButtonClick(Sender: TObject);
begin
    MainSquare();
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
    if (StringGrid.Cells[StringGrid.Col, StringGrid.Row] <> '') And (StringGrid.InplaceEditor.SelStart = 0) And (Key = #8) then
        Key := #0;

End;

procedure TMainTaskForm.StringGridSetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: string);
begin
    if IsGridFull(StringGrid) And (EnterNEdit.Text <> '') Then
        ResultButton.Enabled := True
    Else
        ResultButton.Enabled := False;
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

procedure TMainTaskForm.StringGridMouseActivate(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin
    Clipboard.clear;
end;

end.
