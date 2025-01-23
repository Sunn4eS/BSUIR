unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TDeveloperForm = class(TForm)
    DeveloperLabel1: TLabel;
    DeveloperLabel2: TLabel;
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


end.
