unit Instruction;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TInstructionForm = class(TForm)
    InstructionLabel: TLabel;
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
    InstructionLabel.Caption :=
     '1. Введите количество членов последовательности [2; 100].'+ #13#10 +
     '2. Введите члены последовательности [-100; 100]' + #13#10 +
     '3. В файле должно содержаться количество членов последовательности'+ #13#10 +
     'на первой строке. На второй строке сами члены'+ #13#10 +
     ' [-100; 100] последовательности через пробел. ';
end;


end.
