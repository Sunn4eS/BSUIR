program SpaceInvaders;

uses
  Vcl.Forms,
  GameFormUnit in 'GameFormUnit.pas' {SpaceInvadersForm},
  ImageUnit in 'ImageUnit.pas',
  RocketUnit in 'RocketUnit.pas',
  AlienUnit in 'AlienUnit.pas',
  GameOverUnit in 'GameOverUnit.pas' {GameOverForm},
  PauseUnit in 'PauseUnit.pas' {PauseForm},
  StartMenuUnit in 'StartMenuUnit.pas' {StartMenuForm},
  PlayersListUnit in 'PlayersListUnit.pas',
  PlayerFormUnit in 'PlayerFormUnit.pas' {PlayersForm},
  AddNewPlayerUnit in 'AddNewPlayerUnit.pas' {AddNewPlayerForm},
  ScoreBoardUnit in 'ScoreBoardUnit.pas' {ScoreBoardForm},
  FileUnit in 'FileUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSpaceInvadersForm, SpaceInvadersForm);
  Application.CreateForm(TPlayersForm, PlayersForm);
  Application.CreateForm(TAddNewPlayerForm, AddNewPlayerForm);
  Application.CreateForm(TScoreBoardForm, ScoreBoardForm);
  Application.Run;
end.
