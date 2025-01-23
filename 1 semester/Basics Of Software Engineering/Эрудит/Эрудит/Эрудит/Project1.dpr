Program Project1;

Uses
    Vcl.Forms,
    MainMenuUnit In 'MainMenuUnit.pas' {StartForm} ,
    InstructionUnit In 'InstructionUnit.pas' {InstructionForm} ,
    AboutTheDevelopersUnit In 'AboutTheDevelopersUnit.pas' {DeveloperForm} ,
    BackendGameDictionaryUnit In '..\Backend\BackendGameDictionaryUnit.pas',
    BackendGamerUnit In '..\Backend\BackendGamerUnit.pas',
    BackendLetterBankUnit In '..\Backend\BackendLetterBankUnit.pas',
    GameUnit In '..\Other Forms\LastForms\GameUnit.pas' {GameForm} ,
    FriendsHelpUnit
        In '..\Other Forms\LastForms\FriendsHelpUnit.pas' {FriendsHelpForm} ,
    FiftyForFiftyUnit
        In '..\Other Forms\LastForms\fiftyForFiftyUnit.pas' {FiftyForFiftyForm} ,
    BackendStartUnit In '..\Backend\BackendStartUnit.pas',
    Vcl.Themes,
    Vcl.Styles,
    GamerPoints In '..\Other Forms\LastForms\GamerPoints.pas' {PointsListForm} ,
    ExitUnit In '..\Other Forms\LastForms\ExitUnit.pas' {ExitForm} ,
    QuitUnit In '..\Other Forms\LastForms\QuitUnit.pas' {QuitForm};

{$R *.res}

Begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TStartForm, StartForm);
    Application.CreateForm(TInstructionForm, InstructionForm);
    Application.CreateForm(TDeveloperForm, DeveloperForm);
    Application.CreateForm(TFriendsHelpForm, FriendsHelpForm);
    Application.CreateForm(TFiftyForFiftyForm, FiftyForFiftyForm);
    Application.Run;

End.
