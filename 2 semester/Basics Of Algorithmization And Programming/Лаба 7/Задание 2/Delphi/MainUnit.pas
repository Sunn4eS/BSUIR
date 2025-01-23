Unit MainUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
    Vcl.Menus, InstructionUnit, DeveloperUnit, Vcl.StdCtrls,
    Vcl.Grids, Vcl.Imaging.Pngimage, Vcl.ExtCtrls;

Type
    ERRORS_CODE = (CORRECT, INCORRECT_RANGE, EXTRA_DATA, IS_NOT_READABLE,
      IS_NOT_WRITEABLE, INCORRECT_DATA_IN_FILE, INCORRECT_NUMS_AMOUNT);

    TStringGridEdit = Class(TStringGrid);
    TMatrix = Array Of Array Of Integer;
    TArr = Array Of Integer;

    PVertex = ^TVertex;

    TVertex = Record
        Value: String;
        Next: PVertex;
    End;

Type
    TMainForm = Class(TForm)
        MainMenu1: TMainMenu;
        FileButton: TMenuItem;
        OpenFileButton: TMenuItem;
        SaveFileButton: TMenuItem;
        LineSeparator: TMenuItem;
        ExitButton: TMenuItem;
        InstructionButton: TMenuItem;
        DeveloperButton: TMenuItem;
        OpenFile: TOpenDialog;
        SaveFile: TSaveDialog;
        OrderEdit: TEdit;
        MatrixGrid: TStringGrid;
        ResultButton: TButton;
        OrderLabel: TLabel;
        MatrixGridLabel: TLabel;
        Task: TLabel;
        ResultGrid: TStringGrid;
        ResultLabel: TLabel;
        Function ReadFileData(Var F: TextFile; Sender: TObject): ERRORS_CODE;
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure InstructionButtonClick(Sender: TObject);
        Procedure SaveOnClick(Sender: TObject);
        Procedure DeveloperOnClick(Sender: TObject);
        Procedure ExitOnClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure OpenOnClick(Sender: TObject);
        Procedure OrderEditChange(Sender: TObject);
        Procedure OrderEditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure OrderEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure OrderEditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure MatrixGridKeyPress(Sender: TObject; Var Key: Char);
        Procedure MatrixGridKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure MatrixGridSetEditText(Sender: TObject; ACol, ARow: Integer;
          Const Value: String);
        Procedure ResultButtonClick(Sender: TObject);
        Procedure ResultEditChange(Sender: TObject);

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
    IsSaved: Boolean = True;
    VertexList: Array Of PVertex;

Const
    DIGITS = ['0' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    ERRORS: Array [ERRORS_CODE] Of String = ('',
      'Значение не попадает в диапазон!', 'Лишние данные в файле!',
      'Файл закрыт для чтения!', 'Файл закрыт для записи!',
      'Некорректный тип данных в файле!',
      'Неправильное количество чисел в файле!');
    MIN_N = 1;
    MAX_N = 9;
    MIN_NUM = 0;
    MAX_NUM = 1;

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

Procedure TMainForm.InstructionButtonClick(Sender: TObject);
Var
    InstructionForm: TInstructionForm;
Begin
    InstructionForm := TInstructionForm.Create(Self);
    InstructionForm.ShowModal;
    InstructionForm.Free;
End;

Procedure FillGrid(RowNum: Integer; Grid: TStringGrid);
Var
    I: Integer;
Begin
    Grid.ColCount := RowNum + 1;
    Grid.RowCount := RowNum + 1;
    If RowNum < 5 Then
    Begin
        Grid.Width := (Grid.DefaultColWidth + 4 - Grid.GridLineWidth) *
          Grid.ColCount;
        Grid.Height := (Grid.DefaultRowHeight + 4 - Grid.GridLineWidth) *
          Grid.RowCount;
    End
    Else
    Begin
        Grid.Width := (Grid.DefaultColWidth + 4 - Grid.GridLineWidth) * 5 + 32;
        Grid.Height := (Grid.DefaultRowHeight + 4 - Grid.GridLineWidth)
          * 5 + 32;
    End;

    Grid.Cells[0, 0] := '/';
    For I := 1 To RowNum Do
    Begin
        Grid.Cells[0, I] := IntToStr(I);
        Grid.Cells[I, 0] := IntToStr(I);
    End;
End;

Procedure ClearGrid(Grid: TStringGrid);
Var
    J, I: Integer;
Begin
    For I := 0 To Grid.ColCount - 1 Do
        For J := 0 To Grid.RowCount - 1 Do
            Grid.Cells[I, J] := '';
End;

Procedure CheckRightKeyPress(Var Key: Char; SelLength: Integer; Text: String;
  Const MIN, MAX: Integer);
Var
    IsValidInput: Boolean;
Begin
    IsValidInput := (CharInSet(Key, DIGITS) Or (Key = BACKSPACE)) And
      (Key <> '0');
    If (SelLength > 0) And (SelLength < Length(Text)) Then
        Key := NONE;
    If (IsValidInput) And (Key <> BACKSPACE) Then
        IsValidInput := IsValidRange(Text + Key, MIN, MAX);
    If Not IsValidInput Then
        Key := NONE;
End;

Procedure DeleteLists();
Var
    CurrentNode: PVertex;
    I: Integer;
Begin
    For I := 0 To Length(VertexList) - 1 Do
    Begin
        While VertexList[I].Next <> Nil Do
        Begin
            CurrentNode := VertexList[I].Next;
            VertexList[I].Next := CurrentNode.Next;
            Dispose(CurrentNode);
        End;
        Dispose(VertexList[I]);
    End;
    SetLength(VertexList, 0);
End;

Procedure TMainForm.OrderEditChange(Sender: TObject);
Var
    Num: Integer;
Begin
    If (OrderEdit.Text = '') Or Not TryStrToInt(OrderEdit.Text, Num) Then
    Begin
        MatrixGridLabel.Visible := False;
        MatrixGrid.Visible := False;
        ResultGrid.Visible := False;
        ResultLabel.Visible := False;
        ClearGrid(MatrixGrid);
    End
    Else
    Begin
        MatrixGridLabel.Visible := True;
        MatrixGrid.Visible := True;
        ClearGrid(MatrixGrid);
        FillGrid(StrToInt(OrderEdit.Text), MatrixGrid);
    End;
    If Length(VertexList) > 0 Then
        DeleteLists;
    SaveFileButton.Enabled := False;
    IsSaved := True;
    ResultButton.Enabled := False;
End;

Procedure TMainForm.OrderEditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure CheckRightKeyDown(Var Key: Word; Shift: TShiftState);
Begin
    If (Key = VK_DELETE) Then
        Key := 0;
    If ((SsShift In Shift) Or (SsCtrl In Shift)) And
      Not((Key = VK_RIGHT) Or (Key = VK_LEFT)) Then
        Key := 0;
End;

Procedure TMainForm.OrderEditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckRightKeyDown(Key, Shift);
End;

Procedure TMainForm.OrderEditKeyPress(Sender: TObject; Var Key: Char);
Var
    SelLength: Integer;
    Text: String;
Begin
    SelLength := OrderEdit.SelLength;
    Text := OrderEdit.Text;
    CheckRightKeyPress(Key, SelLength, Text, MIN_N, MAX_N);
End;

Procedure TMainForm.MatrixGridKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckRightKeyDown(Key, Shift);
End;

Function IsAllCellFill(Grid: TStringGrid): Boolean;
Var
    IsFilled: Boolean;
    Col, Row, Num: Integer;
Begin
    IsFilled := MainForm.OrderEdit.Text <> '';
    Row := 1;
    While IsFilled And (Row < Grid.RowCount) Do
    Begin
        Col := 1;
        While IsFilled And (Col < Grid.ColCount) Do
        Begin
            If (MainForm.MatrixGrid.Cells[Col, Row] = '') Or
              Not TryStrToInt(MainForm.MatrixGrid.Cells[Col, Row], Num) Then
                IsFilled := False;
            Inc(Col);
        End;
        Inc(Row);
    End;
    IsAllCellFill := IsFilled;
End;

Procedure TMainForm.MatrixGridKeyPress(Sender: TObject; Var Key: Char);
Var
    MatrixGrid: TStringGridEdit;
    Text: String;
Begin
    MatrixGrid := TStringGridEdit(Sender);
    If Assigned(MatrixGrid.InplaceEditor) Then
    Begin
        Text := MatrixGrid.InplaceEditor.Text;
        If (Length(Text) > 0) And (Key <> BACKSPACE) Then
            Key := NONE
        Else If (Key <> '1') And (Key <> '0') And (Key <> BACKSPACE) Then
            Key := NONE;
    End;
End;

Procedure TMainForm.MatrixGridSetEditText(Sender: TObject; ACol, ARow: Integer;
  Const Value: String);
Begin
    ResultButton.Enabled := IsAllCellFill(MatrixGrid);
    ClearGrid(ResultGrid);
    ResultGrid.Visible := False;
    ResultLabel.Visible := False;
    SaveFileButton.Enabled := False;
    IsSaved := True;
    If Length(VertexList) > 0 Then
        DeleteLists;
End;

Procedure TMainForm.ExitOnClick(Sender: TObject);
Begin
    Close;
End;

Procedure TMainForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
    Confirmation: Integer;
Begin
    If (IsSaved = False) Then
    Begin
        Confirmation := Application.MessageBox
          ('Вы не сохранили файл, хотите ли сохранить?', 'Выход',
          MB_YESNOCANCEl + MB_ICONQUESTION + MB_DEFBUTTON2);
        Case Confirmation Of
            MrYes:
                Begin
                    SaveOnClick(Sender);
                    If IsSaved = True Then
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
        Confirmation := Application.MessageBox('Вы действительно хотите выйти?',
          'Выход', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
        CanClose := Confirmation = IDYES;
    End;
End;

Function TMainForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

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

Function ReadFileNum(Var F: TextFile; Var Num: Integer; Const MIN, MAX: Integer)
  : ERRORS_CODE;
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

Function CheckSpaceInFile(BufStr: String): ERRORS_CODE;
Var
    I: Integer;
    Error: ERRORS_CODE;
Begin
    I := 1;
    Error := CORRECT;
    While (Error = CORRECT) And (I <= Length(BufStr)) Do
    Begin
        If BufStr[I] <> ' ' Then
            Error := EXTRA_DATA;
        Inc(I);
    End;
    CheckSpaceInFile := Error;
End;

Function TMainForm.ReadFileData(Var F: TextFile; Sender: TObject): ERRORS_CODE;
Var
    Error: ERRORS_CODE;
    Num, Order: Integer;
    Matrix: TMatrix;
    I, J: Integer;
    BufStr: String;
Begin
    I := 0;
    J := 0;
    Reset(F);
    Error := ReadFileNum(F, Num, MIN_N + 1, MAX_N);
    If Error = CORRECT Then
    Begin
        Readln(F, BufStr);
        Error := CheckSpaceInFile(BufStr);
    End;
    If Error = CORRECT Then
        OrderEdit.Text := IntToStr(Num);
    Order := Num;

    SetLength(Matrix, Order, Order);

    While (Error = CORRECT) And (I < Order) Do
    Begin
        J := 0;
        While (Error = CORRECT) And Not EOF(F) And (J < Order) Do
        Begin
            Error := ReadFileNum(F, Matrix[I, J], MIN_NUM, MAX_NUM);
            Inc(J);
        End;
        Readln(F, BufStr);
        Error := CheckSpaceInFile(BufStr);
        Inc(I);
    End;
    If (Error = CORRECT) And (J <> Order) Then
        Error := INCORRECT_NUMS_AMOUNT;

    If Error = CORRECT Then
    Begin
        FillGrid(Num, MatrixGrid);
        For I := 1 To MatrixGrid.RowCount - 1 Do
        Begin
            For J := 1 To MatrixGrid.ColCount - 1 Do
                MatrixGrid.Cells[J, I] := IntToStr(Matrix[I - 1, J - 1]);
        End;
        ResultButton.Enabled := True;
    End;
    CloseFile(F);
    ReadFileData := Error;
End;

Procedure CreateAdjacencyLists(Matrix: TMatrix);
Var
    I, J, K: Integer;
    Temp: PVertex;
Begin
    SetLength(VertexList, Length(Matrix));
    For I := 0 To Length(VertexList) - 1 Do
    Begin
        New(VertexList[I]);
        VertexList[I].Next := Nil;
        Temp := VertexList[I];
        For J := 0 To Length(Matrix) - 1 Do
        Begin
            New(Temp.Next);
            Temp := Temp.Next;
            Temp.Value := IntToStr(J + 1);
            Temp.Next := Nil;
        End;
    End;
End;

Procedure MakeResultGrid(RowNum: Integer; Grid: TStringGrid);
Begin
    Grid.ColCount := 2;
    Grid.RowCount := RowNum;
    Grid.ColWidths[0] := Grid.DefaultColWidth;
    Grid.ColWidths[1] := Grid.DefaultColWidth + 20 * RowNum;
    If RowNum < 4 Then
    Begin
        Grid.Height := (Grid.DefaultRowHeight + 4 - Grid.GridLineWidth) *
          Grid.RowCount + 2;
        Grid.Width := Grid.ColWidths[0] + Grid.ColWidths[1] + 10;
    End
    Else
    Begin
        Grid.Height := (Grid.DefaultRowHeight + 4 - Grid.GridLineWidth) * 3 + 2;
        Grid.Width := Grid.ColWidths[0] + Grid.ColWidths[1] + 42;
    End;
    Grid.Visible := True;
End;

Procedure FillResultGrid(RowNum: Integer; Grid: TStringGrid);
Var
    I: Integer;
    ResultStr: String;
    Temp: PVertex;
Begin
    For I := 0 To RowNum - 1 Do
    Begin
        ResultStr := '';
        Grid.Cells[0, I] := IntToStr(I + 1) + ':';
        Temp := VertexList[I];
        While Temp.Next <> Nil Do
        Begin
            If ResultStr <> '' Then
                ResultStr := ResultStr + ', ';
            ResultStr := ResultStr + Temp.Next.Value;
            Temp := Temp.Next;
        End;
        Grid.Cells[1, I] := ResultStr;
    End;
End;

Procedure TMainForm.ResultButtonClick(Sender: TObject);
Var
    Matrix: TMatrix;
    I, J: Integer;
Begin
    SetLength(Matrix, MatrixGrid.RowCount - 1, MatrixGrid.ColCount - 1);
    For I := 1 To MatrixGrid.RowCount - 1 Do
        For J := 1 To MatrixGrid.ColCount - 1 Do
            Matrix[I - 1][J - 1] := StrToInt(MatrixGrid.Cells[J, I]);
    CreateAdjacencyLists(Matrix);
    MakeResultGrid(MatrixGrid.RowCount - 1, ResultGrid);
    FillResultGrid(MatrixGrid.RowCount - 1, ResultGrid);
    ResultLabel.Visible := True;
    IsSaved := False;
    SaveFileButton.Enabled := True;
End;

Procedure TMainForm.ResultEditChange(Sender: TObject);
Begin
    If ResultGrid.Visible = False Then
    Begin
        IsSaved := True;
        SaveFileButton.Enabled := False;
    End
    Else
    Begin
        IsSaved := False;
        SaveFileButton.Enabled := True;
    End;
End;

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
                Writeln(F, #13#10, 'Списки инцидентности: ');
                For I := 0 To Length(VertexList) - 1 Do
                    Writeln(F, IntToStr(I + 1) + ': ' + ResultGrid.Cells[1, I]);
                CloseFile(F);
                IsSaved := True;
            End
            Else
            Begin
                Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка',
                  MB_OK Or MB_ICONINFORMATION);
                IsSaved := False;
            End;
        End
        Else
        Begin
            Rewrite(F);
            Writeln(F, 'Списки инцидентности: ');
            For I := 0 To Length(VertexList) - 1 Do
                Writeln(F, Chr(Ord('A') + I) + ': ' + ResultGrid.Cells[1, I]);
            CloseFile(F);
            IsSaved := True;
        End;
    End;
End;

End.
