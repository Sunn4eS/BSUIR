Unit AddLeaf;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TAddLeafForm = Class(TForm)
        NameEdit: TLabel;
        AddButton: TButton;
        CancelButton: TButton;
        EnterEdit: TEdit;
        Procedure EnterEditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure EnterEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure EnterEditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure CancelButtonClick(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure EnterEditChange(Sender: TObject);
        Procedure AddButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Const
    DIGITS = ['0' .. '9'];
    MAX = 1000;
    MIN = 1;

Var
    AddLeafForm: TAddLeafForm;

Implementation

Uses
    MainForm, TreeUnit;

{$R *.dfm}

Procedure CenterFormOnScreen(AddLeafForm: TAddLeafForm);
Begin
    AddLeafForm.Left := (Screen.Width - AddLeafForm.Width) Div 2;
    AddLeafForm.Top := (Screen.Height - AddLeafForm.Height) Div 2;
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
    BuffString: String;
    Value: Integer;
Begin
    Value := 0;
    If TryStrToInt(Edit.Text + Key, Value) Then
    Begin
        If (Value > MAX) Or (Value < MIN) Then
            Key := #0;
    End;
End;

Procedure TAddLeafForm.AddButtonClick(Sender: TObject);
Var
    Error: ERROR_LIST;
Begin
    Error := CORRECT;
    If BinaryTree = Nil Then
        MakeTree(BinaryTree, StrToInt(EnterEdit.Text))
    Else
        Add(BinaryTree, StrToInt(EnterEdit.Text), Error);
    If Error = CORRECT Then
    Begin
        MainTaskForm.TreePaintBoxPaint(MainTaskForm.TreePaintBox);
        Close;
    End
    Else
        Application.MessageBox(PWideChar(ERRORS[Error]), 'Îøèáêà',
          MB_OK Or MB_ICONERROR);

End;

Procedure TAddLeafForm.CancelButtonClick(Sender: TObject);
Begin
    EnterEdit.Text := '';
    Close;
End;

Procedure TAddLeafForm.EnterEditChange(Sender: TObject);
Begin
    If EnterEdit.Text <> '' Then
        AddButton.Enabled := True
    Else
        AddButton.Enabled := False;
End;

Procedure TAddLeafForm.EnterEditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TAddLeafForm.EnterEditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift)
End;

Procedure TAddLeafForm.EnterEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    CheckComboButtons(Key, EnterEdit, DIGITS);
    CheckRange(Key, EnterEdit, MAX, MIN);
End;

Procedure TAddLeafForm.FormCreate(Sender: TObject);
Begin
    AddButton.Enabled := False;
End;

Function TAddLeafForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

End.
