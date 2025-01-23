Unit FriendsHelpUnit;

Interface

Uses
    Winapi.Windows,
    Winapi.Messages,
    System.SysUtils,
    System.Variants,
    System.Classes,
    Vcl.Graphics,
    Vcl.Controls,
    Vcl.Forms,
    Vcl.Dialogs,
    Vcl.StdCtrls,
    Vcl.Grids,
    Vcl.Buttons,
    FiftyForFiftyUnit,
    BackendGameDictionaryUnit,
    BackendLetterBankUnit,
    BackendGamerUnit,
    BackendStartUnit;

Type
    TFriendsHelpForm = Class(TForm)
        StringGrid1: TStringGrid;
        Label1: TLabel;
        Label2: TLabel;
        Edit1: TEdit;
        Label3: TLabel;
        Edit2: TEdit;
        Edit3: TEdit;
        Label4: TLabel;
        StringGrid2: TStringGrid;
        Label5: TLabel;
        BitBtn1: TBitBtn;
        Label6: TLabel;
        Procedure Edit1KeyPress(Sender: TObject; Var Key: Char);
        Procedure Edit1ContextPopup(Sender: TObject; MousePos: TPoint;
            Var Handled: Boolean);
        Procedure Edit2ContextPopup(Sender: TObject; MousePos: TPoint;
            Var Handled: Boolean);
        Procedure Edit2KeyPress(Sender: TObject; Var Key: Char);
        Procedure Edit3ContextPopup(Sender: TObject; MousePos: TPoint;
            Var Handled: Boolean);
        Procedure Edit3KeyPress(Sender: TObject; Var Key: Char);
        Procedure Edit3KeyDown(Sender: TObject; Var Key: Word;
            Shift: TShiftState);
        Procedure Edit2KeyDown(Sender: TObject; Var Key: Word;
            Shift: TShiftState);
        Procedure Edit1KeyDown(Sender: TObject; Var Key: Word;
            Shift: TShiftState);
        Procedure Edit3Change(Sender: TObject);
        Procedure Edit2Change(Sender: TObject);
        Procedure Edit1Change(Sender: TObject);
        Procedure BitBtn1Click(Sender: TObject);
        Procedure FormCreate(Sender: TObject; Var Gamers: TGamers; Var CurPlayer: Integer);
    Private
        ChosenLanguage: TLanguage;
        CurPlayer: Integer;
        Gamers: TGamers;
    Public
        { Public declarations }
    End;

Var
    FriendsHelpForm: TFriendsHelpForm;
    SwapCount: Integer = 1;
    Language: Integer;

Implementation

{$R *.dfm}

Function CheckConditionFriendLetter(): Boolean;
Var
    I: Integer;
    Res: Boolean;
Begin
    Res := False;
    For I := 1 To Length(FriendsHelpForm.StringGrid1.Cells[1,
        StrToInt(FriendsHelpForm.Edit3.Text)]) Do
        If (FriendsHelpForm.StringGrid1.Cells[1,
            StrToInt(FriendsHelpForm.Edit3.Text)
            ][I] = FriendsHelpForm.Edit2.Text) Then
            Res := True;

    CheckConditionFriendLetter := Res;
End;

Function CheckConditionYourLetter(): Boolean;
Var
    I: Integer;
    Res: Boolean;
Begin
    Res := False;
    For I := 1 To Length(FriendsHelpForm.StringGrid2.Cells[1, 1]) Do
        If (FriendsHelpForm.StringGrid2.Cells[1, 1][I]
            = FriendsHelpForm.Edit1.Text) Then
        Begin
            Res := True;
        End;

    CheckConditionYourLetter := Res;
End;

Function ChangeCheck(Edit1: TEdit; Edit2: TEdit; Edit3: TEdit): Boolean;
Begin
    If (SwapCount <> 0) And (Edit1.Text <> '') And (Edit2.Text <> '') And
        (Edit3.Text <> '') And CheckConditionYourLetter() And
        CheckConditionFriendLetter() Then
        ChangeCheck := True
    Else
        ChangeCheck := False;
End;

Procedure Replacement(Edit1, Edit2, Edit3: TEdit; Var Gamers: TGamers;
    Var CurPlayer: Integer);
Begin
    Gamers[StrToInt(Edit3.Text) - 1].ChangeLetter(Edit2.Text[1], Edit1.Text[1]);
    Gamers[CurPlayer - 1].ChangeLetter(Edit1.Text[1], Edit2.Text[1]);
End;

Procedure RenderingGrids(Var StringGrid2, StringGrid1: TStringGrid;
    Sender: TObject; Var Gamers: TGamers; Var CurPlayer: Integer);
Var
    I, J, IndGrid, CountLetters: Integer;
    TempLetters: TLetters;
    Letter: Char;
Begin
    IndGrid := 1;
    For I := 0 To CurPlayer - 2 Do
    Begin
        StringGrid1.Cells[0, I + 1] := IntToStr(I + 1);

        TempLetters := Gamers[I].GetUserLetters();
        StringGrid1.Cells[1, IndGrid] := '';
        For Letter In TempLetters.Keys Do
        Begin
            CountLetters := TempLetters[Letter];
            For J := 1 To CountLetters Do
                StringGrid1.Cells[1, IndGrid] := StringGrid1.Cells[1, IndGrid] +
                    Letter + ' ';
        End;

        StringGrid1.Cells[2, IndGrid] := IntToStr(Gamers[I].GetPoints);
        Inc(IndGrid);
    End;

    For I := CurPlayer - 1 To High(Gamers) Do
    Begin
        StringGrid1.Cells[0, IndGrid] := IntToStr(I + 1);

        TempLetters := Gamers[I].GetUserLetters();
        StringGrid1.Cells[1, IndGrid] := '';
        For Letter In TempLetters.Keys Do
        Begin
            CountLetters := TempLetters[Letter];
            For J := 1 To CountLetters Do
                StringGrid1.Cells[1, IndGrid] := StringGrid1.Cells[1, IndGrid] +
                    Letter + ' ';
        End;

        StringGrid1.Cells[2, IndGrid] := IntToStr(Gamers[I].GetPoints);
        Inc(IndGrid);
    End;

    StringGrid2.Cells[0, 1] := IntToStr(CurPlayer);

    TempLetters := Gamers[CurPlayer - 1].GetUserLetters();
    StringGrid2.Cells[1, 1] := '';
    For Letter In TempLetters.Keys Do
    Begin
        CountLetters := TempLetters[Letter];
        For I := 1 To CountLetters Do
            StringGrid2.Cells[1, 1] := StringGrid2.Cells[1, 1] + Letter + ' ';
    End;

    StringGrid2.Cells[2, 1] := IntToStr(Gamers[CurPlayer - 1].GetPoints);
End;

Procedure TFriendsHelpForm.BitBtn1Click(Sender: TObject);
Begin
    Label6.Caption := 'Лимит доступных замен исчерпан.';
    Dec(SwapCount);
    Replacement(Edit1, Edit2, Edit3, Gamers, CurPlayer);
    Gamers[CurPlayer - 1].UseFrindsHelpButton();
    RenderingGrids(StringGrid2, StringGrid1, Sender, Gamers, CurPlayer);
    Edit1.Enabled := False;
    Edit1.Text := '';
    Edit2.Enabled := False;
    Edit2.Text := '';
    Edit3.Enabled := False;
    Edit3.Text := '';
    BitBtn1.Enabled := False;
End;

Procedure TFriendsHelpForm.Edit1Change(Sender: TObject);
Begin
    BitBtn1.Enabled := ChangeCheck(Edit1, Edit2, Edit3);
End;

Procedure EditKeyDown(Var Key: Word; Var Edit: TEdit);
Begin
    If ((Key = VK_BACK) And (Edit.SelStart = 1)) Or
        ((Key = VK_DELETE) And (Edit.SelStart = 0)) Then
        Edit.Clear;

    If ((Key = VK_DELETE) Or (Key = VK_BACK)) And (Edit.SelText <> '') Then
        Edit.Clear;
End;

Function CheckKeyInLeng(Var GOOD_KEYS: Array Of Char; Key: Char;
    Language: Integer): Boolean;
Var
    ColNum, I: Integer;
    Res: Boolean;
Begin
    Res := False;
    If Language = 0 Then
        ColNum := 26
    Else
        ColNum := 33;
    For I := 0 To ColNum - 1 Do
        If (GOOD_KEYS[I] = Key) Then
            Res := True;

    CheckKeyInLeng := Res;
End;

Procedure EditKeyPress(Var Key: Char; Var Edit: TEdit);
Var
    GOOD_KEYS: Array Of Char;
    Chardfsdfs: Char;
    I: Integer;
    CheckKey: Boolean;
Begin
    If Language = 0 Then
    Begin
        SetLength(GOOD_KEYS, 26);
        For I := 0 To 25 Do
            GOOD_KEYS[I] := Chr(97 + I);
    End
    Else
    Begin
        SetLength(GOOD_KEYS, 33);
        For I := $0430 To $044F Do
            GOOD_KEYS[I - $0430] := Chr(I);
        GOOD_KEYS[32] := 'ё';
    End;

    If (Key <> #0) Then
        CheckKey := CheckKeyInLeng(GOOD_KEYS, Key, Language);

    If Not CheckKey Then
        Key := #0;

    If CheckKey And (Edit.SelText <> '') And (Length(Edit.Text) >= 1) Then
        Edit.Clear;

    If Length(Edit.Text) >= 1 Then
        Key := #0;
End;

Procedure TFriendsHelpForm.Edit1ContextPopup(Sender: TObject; MousePos: TPoint;
    Var Handled: Boolean);
Begin
    Handled := False;
End;

Procedure TFriendsHelpForm.Edit1KeyDown(Sender: TObject; Var Key: Word;
    Shift: TShiftState);
Begin
    EditKeyDown(Key, Edit1)
End;

Procedure TFriendsHelpForm.Edit1KeyPress(Sender: TObject; Var Key: Char);
Begin
    EditKeyPress(Key, Edit1);
End;

Procedure TFriendsHelpForm.Edit2Change(Sender: TObject);
Begin
    BItBtn1.Enabled := ChangeCheck(Edit1, Edit2, Edit3);
End;

Procedure TFriendsHelpForm.Edit2ContextPopup(Sender: TObject; MousePos: TPoint;
    Var Handled: Boolean);
Begin
    Handled := False;
End;

Procedure TFriendsHelpForm.Edit2KeyDown(Sender: TObject; Var Key: Word;
    Shift: TShiftState);
Begin
    EditKeyDown(Key, Edit2)
End;

Procedure TFriendsHelpForm.Edit2KeyPress(Sender: TObject; Var Key: Char);
Begin
    EditKeyPress(Key, Edit2);
End;

Procedure TFriendsHelpForm.Edit3Change(Sender: TObject);
Begin
    BItBtn1.Enabled := ChangeCheck(Edit1, Edit2, Edit3);
End;

Procedure TFriendsHelpForm.Edit3ContextPopup(Sender: TObject; MousePos: TPoint;
    Var Handled: Boolean);
Begin
    Handled := False;
End;

Procedure TFriendsHelpForm.Edit3KeyDown(Sender: TObject; Var Key: Word;
    Shift: TShiftState);
Begin
    EditKeyDown(Key, FriendsHelpForm.Edit3);
End;

Procedure TFriendsHelpForm.Edit3KeyPress(Sender: TObject; Var Key: Char);
Var
    GOOD_KEYS: Set Of Char;
Begin
    GOOD_KEYS := ['1' .. Chr(Length(Gamers) + 48)];
    If Not(Key In GOOD_KEYS) Or (Key = Chr(CurPlayer + 48)) Then
        Key := #0;

    If (Key In GOOD_KEYS) And (Edit3.SelText <> '') And
        (Length(Edit3.Text) >= 1) Then
        Edit3.Clear;

    If Length(Edit3.Text) >= 1 Then
        Key := #0;
End;

Procedure TFriendsHelpForm.FormCreate(Sender: TObject; Var Gamers: TGamers; Var CurPlayer: Integer);
Begin
    SwapCount := 1;
    Self.CurPlayer := CurPlayer;
    Self.Gamers := Gamers;
    Self.ChosenLanguage := Start.GetLanguage;
    If ChosenLanguage = BackendStartUnit.EN Then
        Language := 0
    Else
        Language := 1;
    StringGrid1.RowCount := Length(Gamers) + 1;
    StringGrid1.Cells[0, 0] := '№ игрока';
    StringGrid1.Cells[1, 0] := 'Набор букв';
    StringGrid1.Cells[2, 0] := 'Очки';

    StringGrid2.Cells[0, 0] := '№ игрока';
    StringGrid2.Cells[1, 0] := 'Набор букв';
    StringGrid2.Cells[2, 0] := 'Очки';

    RenderingGrids(StringGrid2, StringGrid1, Sender, Gamers, CurPlayer);
End;

End.
