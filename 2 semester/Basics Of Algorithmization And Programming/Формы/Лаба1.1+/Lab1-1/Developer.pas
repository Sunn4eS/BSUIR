unit Developer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TDeveloperForm = class(TForm)
    DeveloperLabel: TLabel;
    CloseButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DeveloperForm: TDeveloperForm;

implementation

{$R *.dfm}

procedure TDeveloperForm.CloseButtonClick(Sender: TObject);
begin
    Close;
end;
Procedure CenterDeveloperFormOnScreen(DeveloperForm: TDeveloperForm);
Begin
    DeveloperForm.Left := (Screen.Width - DeveloperForm.Width) div 2;
    DeveloperForm.Top := (Screen.Height - DeveloperForm.Height) div 2;
End;


procedure TDeveloperForm.FormCreate(Sender: TObject);
begin
    CenterDeveloperFormOnScreen(Self);
    DeveloperLabel.Caption := '�����������: ���������� ��������� ��������' + #13#10 + '������: 351005' + #13#10 + 'Tg: @Sunn4es';
    DeveloperLabel.Update;
end;

end.
