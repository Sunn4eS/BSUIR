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
      '1. ѕтица передвигаетс€ с помощью стрелок.';
End;

End.
