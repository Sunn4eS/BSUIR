unit InstrForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TInstrForm = class(TForm)
    ClosuInstrFormButton: TButton;
    procedure ClosuInstrFormButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InstructionForm: TInstrForm;

implementation

{$R *.dfm}

procedure TInstrForm.ClosuInstrFormButtonClick(Sender: TObject);
begin
    Close;
end;

end.
