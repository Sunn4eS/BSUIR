Unit Instruction;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TInstructionForm = Class(TForm)
        InstructionLabel: TLabel;
        Procedure CloseButtonClick(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    InstructionForm: TInstructionForm;

Implementation

{$R *.dfm}

Procedure CenterFormOnScreen(InstructionForm: TInstructionForm);
Begin
    InstructionForm.Left := (Screen.Width - InstructionForm.Width) Div 2;
    InstructionForm.Top := (Screen.Height - InstructionForm.Height) Div 2;
End;

Procedure TInstructionForm.CloseButtonClick(Sender: TObject);
Begin
    Close;
End;

Procedure TInstructionForm.FormCreate(Sender: TObject);
Begin
    CenterFormOnScreen(Self);
    InstructionLabel.Caption :=
      '1. ����� �������� ����� ������� ����� ������ �� ������ "�������� �������".'
      + #13#10 +
      '2. ��� �������� ����� ������ �� ������ ������� � ������ � ������ ������ "�������"'
      + #13#10 +
      '3. ��� ��������� ������ � �������� ������� ����� ������ �� ������ "�������� �������"'
      + #13#10 + '' + #13#10 + '��� �������� ��������� �� ���������� �����:' +
      #13#10 + '1. �� ������ ������ ��� ��������.' + #13#10 +
      '2. �� ������ ������ ����� �������� (��� +375).';
End;

Function TInstructionForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

End.
