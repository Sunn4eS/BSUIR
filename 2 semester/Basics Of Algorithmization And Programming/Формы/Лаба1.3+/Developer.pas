unit Developer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TDeveloperForm = class(TForm)
    DeveloperLabel: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DeveloperForm: TDeveloperForm;

implementation

{$R *.dfm}

procedure TDeveloperForm.Button1Click(Sender: TObject);
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
    DeveloperLabel.Caption := 'Разработчик: Бражалович Александр Иванович' + #13#10 + 'Группа: 351005' + #13#10 + 'Tg: @Sunn4es';
    DeveloperLabel.Update;
end;


end.
