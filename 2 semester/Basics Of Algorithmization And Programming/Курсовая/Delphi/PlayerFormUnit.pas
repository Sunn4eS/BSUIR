Unit PlayerFormUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.Pngimage,
    Vcl.ExtCtrls;

Type
    TPlayersForm = Class(TForm)
        PlayerComboBox: TComboBox;
        PlayerBackgroundImage: TImage;
        NewPlayerButtonImage: TImage;
        DeletePlayerButtonImage: TImage;
        SavePlayerButtonImage: TImage;
        Procedure NewPlayerButtonImageClick(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure PlayerComboBoxChange(Sender: TObject);
        Procedure SavePlayerButtonImageClick(Sender: TObject);
        Procedure DeletePlayerButtonImageClick(Sender: TObject);
        Procedure FormKeyPress(Sender: TObject; Var Key: Char);
        Procedure PlayerComboBoxKeyPress(Sender: TObject; Var Key: Char);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    PlayersForm: TPlayersForm;

Implementation

Uses
    AddNewPlayerUnit, PlayersListUnit, GameFormUnit, StartMenuUnit;
{$R *.dfm}

Procedure FillComboBox(ComboBox: TComboBox);
Var
    CurrPlayer: Player;
Begin
    ComboBox.Items.Clear;

    CurrPlayer := PlayersList;
    While CurrPlayer <> Nil Do
    Begin
        ComboBox.Items.Add(CurrPlayer.Name);
        CurrPlayer := CurrPlayer^.Next;
    End;

    ComboBox.ItemIndex := 0;
End;

Procedure TPlayersForm.DeletePlayerButtonImageClick(Sender: TObject);
Var
    Confirmation: Integer;
Begin
    Confirmation := Application.MessageBox
      ('Вы действительно хотите удалить игрока?', 'Удаление',
      MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
    If Confirmation = IDYES Then
    Begin

        DeletePlayer(PlayersList, PlayerComboBox.Text);
        PlayerInGame := Nil;
        SavePlayerButtonImage.Visible := PlayersList <> Nil;
        FillComboBox(PlayerComboBox);
        PlayerComboBoxChange(Self);
        StartMenuForm.SavePlayersToFile();

    End;

End;

Procedure TPlayersForm.FormCreate(Sender: TObject);
Begin
    FillComboBox(PlayerComboBox);
End;

Procedure TPlayersForm.FormKeyPress(Sender: TObject; Var Key: Char);
Begin
    If (Key = #13) And (SavePlayerButtonImage.Enabled) And
      (SavePlayerButtonImage.Visible) Then
        SavePlayerButtonImageClick(Self);
    If (Key = Char(VK_DELETE)) And (DeletePlayerButtonImage.Enabled) And
      (DeletePlayerButtonImage.Visible) Then
        DeletePlayerButtonImageClick(Self);
    If Key = Char(VK_ESCAPE) Then
        Close;

End;

Procedure TPlayersForm.NewPlayerButtonImageClick(Sender: TObject);
Begin

    AddNewPlayerForm := TAddNewPlayerForm.Create(PlayersForm);
    AddNewPlayerForm.ShowModal;
    FillComboBox(PlayerComboBox);
    PlayerComboBoxChange(Self);
    StartMenuForm.SavePlayersToFile();

End;

Procedure TPlayersForm.PlayerComboBoxChange(Sender: TObject);
Begin
    SavePlayerButtonImage.Visible := (PlayerComboBox.ItemIndex >= 0) And
      (PlayersList <> NIl);
    DeletePlayerButtonImage.Visible := (PlayerComboBox.ItemIndex >= 0) And
      (PlayersList <> NIl);
End;

Procedure TPlayersForm.PlayerComboBoxKeyPress(Sender: TObject; Var Key: Char);
Begin
    FormKeyPress(Self, Key);
End;

Procedure TPlayersForm.SavePlayerButtonImageClick(Sender: TObject);
Begin
    PlayerInGame := SearchPlayer(PlayersList, PlayerComboBox.Text);
    Close;
End;

End.
