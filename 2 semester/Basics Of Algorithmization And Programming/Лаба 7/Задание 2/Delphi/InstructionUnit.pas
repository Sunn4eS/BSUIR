Unit InstructionUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TInstructionForm = Class(TForm)
        InstructionLabel1: TLabel;
        InstructionLabel4: TLabel;
        InstructionLabel2: TLabel;
        
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    InstructionForm: TInstructionForm;

Implementation

{$R *.dfm}

End.
