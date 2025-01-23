Unit Instruction;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TInstructionForm = Class(TForm)
        InstructionLabel: TLabel;
        Procedure FormCreate(Sender: TObject);
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

Procedure TInstructionForm.FormCreate(Sender: TObject);
Begin
    CenterFormOnScreen(Self);
    InstructionLabel.Caption := '1. ������� ������� ������� N [2; 4].' + #13#10
      + '2. ������� �������� ������� [-99; 100]' + #13#10 +
      '3. � "��������� �������" ����� ������ ���������� �����' + #13#10 +
      '   �� ������� �� ������ ������ ����. � "�������� �������"' + #13#10 +
      '   ���������� �� ������� �� ������ ��������� ����� �������.' + #13#10 +
      '4.1 � ����� ������ ����������� ���������� �������� ������� �� ������ ������.'
      + #13#10 + '    �� ������ ������ ���������� ����� �������.' + #13#10 +
      '4.2 �� ������ � �������� ������� ���������� I ���� ������' + #13#10 +
      '    (������ ������ I1, �������� ������ I2).' + #13#10 +
      '4.3 �� ����� � ������ ������� ���������� J ���� ������' + #13#10 +
      '    (����� ������ J1, ������ ������ J2)' + #13#10 +
      '4.4 � ������� ������ ������������ �������� �������.' + #13#10 +
      '    �������� ����� ������ ������������ ����� ������.' + #13#10 +
      '    ����� ������ ������� ������������ � ����� ������.';
End;

End.
