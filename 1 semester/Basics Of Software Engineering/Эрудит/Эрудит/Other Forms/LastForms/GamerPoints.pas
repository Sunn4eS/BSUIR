Unit GamerPoints;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, BackendGamerUnit;

Type
    TPointsListForm = Class(TForm)
        GamerPointsGrid: TStringGrid;
    procedure FormCreate(Var Gamers: TGamers);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    PointsListForm: TPointsListForm;

Implementation

{$R *.dfm}
{ TPointsList }

Procedure TPointsListForm.FormCreate(Var Gamers: TGamers);
Var
    I, PlayersCount: Integer;
Begin
    PlayersCount := Length(Gamers);
    GamerPointsGrid.RowCount := PlayersCount + 1;
    GamerPointsGrid.Cells[0, 0] := '№ игрока';
    GamerPointsGrid.Cells[1, 0] := 'Очки';
    For I := 1 To PlayersCount Do
    Begin
        GamerPointsGrid.Cells[0, I] := 'Игрок ' + IntToStr(I);
        GamerPointsGrid.Cells[1, I] := IntToStr(Gamers[I - 1].GetPoints());
    End;
End;

End.
