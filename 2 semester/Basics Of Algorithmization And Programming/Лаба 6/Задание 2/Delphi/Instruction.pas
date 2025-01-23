Unit Instruction;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TInstructionForm = Class(TForm)
        InstructionLabel: TLabel;
        Label1: TLabel;
        Procedure CloseButtonClick(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
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

Procedure TInstructionForm.CloseButtonClick(Sender: TObject);
Begin
    Close;
End;

Procedure TInstructionForm.FormCreate(Sender: TObject);
Begin
    CenterFormOnScreen(Self);
    InstructionLabel.Caption :=
      '1. Для добавления города нажмите на кнопку "Добавить город".' + #13#10 +
      '2. Для добавления новой дороги между городами, нажмите на кнопку "Добавить дорогу".'
      + #13#10 + '3. Чтобы найти путь нажмите на кнопку "Найти путь".' + #13#10
      + 'Работа с файлом:' + #13#10 +
      '1. На первой строке должно быть указано количество городов.' + #13#10 +
      '2. На следующих строках располагается матрица смежности для указания дорог.'
      + #13#10 +
      '3. На последней строке файла написаны два номера города, от которого и к которому'
      + #13#10 + ' вы хотите найти путь.';
End;

Function TInstructionForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

End.
