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
    InstructionLabel.Caption :=
     '1. Введите порядок матрицы N [2; 20].'+ #13#10 +
     '2. Введите элементы мтарицы [-100; 100]' + #13#10 +
     '3. В файле должен содержаться порядок матрицы на первой строке.'+ #13#10 +
     '   Со следующей строки начинается матрица N x N элементов.'+ #13#10 +
     '   Со второй строки записываются элементы матрицы через пробел.'+ #13#10 +
     '   Каждая последующая строка должна содержать элементы матрицы'+ #13#10 +
     '   в количестве N штук.'+ #13#10 +
     '   Строк в матрице должно быть N штук. ';
end;


end.
