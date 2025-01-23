Unit Instruction;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TInstructionForm = Class(TForm)
        InstructionLabel: TLabel;
        Procedure FormCreate(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    InstructionForm: TInstructionForm;

Implementation

{$R *.dfm}

Procedure CenterFormOnScreen(InstructionForm: TInstructionForm);
Begin
    InstructionForm.Left := (Screen.Width - InstructionForm.Width) Div 2;
    InstructionForm.Top := (Screen.Height - InstructionForm.Height) Div 2;
End;

Procedure TInstructionForm.FormCreate(Sender: TObject);
Begin
    CenterFormOnScreen(Self);
    InstructionLabel.Caption := '1. Введите порядок матрицы N [2; 4].' + #13#10
      + '2. Введите элементы мтарицы [-99; 100]' + #13#10 +
      '3. В "начальный элемент" нужно ввести координаты точки' + #13#10 +
      '   от которой вы хотите искать путь. В "конечный элемент"' + #13#10 +
      '   координаты на котором вы хотите закончить обход матрицы.' + #13#10 +
      '4.1 В файле должно содержаться количество столбцов матрицы на первой строке.'
      + #13#10 + '    Во второй строке количество строк матрицы.' + #13#10 +
      '4.2 На третей и четвёртой строках координаты I пути обхода' + #13#10 +
      '    (третья строка I1, четвёртая строка I2).' + #13#10 +
      '4.3 На пятой и шестой строках координаты J пути обхода' + #13#10 +
      '    (пятая строка J1, шестая строка J2)' + #13#10 +
      '4.4 С седьмой строки записываются элементы матрицы.' + #13#10 +
      '    Элементы строк матрцы записываются через пробел.' + #13#10 +
      '    Далее строки матрицы записываются с новой строки.';
End;

End.
