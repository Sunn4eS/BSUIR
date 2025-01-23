unit InstructionUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TInstructionForm = class(TForm)
    InstructionScrollBox: TScrollBox;
    InstructionLabel: TLabel;
    procedure InstructionFormOnCreate(Sender: TObject);
    procedure InstructionScrollBoxMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure InstructionScrollBoxMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InstructionForm: TInstructionForm;

implementation

{$R *.dfm}

procedure TInstructionForm.InstructionFormOnCreate(Sender: TObject);
begin
    InstructionLabel.Caption := '������: �������� ���� �� ���� ������, �� ������� ����� ���������� �����. �������� ���������� ������� �� 2 �� 5. '#13#10#13#10 +
                                '������� ����: ��� ������ �� ������� ���������� �����, ������ �� ������ ������ ���� ������. ' +
                                '���� ����� ���������� �����, �� ������ ������������ ����, �� ����� ������ ���������� ���� � �����. ' +
                                '���� ����� ������ ���������� � ��� �� �����, �� ������� ������������� ����� ����������� ������, �� ���������� �����, ������������ �� ������� ���, �����������. ' +
                                '�������������� ����� �� ������ ���� ������ ��������� � ��������� �����������. ' +
                                '����� ���������� �������, ���� � ���� ������ �����, �� �������� � ����� ���� ������ (���� � �� �� ����� �� ������ ���� ������ ������ ������������ ���������, ���). ' +
                                '����� ���������� �������, ���� ��� ��� � ������� ��������� ���� � ������ ������������ ������� ������ ����� � ������� ��������� ����. ' +
                                '���� ����� ���������� �������, �� �� ����� ����� ����� ������ ���������� ����� �����, ������ ���������� ���� � ������� ������������ �����. ���� ����� �� ������ ���� �� ���������. ' +
                                '���� ����� �� ����� ��������� �����, �� ���������� ���. ��������� ������ ������ ����������� �������� ����. �� ������� ���� ���� �� ���������. ' +
                                '����� ����, ��� ������ ����� ������ ���� ���, ����� ��������� ����� �� ����� ���� ��� ����������� ����������� �� 10-�� ���������� ���� � ����� ���� ������. '#13#10#13#10 +
                                '������: �� ����, ������ ����� ����� ��������������� ����� ��������: �50-��-50� � ������� �����.' +
                                '�50-��-50� � ����� ����� ����������� 5 ����, ������� �� ����� �� ��������. ��� ����� �� ������ ���� ������ ���������, � ������ ��� ��������� ������� ���������� ��������� 5 ����, ������� �� ����� �� ��������. ' +
                                '��� ����� �� ������ ����� ����. ��� ���� ���������� ����� ���������, ����������� � ������� � ���� �� ���������, � ����� ����� ������ ����������� �� 2.' +
                                '������� ����� -- ����� ����� �������� ���������� ��� ����� �� ������ ������ ���� ������ �� ��������������� ��� ����� �� ������ ���� ������ ���������. ' +
                                ' ��� ���� �������� ������� �� ��������� � ����� ����� �� �����������. ������ ����� ������� ���� �����, ������� �� ����� ��������, ����� ��������� � ����� � ������ ���� ��������� ��� ������. '#13#10#13#10 +
                                '���������: ���������� ���� ����� �������� ������� ���� ����� ��������. ���������� ��� �����, ������� ������ ������� ����� ������.';
end;

procedure TInstructionForm.InstructionScrollBoxMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
    InstructionScrollBox.VertScrollBar.Position:= InstructionScrollBox.VertScrollBar.Position + 12;
end;


procedure TInstructionForm.InstructionScrollBoxMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
    InstructionScrollBox.VertScrollBar.Position:= InstructionScrollBox.VertScrollBar.Position - 12;
end;

end.
