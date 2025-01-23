Unit PositiveNumberComponentUnit;

Interface

Uses
    Winapi.Windows, System.SysUtils, System.Classes, Clipbrd;

Const
    ENTER = #13;
    BACKSPACE = #8;
    NONE = #0;
    DIGITS = ['0' .. '9'];
    DIGITS_WITHOUT_ZERO = ['1' .. '9'];
    ALPHABET = ['A' .. 'Z', 'a' .. 'z'];

Var
    CtrlPressed: Boolean = False;

Procedure PositiveNumberComponentContextPopup(Const Text: String; Const SelStart, SelLength, MAX: Integer; Var Handled: Boolean);
Procedure PositiveNumberComponentExit(Text: String; Const MIN: Integer);
Procedure PositiveNumberComponentKeyDown(Const Text: String; Const SelStart, SelLength, MAX: Integer; Var Key: Word; Shift: TShiftState);
Procedure PositiveNumberComponentKeyPress(Const Text: String; Const SelStart, SelLength, MAX: Integer; Var Key: Char);
Procedure PositiveNumberComponentKeyUp();

Implementation

Function IsValidRange(Const Num, MAX: Integer): Boolean;
Begin
    IsValidRange := Num <= MAX;
End;

Function IsPossiblePaste(Const Text: String; Const SelStart, SelLength, MAX: Integer): Boolean;
Var
    Num: Integer;
Begin
    IsPossiblePaste := Clipboard.HasFormat(CF_TEXT) And
                       (Length(Clipboard.AsText) <> 0) And
                       TryStrToInt(Copy(Text, 1, SelStart) + Clipboard.AsText + Copy(Text, SelStart + SelLength + 1), Num) And
                       ((SelStart = 0) And (Clipboard.AsText[1] <> '0') Or (SelStart > 0)) And
                       IsValidRange(StrToInt(Copy(Text, 1, SelStart) + Clipboard.AsText + Copy(Text, SelStart + SelLength + 1)), MAX);
End;

Function IsValidChar(Const SelStart: Integer; Const Key: Char): Boolean;
Begin
    IsValidChar := (SelStart = 0) And CharInSet(Key, DIGITS_WITHOUT_ZERO) Or
                   (SelStart > 0) And CharInSet(Key, DIGITS);
End;


Procedure PositiveNumberComponentContextPopup(Const Text: String; Const SelStart, SelLength, MAX: Integer; Var Handled: Boolean);
Begin
    If Not IsPossiblePaste(Text, SelStart, SelLength, MAX) Or
       (SelLength = 0) And (SelStart = 1) And (Length(Text) > 1) And (Text[2] = '0') Or
       (SelLength > 0) And (SelStart = 0) And (SelLength <> Length(Text)) And (Text[SelLength + 1] = '0') Then
        Handled := True;
End;

Procedure PositiveNumberComponentExit(Text: String; Const MIN: Integer);
Begin
    If (Text <> '') And (StrToInt(Text) < MIN) Then
        Text := '';
End;

Procedure PositiveNumberComponentKeyDown(Const Text: String; Const SelStart, SelLength, MAX: Integer; Var Key: Word; Shift: TShiftState);
Begin
    If (Shift = [ssCtrl]) And (UpCase(Chr(Key)) = 'X') Then
    Begin
        If (SelLength = 0) And (SelStart = 1) And (Length(Text) > 1) And (Text[2] = '0') Or
           (SelLength > 0) And (SelStart = 0) And (SelLength <> Length(Text)) And (Text[SelLength + 1] = '0') Then
            Key := Ord(NONE);
    End
    Else If Key = VK_DELETE Then
    Begin
        If (SelLength = 0) And (SelStart = 0) And (Length(Text) > 1) And (Text[2] = '0') Or
           (SelLength > 0) And (SelStart = 0) And (SelLength <> Length(Text)) And (Text[SelLength + 1] = '0') Then
            Key := Ord(NONE);
    End
    Else If (Shift = [ssCtrl]) And (UpCase(Chr(Key)) = 'V') Or
            (Shift = [ssShift]) And (Key = VK_INSERT) Then
    Begin
        If Not IsPossiblePaste(Text, SelStart, SelLength, MAX) Then
            Key := Ord(NONE);
    End;
    If (Shift = [ssCtrl]) And CharInSet(Chr(Key), ALPHABET) Then
        CtrlPressed := True;
End;

Procedure PositiveNumberComponentKeyPress(Const Text: String; Const SelStart, SelLength, MAX: Integer; Var Key: Char);
Begin
    If Key = BACKSPACE Then
    Begin
        If (SelLength = 0) And (SelStart = 1) And (Length(Text) > 1) And (Text[2] = '0') Or
           (SelLength > 0) And (SelStart = 0) And (SelLength <> Length(Text)) And (Text[SelLength + 1] = '0') Then
            Key := NONE;
    End
    Else If Not CtrlPressed Then
    Begin
        If Not (IsValidChar(SelStart, Key) And IsValidRange(StrToInt(Copy(Text, 1, SelStart) + Key + Copy(Text, SelStart + SelLength + 1)), MAX)) Then
            Key := NONE;
    End;
End;

Procedure PositiveNumberComponentKeyUp();
Begin
    CtrlPressed := False;
End;

End.
