unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TInstructionForm = class(TForm)
    CloseButton: TButton;
    InstructionLabel1: TLabel;
    InstructionLabel4: TLabel;
    InstructionLabel2: TLabel;
    procedure CloseButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InstructionForm: TInstructionForm;

implementation

{$R *.dfm}

procedure TInstructionForm.CloseButtonClick(Sender: TObject);
begin
    Close;
end;

end.
