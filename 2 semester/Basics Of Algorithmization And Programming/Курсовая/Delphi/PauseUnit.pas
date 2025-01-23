Unit PauseUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, GameFormUnit, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
    Vcl.Imaging.Pngimage;

Type
    TPauseForm = Class(TForm)
        PauseBackGroundImage: TImage;
        ResumeButtonImage: TImage;
        ExitButtonImage: TImage;
        Procedure ResumeButtonImageClick(Sender: TObject);
        Procedure FormKeyPress(Sender: TObject; Var Key: Char);
        Procedure ExitButtonImageClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    PauseForm: TPauseForm;

Implementation

{$R *.dfm}

Procedure TPauseForm.ExitButtonImageClick(Sender: TObject);
Begin
    Close;
    SpaceInvadersForm.DisableTimers();
    IsStartOpen := False;
    SpaceInvadersForm.FormCreate(Self);

End;

Procedure TPauseForm.FormKeyPress(Sender: TObject; Var Key: Char);
Begin
    If (Key = #13) Or (Key = Char(VK_ESCAPE)) Then
        ResumeButtonImageClick(Self);
End;

Procedure TPauseForm.ResumeButtonImageClick(Sender: TObject);
Begin
    SpaceInvadersForm.EnableTimers();
    Close
End;

End.
