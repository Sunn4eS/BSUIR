unit Instruction;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TInstructionForm = class(TForm)
    InstructionLabel: TLabel;
    CloseButton: TButton;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InstructionForm: TInstructionForm;

implementation

{$R *.dfm}
procedure CenterFormOnScreen(InstructionForm: TInstructionForm);
begin
  InstructionForm.Left := (Screen.Width - InstructionForm.Width) div 2;
  InstructionForm.Top := (Screen.Height - InstructionForm.Height) div 2;
end;


procedure TInstructionForm.CloseButtonClick(Sender: TObject);
begin
    Close;
end;

procedure TInstructionForm.FormCreate(Sender: TObject);
begin
    CenterFormOnScreen(Self);
    InstructionLabel.Caption := '1. Для получения результата нужно ввести число'  + #13#10 +
                                'от 1 до 12.' + #13#10 +
                                '2. В файле должно находится только число.'
end;

end.
