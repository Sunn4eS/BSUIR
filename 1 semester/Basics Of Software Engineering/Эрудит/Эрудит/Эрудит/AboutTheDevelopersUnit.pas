Unit AboutTheDevelopersUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TDeveloperForm = Class(TForm)
    DevelopersLabel: TLabel;
    procedure DeveloperFormOnCreate(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    DeveloperForm: TDeveloperForm;

Implementation

{$R *.dfm}

procedure TDeveloperForm.DeveloperFormOnCreate(Sender: TObject);
begin
    DevelopersLabel.Caption := '������ 351005'#13#10'1. ������ ���� - ��������'#13#10'2. ������ ��������� - ��� ���'#13#10'3. ������ ���������� - �����������'#13#10'4. ������ ����� - �����������'#13#10'5. ������� ������ - ��������'#13#10'6. ���������� ��������� - �����������'#13#10'7. ����� ������ - �����������';
end;

End.
