Unit AddContact;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Instruction;

Type
    TAddContactForm = Class(TForm)
        StartLabel: TLabel;
        NumberEdit: TEdit;
        NameEdit: TEdit;
        NameLabel: TLabel;
        NemberLabel: TLabel;
        AddButton: TButton;
        CancelButton: TButton;
        Procedure CancelButtonClick(Sender: TObject);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure NumberEditChange(Sender: TObject);
        Procedure NameEditChange(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure NumberEditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure NumberEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure NameEditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure NameEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure AddButtonClick(Sender: TObject);
        Procedure NumberEditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure NameEditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;

    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    AddContactForm: TAddContactForm;

Const
    ALPHABET = ['À' .. 'ß', 'à' .. 'ÿ'];
    NUMBERS = ['0' .. '9'];
    NUMBER_LENGTH = 9;

Implementation

Uses
    MainForm;

    //DoubleLinkedList;

Procedure AddNewContact(Name, Number: String; Var StringGrid: TStringGrid);
  External 'DoubleLinkedList.dll';
Procedure PrintUpDownList(Var ListGrid: TStringGrid);
  External 'DoubleLinkedList.dll';

{$R *.dfm}

Var
    CanAdd: Boolean;

Procedure CenterFormOnScreen(AddContactForm: TAddContactForm);
Begin
    AddContactForm.Left := (Screen.Width - AddContactForm.Width) Div 2;
    AddContactForm.Top := (Screen.Height - AddContactForm.Height) Div 2;
End;

Procedure CheckComboButtons(Var Key: Char; Edit: TEdit;
  Const Chariki: TSysCharSet);
Begin
    If (Key = #22) Or ((Key = 'v') And (GetKeyState(VK_CONTROL) < 0)) Then
        Key := #0;
    If Not CharInSet(Key, Chariki) And (Key <> #8) Then
        Key := #0;
End;

Procedure CheckShftAndArrows(Var Key: Word; Shift: TShiftState);
Begin
    If (Key = VK_INSERT) And (Shift = [SsShift]) Then
        Key := 0;
    If (Key = VK_LEFT) Or (Key = VK_UP) Then
        Key := 0
    Else If (Key = VK_RIGHT) Or (Key = VK_DOWN) Then
        Key := 0;
End;

Procedure CheckRange(Var Key: Char; Edit: TEdit; Const MAX: Integer);
Var
    BuffString: String;
Begin
    If (Length(Edit.Text) >= MAX) And (Key <> #8) Then
        Key := #0;
End;

Procedure TAddContactForm.AddButtonClick(Sender: TObject);
Begin
    AddNewContact(NameEdit.Text, NumberEdit.Text, MainTaskForm.StringGrid);
    MainTaskForm.StringGrid.RowCount := MainTaskForm.StringGrid.RowCount + 1;
    PrintUpDownList(MainTaskForm.StringGrid);
    IsEdited := True;
    Saved := False;
    Close;
End;

Procedure TAddContactForm.CancelButtonClick(Sender: TObject);
Begin
    NameEdit.Text := '';
    NumberEdit.Text := '';
    Close;
End;

Procedure TAddContactForm.FormCreate(Sender: TObject);
Begin
    AddButton.Enabled := False;
End;

Function TAddContactForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

Procedure TAddContactForm.FormKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    If Key = VK_ESCAPE Then
        Close;

End;

Procedure TAddContactForm.NameEditChange(Sender: TObject);
Begin
    If (NameEdit.Text <> '') And (NumberEdit.Text <> '') Then
        AddButton.Enabled := True
    Else
        AddButton.Enabled := False;
End;

Procedure TAddContactForm.NameEditContextPopup(Sender: TObject;
  MousePos: TPoint; Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TAddContactForm.NameEditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TAddContactForm.NameEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    CheckRange(Key, NameEdit, 15);
End;

Procedure TAddContactForm.NumberEditChange(Sender: TObject);
Begin
    If (NameEdit.Text <> '') And (Length(NumberEdit.Text) = 9) Then
        AddButton.Enabled := True
    Else
        AddButton.Enabled := False;
End;

Procedure TAddContactForm.NumberEditContextPopup(Sender: TObject;
  MousePos: TPoint; Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TAddContactForm.NumberEditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TAddContactForm.NumberEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    CheckComboButtons(Key, NumberEdit, NUMBERS);
    CheckRange(Key, NumberEdit, NUMBER_LENGTH);
End;

End.
