Unit Instruction;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TInstructionForm = Class(TForm)
        InstructionLabel: TLabel;
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
      '1. Чтобы добавить новый контакт нужно нажать на кнопку "Добавить контакт".'
      + #13#10 +
      '2. Для удаления нужно нажать на нужный контакт в списке и нажать кнопку "Удалить"'
      + #13#10 +
      '3. Для просмотра списка в обратном порядке нужно нажать на кнопку "Обратный порядок"'
      + #13#10 + '' + #13#10 + 'Для загрузки контактов из текстового файла:' +
      #13#10 + '1. На первой строке имя контакта.' + #13#10 +
      '2. На второй строке номер телефона (без +375).';
End;

Function TInstructionForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

End.
