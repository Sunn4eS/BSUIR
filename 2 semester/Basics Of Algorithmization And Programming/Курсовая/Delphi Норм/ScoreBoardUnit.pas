Unit ScoreBoardUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls,
    Vcl.Imaging.Pngimage;

Type
    TScoreBoardForm = Class(TForm)
        ScoreGrid: TStringGrid;
        ScoreBackgroundImage: TImage;
        OkButtonImage: TImage;
        Procedure OkButtonImageClick(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure FormKeyPress(Sender: TObject; Var Key: Char);
        Procedure ScoreGridKeyPress(Sender: TObject; Var Key: Char);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    ScoreBoardForm: TScoreBoardForm;

Implementation

Uses
    PlayersListUnit, GameFormUnit;
{$R *.dfm}

Procedure TScoreBoardForm.FormCreate(Sender: TObject);
Begin
    FillScoreGrid(ScoreGrid, PlayersList);
End;

Procedure TScoreBoardForm.FormKeyPress(Sender: TObject; Var Key: Char);
Begin
    If Key = Char(VK_ESCAPE) Then
        Close;
End;

Procedure TScoreBoardForm.OkButtonImageClick(Sender: TObject);
Begin
    Close;
End;

Procedure TScoreBoardForm.ScoreGridKeyPress(Sender: TObject; Var Key: Char);
Begin
    FormKeyPress(Self, Key);
End;

End.
