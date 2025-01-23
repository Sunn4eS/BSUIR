Unit DeveloperUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TDeveloperForm = Class(TForm)
        CloseButton: TButton;
        DeveloperLabel1: TLabel;
        DeveloperLabel2: TLabel;
        Procedure CloseButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    DeveloperForm: TDeveloperForm;

Implementation

{$R *.dfm}

Procedure TDeveloperForm.CloseButtonClick(Sender: TObject);
Begin
    Close;
End;

End.
