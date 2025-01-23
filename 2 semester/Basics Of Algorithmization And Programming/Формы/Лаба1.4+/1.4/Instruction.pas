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
     '1. Вам нужно ввести количество элементов массива [1; 20]' + #13#10 +
     '2. В файле должно содержаться количество элементов'+ #13#10 +
     'на первой строке. На второй строке элементы массива [-100; 100]';
end;


end.
