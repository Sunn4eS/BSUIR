program Project1;

uses
  Vcl.Forms,
  fiftyForFiftyUnit in 'fiftyForFiftyUnit.pas' {FiftyForFiftyForm},
  FriendsHelpUnit in 'FriendsHelpUnit.pas' {FriendsHelpForm},
  GameUnit in 'GameUnit.pas' {GameForm},
  GamerPoints in 'GamerPoints.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFiftyForFiftyForm, FiftyForFiftyForm);
  Application.CreateForm(TFriendsHelpForm, FriendsHelpForm);
  Application.CreateForm(TGameForm, GameForm);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
