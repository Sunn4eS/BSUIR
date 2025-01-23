Unit StartMenuUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.Pngimage;

Type
    TStartMenuForm = Class(TForm)
        StartMenuBackground: TImage;
        StartButtonImage: TImage;
        PlayerButtonImage: TImage;
        ScoreListButtonImage: TImage;
        SettingsButtonImage: TImage;
        ExitButtonImage: TImage;
        Procedure CreateForm(FormClass: TFormClass);
        Procedure StartButtonImageClick(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure FormClose(Sender: TObject; Var Action: TCloseAction);
        Procedure CreateParams(Var Params: TCreateParams); Override;
        Procedure ExitButtonImageClick(Sender: TObject);
        Procedure PlayerButtonImageClick(Sender: TObject);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure ScoreListButtonImageClick(Sender: TObject);
        Procedure SavePlayersToFile();
        Procedure ReadPlayersFromFile();

    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    StartMenuForm: TStartMenuForm;
    InGame: Boolean = True;
    

Implementation

{$R *.dfm}

Uses
    GameFormUnit, GameOverUnit, PlayerFormUnit, ScoreBoardUnit, FileUnit,
    PlayersListUnit;

Procedure TStartMenuForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Procedure TStartMenuForm.ExitButtonImageClick(Sender: TObject);
Begin

    IsStartOpen := False;
    ShouldClose := True;

    Close;

End;

Procedure TStartMenuForm.CreateForm(FormClass: TFormClass);
Var
    Form: TForm;
Begin
    StartMenuForm.Visible := False;

    Form := FormClass.Create(StartMenuForm);
    Form.Icon := StartMenuForm.Icon;
    Form.ShowModal;

    StartMenuForm.Visible := True;
End;

Procedure TStartMenuForm.FormClose(Sender: TObject; Var Action: TCloseAction);
Begin
    ShouldClose := True;

End;

Procedure TStartMenuForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
    Confirmation: Integer;
Begin
    If Not IsStartOpen Then
    Begin

        Confirmation := Application.MessageBox('Вы действительно хотите выйти?',
          'Выход', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
        ShouldClose := Confirmation = IDYES;
        CanClose := Confirmation = IDYES;
        SavePlayersToFile();

    End
    Else
    Begin
        CanClose := True;
        IsStartOpen := False;
        ShouldClose := False;
        SavePlayersToFile();
    End;

End;

Procedure TStartMenuForm.SavePlayersToFile();
Var
    OutputFile: TPlayerFile;
    TempPlayerList: Player;
    ProjectPath: String;
    FileName: String;

Begin
    ProjectPath := ExtractFilePath(ParamStr(0));
    FileName := ProjectPath + 'PlayerData.dat';
    AssignFile(OutputFile, FileName);
    WriteFileData(OutputFile, PlayersList);
End;

Procedure TStartMenuForm.ReadPlayersFromFile();
Var
    InputFile: TPlayerFile;
    TempPlayerList: Player;
    IsCorrect: Boolean;
    ProjectPath: String;
    FileName: String;
Begin
    ProjectPath := ExtractFilePath(ParamStr(0));
    FileName := ProjectPath + 'PlayerData.dat';

    TempPlayerList := Nil;
    IsCorrect := ReadFileData(InputFile, TempPlayerList, FileName);
    If IsCorrect Then
    Begin
        ClearPlayer(PlayersList);
        PlayersList := TempPlayerList;
    End
    Else
    Begin
        ClearPlayer(TempPlayerList);
        Application.MessageBox('Содержимое файла повреждено!', 'Ошибка',
          MB_OK + MB_ICONERROR);
    End;

End;

Procedure TStartMenuForm.FormCreate(Sender: TObject);
Begin
    IsStartOpen := False;
    ShouldClose := False;
    ReadPlayersFromFile;
    StartButtonImage.Visible := PlayerInGame <> Nil;
    ScoreListButtonImage.Visible := PlayerInGame <> Nil;

End;

Procedure TStartMenuForm.FormKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    If Key = VK_ESCAPE Then
    Begin
        IsStartOpen := False;
        Close;
    End;
    If Key = VK_F1 Then
        MessageBox(Handle, 'Бражалович Александр Иванович.' + #13#10 +
          'Студент группы 351004', 'О разработчике',
          MB_OK Or MB_ICONINFORMATION);
End;

Procedure TStartMenuForm.PlayerButtonImageClick(Sender: TObject);
Begin
    PlayersForm := TPlayersForm.Create(StartMenuForm);
    PlayersForm.ShowModal;
    StartButtonImage.Visible := PlayerInGame <> Nil;
    ScoreListButtonImage.Visible := PlayerInGame <> Nil;
End;

Procedure TStartMenuForm.ScoreListButtonImageClick(Sender: TObject);
Begin
    ScoreBoardForm := TScoreBoardForm.Create(StartMenuForm);
    ScoreBoardForm.ShowModal;

End;

Procedure TStartMenuForm.StartButtonImageClick(Sender: TObject);
Begin
    IsStartOpen := True;
    ShouldClose := False;
    Lives := 3;
    SpaceInvadersForm.Visible := True;
    PlayerInGame := SearchPlayer(PlayersList, PlayerName);
    SpaceInvadersForm.FormCreate(Self);
    Close;

End;

End.
