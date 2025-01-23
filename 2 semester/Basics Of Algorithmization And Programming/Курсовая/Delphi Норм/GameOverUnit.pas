Unit GameOverUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.Pngimage,
    StartMenuUnit;

Type
    TGameOverForm = Class(TForm)
        GameOverImage: TImage;
        Procedure FormKeyPress(Sender: TObject; Var Key: Char);
        Procedure CreateParams(Var Params: TCreateParams); Override;

    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    GameOverForm: TGameOverForm;
    GameOverExist: Boolean = False;

Implementation

{$R *.dfm}

Uses
    GameFormUnit, PlayersListUnit;

Procedure TGameOverForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Procedure TGameOverForm.FormKeyPress(Sender: TObject; Var Key: Char);
Begin
    If Key = #13 Then
    Begin
    
        PlayerInGame.Score := Score;
        IsStartOpen := False;
        CheckHighScore(PlayerInGame);
        
        StartMenuForm.SavePlayersToFile();
       // PlayerInGame := CurrPlayer;
        Close;

    End;
End;

End.
