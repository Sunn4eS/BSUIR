{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N-,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN SYMBOL_EXPERIMENTAL ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN UNIT_EXPERIMENTAL ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$WARN OPTION_TRUNCATED ON}
{$WARN WIDECHAR_REDUCED ON}
{$WARN DUPLICATES_IGNORED ON}
{$WARN UNIT_INIT_SEQ ON}
{$WARN LOCAL_PINVOKE ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN TYPEINFO_IMPLICITLY_ADDED ON}
{$WARN RLINK_WARNING ON}
{$WARN IMPLICIT_STRING_CAST ON}
{$WARN IMPLICIT_STRING_CAST_LOSS ON}
{$WARN EXPLICIT_STRING_CAST OFF}
{$WARN EXPLICIT_STRING_CAST_LOSS OFF}
{$WARN CVT_WCHAR_TO_ACHAR ON}
{$WARN CVT_NARROWING_STRING_LOST ON}
{$WARN CVT_ACHAR_TO_WCHAR ON}
{$WARN CVT_WIDENING_STRING_LOST ON}
{$WARN NON_PORTABLE_TYPECAST ON}
{$WARN XML_WHITESPACE_NOT_ALLOWED ON}
{$WARN XML_UNKNOWN_ENTITY ON}
{$WARN XML_INVALID_NAME_START ON}
{$WARN XML_INVALID_NAME ON}
{$WARN XML_EXPECTED_CHARACTER ON}
{$WARN XML_CREF_NO_RESOLVE ON}
{$WARN XML_NO_PARM ON}
{$WARN XML_NO_MATCHING_PARM ON}
{$WARN IMMUTABLE_STRINGS OFF}
unit MainForm;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, clipbrd,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
    Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.Grids;

type
    TEStringGrid = Class(TStringGrid);
    TArr = Array Of Array of Integer;
    TGood = Array of Integer;
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
        OutEdit: TEdit;
        ArrLabel: TLabel;
        OutLabel: TLabel;
        SaveTextFile: TSaveTextFileDialog;
        StringGrid: TStringGrid;
        procedure DeveloperMenuClick(Sender: TObject);
        procedure InstructionMenuClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
       // procedure EnterNEditContextPopup(Sender: TObject; MousePos: TPoint;
       //   var Handled: Boolean);

        Procedure GetDataFromFile(Var F: TextFile; Sender: TObject);
        Function FileReading(Var F: TextFile): ERRORS_LIST;
        procedure ResultButtonClick(Sender: TObject);
        procedure OutEditChange(Sender: TObject);
       // procedure EnterNEditChange(Sender: TObject);
        procedure QuitMenuClick(Sender: TObject);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

       // procedure EnterNEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

      //  procedure EnterNEditKeyPress(Sender: TObject; var Key: Char);
      //  procedure EnterNEditExit(Sender: TObject);

     //   procedure EnterNEditClick(Sender: TObject);

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
      'Неверный число столбцов в файле!', 'Введенные координаты равны!',
      'Неверное число строк в файле!',
      'Стороны многоугольника лежат на одной прямой!',
      'Многоугольник не является выпуклым!');
    DIGITS = ['0' .. '9'];
    NO_ZERO_DIGITS = ['1' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_N = 1;
    MAX_N = 20;
    MIN_X = 0;
    MAX_X = 10;
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
Procedure FillGrid(Grid: TStringGrid);
Var
    I, J: Integer;

Begin
    Grid.Cells[0, 0] := 'Студенты ';
    Grid.ColWidths[0] := 100;

    For I := 1 To Grid.ColCount - 1 Do
    Begin
            Grid.Cells[I, 0] := IntToStr(I) + ' оценка';
    End;
    for I := 1 to Grid.RowCount do
        Grid.Cells[0, I] := IntToStr(I);

End;
procedure TMainTaskForm.FormCreate(Sender: TObject);
begin
    ResultButton.Enabled := False;
    TaskLabel.Caption :=
      'Данная программа выводит номера отличников за семестр.' + #13#10 +
      '30 студентов, 10 оценок';
      FillGrid(StringGrid);


end;

function TMainTaskForm.FormHelp(Command: Word; Data: NativeInt;
  var CallHelp: Boolean): Boolean;
begin
    CallHelp := false;
    InstructionMenuClick(self);
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
           // try
          //      Read(F, Value);
           // Except
               // ERRORS := NUM_ERR;
           // end;
          //  ERRORS := IsCorrectRange(Value, MIN_X, MAX_X);
           // Inc(I);
        End;
        if (I <> 10) And (ERRORS = CORRECT) then
            ERRORS := ORDER_ERR;
        I := 0;
        Readln(F);
        Inc(J);
    End;
   if (J <> 30) then
     ERRORS := CROSS_SIDE;
    CloseFile(F);
    CheckFileData := ERRORS;
End;

Procedure TMainTaskForm.GetDataFromFile(Var F: TextFile; Sender: TObject);
Var
    NumStr, Mark: String;
    Numbers: TArray<String>;
    Num, I, J: Integer;
Begin
    I := 1;
    J := 1;
    Reset(F);
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
        ERRORS := CheckNumOfLines(F, 30);
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
    SetLength(CoordArr, CoordGrid.RowCount - 1, CoordGrid.ColCount - 1);

    For I := 1 To CoordGrid.RowCount - 1 Do
    Begin
        for J := 1 to CoordGrid.ColCount - 1 do
        Begin
            CoordArr[I - 1, J - 1] := StrtoInt(CoordGrid.Cells[J, I]);
        End;
    End;
    Result := CoordArr;
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
Var
    GoodMarks: Boolean;
    GoodMen: TGood;
    AllStud: TArr;
    Row, Col, I, Mark: Integer;
    Str : String;
Begin
    Row := 0;
    Col := 0;
    I := 0;
    Str := '';

    AllStud := FillArrayFromStringGrid(MainTaskForm.StringGrid);
    SetLength(GoodMen, 30);
    For Row := Low(AllStud) To Length(AllStud)  Do
    Begin
        if Row >= 30 then
            GoodMarks := False
        Else
            GoodMarks := True;
        For Col := Low(AllStud[Row]) To  High(AllStud[Row]) Do
        Begin
           Mark := AllStud[Row, Col];
           If Mark < 9 Then
                GoodMarks := False;
        End;
        If GoodMarks Then
        Begin
            SetLength(GoodMen, I + 1);
            GoodMen[I] := Row + 1;
            Inc(I);
        End;


    End;
    if Length(GoodMen) = 1 then
    Begin
        MainTAskForm.OutEdit.Text := 'Отличников нет.';
    End
    Else
    Begin
        Str := 'Отличники под номерами: ';
        for I := 0 to High(GoodMen) do
        Begin
           Str := Concat(Str, IntToStr(GoodMen[I]),', ')
        End;
        Delete(Str, Length(Str) - 1, 1);
        MainTAskForm.OutEdit.Text := Str;
    End;




End;
 {
procedure TMainTaskForm.EnterNEditChange(Sender: TObject);
Var
    ArrayLength: Integer;
begin

    OutEdit.Text := '';

    If (EnterNEdit.Text = '') OR (EnterNEdit.Text = '1') Or (EnterNEdit.Text = '2') Then
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
     }
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
 {
procedure TMainTaskForm.EnterNEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    CheckShftAndArrows(Key, Shift);
end;
    }
{
procedure TMainTaskForm.EnterNEditKeyPress(Sender: TObject; var Key: Char);
begin
    CheckComboButtons(Key, EnterNEdit);
    CheckInput(EnterNEdit.Text, Key, MIN_N, MAX_N);
end;
   }
Procedure BlockClick(Edit: TEdit);
Begin
    If Edit.SelStart <> Length(Edit.Text) Then
        Edit.SelStart := Length(Edit.Text);
End;
 {
procedure TMainTaskForm.EnterNEditClick(Sender: TObject);
begin
    BlockClick(EnterNEdit);
end;
     }
Function IsGridFull(StringGrid: TStringGrid): Boolean;
var
    I, J, EmptyCount: Integer;
begin
    EmptyCount := 0;
    For I := 0 to StringGrid.ColCount - 1 do
    begin
        For J := 0 to StringGrid.RowCount - 1 do
        begin
            if StringGrid.Cells[I, J] = '' then
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
    If Not CharInSet(Key, DIGITS) And (Key <> #8)  Then
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
    if IsGridFull(StringGrid) Then
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
