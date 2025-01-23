Unit AddLine;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Instruction,
    MainForm;

Type
    TAddLineForm = Class(TForm)
        StartLabel: TLabel;
        EndEdit: TEdit;
        StartEdit: TEdit;
        StartTLabel: TLabel;
        EndLabel: TLabel;
        AddButton: TButton;
        CancelButton: TButton;
        Procedure CancelButtonClick(Sender: TObject);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure EndEditChange(Sender: TObject);
        Procedure StartEditChange(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure EndEditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure EndEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure StartEditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure StartEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure AddButtonClick(Sender: TObject);
        Procedure EndEditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure StartEditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Function CanAdd(): Boolean;

    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    AddLineForm: TAddLineForm;
    CanAddTown: Boolean = True;

Const
    NUMBERS = ['0' .. '9'];

Implementation

Uses
    GraphLinkedList;

{$R *.dfm}

Procedure CenterFormOnScreen(AddLineForm: TAddLineForm);
Begin
    AddLineForm.Left := (Screen.Width - AddLineForm.Width) Div 2;
    AddLineForm.Top := (Screen.Height - AddLineForm.Height) Div 2;
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

Procedure CheckRange(Var Key: Char; Edit: TEdit; Const MAX, MIN: Integer);
Var
    Value: Integer;
Begin
    Value := 0;
    If TryStrToInt(Edit.Text + Key, Value) Then
    Begin
        If (Value > MAX) Or (Value < MIN) Then
            Key := #0;
    End;
End;

Procedure TAddLineForm.AddButtonClick(Sender: TObject);
Begin
    AddLink(StrToInt(StartEdit.Text), StrToInt(EndEdit.Text));

    CanAddTown := False;
    Close;
End;

Procedure TAddLineForm.CancelButtonClick(Sender: TObject);
Begin
    StartEdit.Text := '';
    EndEdit.Text := '';
    Close;
End;

Procedure TAddLineForm.FormCreate(Sender: TObject);
Begin
    AddButton.Enabled := False;
End;

Function TAddLineForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    FormHelp := False;
End;

Procedure TAddLineForm.FormKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    If Key = VK_ESCAPE Then
        Close;
End;

Function TAddLineForm.CanAdd(): Boolean;
Begin
    CanAdd := (StartEdit.Text <> '') And (EndEdit.Text <> '') And
      (StartEdit.Text <> EndEdit.Text)
End;

Procedure TAddLineForm.StartEditChange(Sender: TObject);
Begin
    AddButton.Enabled := CanAdd();
End;

Procedure TAddLineForm.StartEditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TAddLineForm.StartEditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TAddLineForm.StartEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    CheckComboButtons(Key, StartEdit, NUMBERS);
    CheckRange(Key, StartEdit, CountOfTowns, 1);
End;

Procedure TAddLineForm.EndEditChange(Sender: TObject);
Begin
    AddButton.Enabled := CanAdd();
End;

Procedure TAddLineForm.EndEditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TAddLineForm.EndEditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift);
End;

Procedure TAddLineForm.EndEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    CheckComboButtons(Key, EndEdit, NUMBERS);
    CheckRange(Key, EndEdit, CountOfTowns, 1);
End;

End.
