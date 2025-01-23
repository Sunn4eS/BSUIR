Unit InputEditUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils,
    System.Variants, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
    Vcl.Grids;

Type
    TGrid = Class(TStringGrid);

Const
    GROUP_LENGTH = 6;
    YEAR_LENGTH = 4;
    CODE_LENGTH = 10;

    NAME_LENGTH = 15;
    MARK_MIN = 0;
    MARK_MAX = 10;

    YEAR_MIN = 1964;
    YEAR_MAX = 2100;
    NONE = #0;
    BACKSPACE = #8;
    NUMBERS = ['0' .. '9'];
    NUMBERS_EXT = ['0' .. '9', '-'];

    LETTERS = ' -‡·‚„‰Â∏ÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘˙˚¸˝˛ˇabcdefghijklmnopqrstuvwxyz¿¡¬√ƒ≈®∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂABCDEFGHIJKLMNOPQRSTUVWXYZ';

Procedure CheckShiftAndArrows(Var Key: Word; Shift: TShiftState);
Procedure CheckComboButtons(Var Key: Char; Edit: TEdit;
  Const Chars: TSysCharSet);
Procedure CheckLength(Const MAX: Integer; Edit: TEdit; Var Key: Char);
Function IsCorrectRange(Value: Integer; Const MIN, MAX: Integer): Boolean;
Procedure CheckNumberRange(Var Key: Char; Const MAX, MIN: Integer;
  Text: String);
Function IsFullFields(NumberEdit, YearEdit, CodeEdit: TEdit): Boolean;
Function IsAllCellFill(Grid: TStringGrid): Boolean;
Function IsFullFieldsStudents(NameEdit, SurnameEdit, PatrynomicEdit,
  GroupNumberEdit: TEdit; Grid: TStringGrid): Boolean;
Procedure CheckValidMarks(Var MarksGrid: TStringGrid; Var Key: Char);
Function IsValidChars(Const Text: String): Boolean;
Function IsValidChar(Const Key: Char): Boolean;
Function IsValidRange(Const Num, MAX: Integer): Boolean;
Procedure NameComponentKeyPress(Const Text: String;
  Const SelStart, SelLength, MAX: Integer; Var Key: Char);
Function IsFullFieldsStudentsNSP(NameEdit, SurnameEdit, PatrynomicEdit
  : TEdit): Boolean;

Implementation

Procedure NameComponentKeyPress(Const Text: String;
  Const SelStart, SelLength, MAX: Integer; Var Key: Char);
Begin
    If (Key <> BACKSPACE) Then
    Begin
        If Not(IsValidChar(Key) And
          IsValidRange(Length(Copy(Text, 1, SelStart) + Key + Copy(Text,
          SelStart + SelLength + 1)), MAX)) Then
            Key := NONE;
    End;
End;

Function IsValidRange(Const Num, MAX: Integer): Boolean;
Begin
    IsValidRange := Num <= MAX;
End;

Procedure CheckShiftAndArrows(Var Key: Word; Shift: TShiftState);
Begin
    If (Key = VK_INSERT) And (Shift = [SsShift]) Then
        Key := Ord(NONE);
    If (Key = VK_LEFT) Or (Key = VK_UP) Then
        Key := Ord(NONE)
    Else If (Key = VK_RIGHT) Or (Key = VK_DOWN) Then
        Key := Ord(NONE);
End;

Procedure CheckComboButtons(Var Key: Char; Edit: TEdit;
  Const Chars: TSysCharSet);
Begin
    If (Key = #22) Or ((Key = 'v') And (GetKeyState(VK_CONTROL) < 0)) Then
        Key := #0;
    If Not CharInSet(Key, Chars) And (Key <> #8) Then
        Key := #0;

End;

Procedure CheckNumberRange(Var Key: Char; Const MAX, MIN: Integer;
  Text: String);
Var
    Value: Integer;
Begin
    Value := 0;
    If TryStrToInt(Text + Key, Value) Then
    Begin
        If Not IsCorrectRange(Value, 0, MAX) Then
        Begin
            Key := #0;
        End;
    End;
End;

Function IsCorrectRange(Value: Integer; Const MIN, MAX: Integer): Boolean;
Begin
    IsCorrectRange := Not((Value < MIN) Or (Value > MAX));
End;

Function IsValidChar(Const Key: Char): Boolean;
Var
    C: Char;
Begin
    For C In LETTERS Do
        If C = Key Then
            Exit(True);
    IsValidChar := False;
End;

Function IsValidChars(Const Text: String): Boolean;
Var
    I: Integer;
Begin
    For I := 1 To Length(Text) Do
        If Not IsValidChar(Text[I]) Then
            Exit(False);
    IsValidChars := True;
End;

Procedure CheckLength(Const MAX: Integer; Edit: TEdit; Var Key: Char);
Var
    BufString: String;
Begin
    If (Length(Edit.Text) >= MAX) And (Key <> BACKSPACE) Then
        Key := NONE;
End;

Function IsFullFields(NumberEdit, YearEdit, CodeEdit: TEdit): Boolean;
Begin
    IsFullFields := (Trim(NumberEdit.Text) <> '') And
      (Trim(YearEdit.Text) <> '') And (Trim(CodeEdit.Text) <> '') And
      (Length(Trim(NumberEdit.Text)) = GROUP_LENGTH) And
      (Length(Trim(YearEdit.Text)) = YEAR_LENGTH) And
      (Length(Trim(CodeEdit.Text)) = CODE_LENGTH);
End;

Function IsAllCellFill(Grid: TStringGrid): Boolean;
Var
    IsFilled: Boolean;
    Col, Row, Num: Integer;
Begin
    IsFilled := True;
    Row := 0;
    While IsFilled And (Row < Grid.RowCount) Do
    Begin
        Col := 0;
        While IsFilled And (Col < Grid.ColCount) Do
        Begin
            If (Grid.Cells[Col, Row] = '') Then
                IsFilled := False;
            Inc(Col);
        End;
        Inc(Row);
    End;
    IsAllCellFill := IsFilled;
End;

Function IsValidRangeGrid(Text: String; Key: Char;
  SelStart, MIN, Max: Integer): Boolean;
Var
    IsValidInput: Boolean;
    Num: Integer;
    Str: String;

Begin
    IsValidInput := True;
    Str := Copy(Text, 0, SelStart) + Key + Copy(Text, SelStart + 1);
    If Not TryStrToInt(Str, Num) Then
        IsValidInput := False;
    If (Num < MIN) Or (Num > MAX) Then
        IsValidInput := False;
    IsValidRangeGrid := IsValidInput;
End;

Procedure ComponentKeyPressGrid(Var Key: Char; SelStart, SelLength: Integer;
  Text: String; Const MIN_NUM, MAX_NUM: Integer);
Var
    IsValidInput: Boolean;

Begin
    IsValidInput := (CharInSet(Key, NUMBERS) Or (Key = BACKSPACE));
    If (SelLength > 0) And (SelLength < Length(Text)) Then
        Key := NONE
    Else
    Begin
        If (SelLength = Length(Text)) And (Key = '0') And
          (Length(Text) <> 0) Then
            Key := NONE;
        If (SelStart = 0) And (SelLength < Length(Text)) And (Key = '0') Then
            Key := NONE;
        If (SelStart = 1) And (Length(Text) > 1) And (Text[2] = '0') And
          (Key = BACKSPACE) Then
            Key := NONE;
        If (IsValidInput) And (Key <> BACKSPACE) And (Key <> NONE) Then
            IsValidInput := IsValidRangeGrid(Text, Key, SelStart,
              MIN_NUM, MAX_NUM);
        If Not IsValidInput Then
            Key := NONE;
    End;
End;

Procedure CheckValidMarks(Var MarksGrid: TStringGrid; Var Key: Char);
Var
    NumsGrid: TGrid;
    SelStart, SelLength: Integer;
    Text: String;
Begin
    NumsGrid := TGrid(MarksGrid);
    If Assigned(NumsGrid.InplaceEditor) Then
    Begin
        NumsGrid.InplaceEditor.Visible;
        SelStart := NumsGrid.InplaceEditor.SelStart;
        SelLength := NumsGrid.InplaceEditor.SelLength;
        Text := NumsGrid.InplaceEditor.Text;
        ComponentKeyPressGrid(Key, SelStart, SelLength, Text, 1, 10);
    End;
End;

Function IsFullFieldsStudents(NameEdit, SurnameEdit, PatrynomicEdit,
  GroupNumberEdit: TEdit; Grid: TStringGrid): Boolean;
Var
    IsFull: Boolean;
Begin
    IsFull := False;
    IsFull := IsAllCellFill(Grid) And (Trim(NameEdit.Text) <> '') And
      (Trim(SurnameEdit.Text) <> '') And (Trim(PatrynomicEdit.Text) <> '');


    IsFullFieldsStudents := IsFull;
End;

Function IsFullFieldsStudentsNSP(NameEdit, SurnameEdit, PatrynomicEdit
  : TEdit): Boolean;
Var
    IsFull: Boolean;
Begin
    IsFull := False;
    IsFull := (Trim(NameEdit.Text) <> '') And (Trim(SurnameEdit.Text) <> '') And
      (Trim(PatrynomicEdit.Text) <> '');

    IsFullFieldsStudentsNSP := IsFull;
End;

Exports CheckLength, CheckComboButtons, CheckShiftAndArrows, CheckNumberRange,
  IsFullFields;

End.
