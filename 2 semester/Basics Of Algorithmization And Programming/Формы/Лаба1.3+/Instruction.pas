unit Instruction;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TInstructionForm = class(TForm)
    CloseButton: TButton;
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
     '1. Введите X в диапазоне (-1; 1].'+ #13#10 +
     '2. Введите EPS в диапазоне [0,0001; 1]' + #13#10 +
     '3. Значения не должны иметь более пяти' + #13#10 +
     'знаков после запятой. ' + #13#10+
     '4. В файле должны содержаться два числа на ' + #13#10 +
     'разных строчках. Первая строка Х, вторая EPS.';
end;


end.
