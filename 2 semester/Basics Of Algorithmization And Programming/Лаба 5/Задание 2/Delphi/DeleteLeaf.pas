Unit DeleteLeaf;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TDeleteLeafForm = Class(TForm)
        NameEdit: TLabel;
        DelButton: TButton;
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
        Procedure DelButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Const
    DIGITS = ['0' .. '9'];
    MAX = 10000;
    MIN = 1;

Var
    DeleteLeafForm: TDeleteLeafForm;

Implementation

Uses
    MainForm, TreeUnit;

{$R *.dfm}

Procedure CenterFormOnScreen(DeleteLeafForm: TDeleteLeafForm);
Begin
    DeleteLeafForm.Left := (Screen.Width - DeleteLeafForm.Width) Div 2;
    DeleteLeafForm.Top := (Screen.Height - DeleteLeafForm.Height) Div 2;
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

    If TryStrToInt(Edit.Text + Key, Value) Then
    Begin
        If (Value > MAX) Or (Value < MIN) Then
            Key := #0;
    End;
End;

Procedure TDeleteLeafForm.DelButtonClick(Sender: TObject);
Var
    Error: ERROR_LIST;
Begin
    Error := CORRECT;
    If (BinaryTree <> Nil) And (BinaryTree.Data = StrToInt(EnterEdit.Text)) Then
        DeleteFirstLeaf(BinaryTree, Error)
    Else
        Delete(BinaryTree, StrToInt(EnterEdit.Text), Error);
    If Error = CORRECT Then
    Begin
        MainTaskForm.TreePaintBoxPaint(MainTaskForm.TreePaintBox);
        Close;
    End
    Else
        Application.MessageBox(PWideChar(ERRORS[Error]), 'Œ¯Ë·Í‡',
          MB_OK Or MB_ICONERROR);

End;

Procedure TDeleteLeafForm.CancelButtonClick(Sender: TObject);
Begin
    EnterEdit.Text := '';
    Close;
End;

Procedure TDeleteLeafForm.EnterEditChange(Sender: TObject);
Begin
    If EnterEdit.Text <> '' Then
        DelButton.Enabled := True
    Else
        DelButton.Enabled := False;
End;

Procedure TDeleteLeafForm.EnterEditContextPopup(Sender: TObject;
  MousePos: TPoint; Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TDeleteLeafForm.EnterEditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShftAndArrows(Key, Shift)
End;

Procedure TDeleteLeafForm.EnterEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    CheckComboButtons(Key, EnterEdit, DIGITS);
    CheckRange(Key, EnterEdit, MAX, MIN);
End;

Procedure TDeleteLeafForm.FormCreate(Sender: TObject);
Begin
    DelButton.Enabled := False;
End;

Function TDeleteLeafForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

End.
