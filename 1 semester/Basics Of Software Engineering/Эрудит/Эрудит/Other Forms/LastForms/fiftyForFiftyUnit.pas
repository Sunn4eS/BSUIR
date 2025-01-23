Unit fiftyForFiftyUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
    BackendGameDictionaryUnit,
    BackendLetterBankUnit,
    BackendGamerUnit,
    BackendStartUnit;

Const
    COUNT_LETTERS: Integer = 10;

Type

    TFiftyForFiftyForm = Class(TForm)
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Edit1: TEdit;
        BitBtn1: TBitBtn;
        Procedure FormCreate(Sender: TObject; Var Gamer: TGamer;
            Var Bank: TLetterBank);
        Procedure Edit1Change(Sender: TObject);
        Procedure Edit1KeyPress(Sender: TObject; Var Key: Char);
        Procedure BitBtn1Click(Sender: TObject);
    Private
        CurGamer: TGamer;
        ChosenLanguage: TLanguage;
        Bank: TLetterBank;
        IsBonusUsed: Boolean;
    Public
        Function Is50For50Used(): Boolean;
    End;

Const
    Alphabet = ['a' .. 'z'];

Var
    FiftyForFiftyForm: TFiftyForFiftyForm;
    Language: Integer;

Implementation

{$R *.dfm}

Procedure TFiftyForFiftyForm.BitBtn1Click(Sender: TObject);
Var
    TempLetters: TLetters;
    Letter, TempLetter: Char;
    I, CountMissing: Integer;
Begin
    If (5 <= Bank.GetCountOfLetter()) Then
    Begin
        TempLetters := CurGamer.GetUserLetters();
        CurGamer.SetLastGamersWord(Edit1.Text);
        If CurGamer.IsWordCreatable() Then
        Begin
            CurGamer.Use50For50Button();
            CurGamer.DeleteLetters();
            CurGamer.SetLastGamersWord('');
            CurGamer.SetLetters(Self.Bank.GiveLetters(COUNT_LETTERS -
                CurGamer.GetCountLetters(), CurGamer.GetCountVowel()));
        End
        Else
            MessageBox(FiftyForFiftyForm.Handle,
                'ќй-еееей, кажетс€ одной из букв которые вы хотите помен€ть нет в вашем наборе',
                'ќшибочка', MB_ICONEXCLAMATION);
    End
    else
        MessageBox(FiftyForFiftyForm.Handle,
                'ќй-еееей, кажетс€ в Ѕанке букв закончилиьс буквы :(',
                'ќшибочка', MB_ICONEXCLAMATION);
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
        GOOD_KEYS[32] := 'Є';
    End;

    If (Key <> #0) Then
        CheckKey := CheckKeyInLeng(GOOD_KEYS, Key, Language);

    If Not CheckKey Then
        Key := #0;

    If CheckKey And (Edit.SelText <> '') And (Length(Edit.Text) >= 5) Then
        Edit.Clear;

    If Length(Edit.Text) >= 5 Then
        Key := #0;
End;

Procedure TFiftyForFiftyForm.Edit1Change(Sender: TObject);
Begin
    If Length(Edit1.Text) = 5 Then
        BitBtn1.Enabled := True
    Else
        BitBtn1.Enabled := False;
End;

Procedure TFiftyForFiftyForm.Edit1KeyPress(Sender: TObject; Var Key: Char);
Begin
    If Key <> #8 Then
        EditKeyPress(Key, Edit1);
End;

Procedure TFiftyForFiftyForm.FormCreate(Sender: TObject; Var Gamer: TGamer;
    Var Bank: TLetterBank);
Var
    I, CountLetters: Integer;
    TempLetters: TLetters;
    Letter: Char;
Begin
    IsBonusUsed := False;
    Self.Bank := Bank;
    Self.CurGamer := Gamer;
    Self.ChosenLanguage := Start.GetLanguage;
    If ChosenLanguage = BackendStartUnit.EN Then
        Language := 0
    Else
        Language := 1;
    TempLetters := CurGamer.GetUserLetters();
    Label2.Caption := '';
    For Letter In TempLetters.Keys Do
    Begin
        CountLetters := TempLetters[Letter];
        For I := 1 To CountLetters Do
            Label2.Caption := Label2.Caption + Letter + ' ';
    End;
End;

Function TFiftyForFiftyForm.Is50For50Used: Boolean;
Begin
    Is50For50Used := IsBonusUsed;
End;

End.
