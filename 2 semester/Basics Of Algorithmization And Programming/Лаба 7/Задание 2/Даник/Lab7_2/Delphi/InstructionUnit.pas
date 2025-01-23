Unit InstructionUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TInstructionForm = Class(TForm)
        CloseButton: TButton;
        Button1: TButton;
        InstructionLabel1: TLabel;
        InstructionLabel4: TLabel;
        InstructionLabel2: TLabel;
        Procedure CloseButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    InstructionForm: TInstructionForm;

Implementation

{$R *.dfm}

Procedure TInstructionForm.CloseButtonClick(Sender: TObject);
Begin
    Close;
End;

End.
