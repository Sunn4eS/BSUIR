Unit AddNewPlayerUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.Pngimage, Vcl.ExtCtrls,
    Vcl.StdCtrls;

Type
    TAddNewPlayerForm = Class(TForm)
        AddNewPlayerBackGroundImage: TImage;
        AddNewPlayerButton: TImage;
        NameEdit: TEdit;
        Procedure NameEditChange(Sender: TObject);
        Procedure AddNewPlayerButtonClick(Sender: TObject);
        Procedure FormKeyPress(Sender: TObject; Var Key: Char);
        Procedure NameEditKeyPress(Sender: TObject; Var Key: Char);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    AddNewPlayerForm: TAddNewPlayerForm;

Implementation

Uses
    PlayersListUnit, GameFormUnit;

{$R *.dfm}

Procedure TAddNewPlayerForm.AddNewPlayerButtonClick(Sender: TObject);
Begin
    If Not IsExistPlayer(PlayersList, NameEdit.Text) Then
    Begin
        AddPlayer(PlayersList, NameEdit.Text, 0);
    End;
    Close;

End;

Procedure TAddNewPlayerForm.FormKeyPress(Sender: TObject; Var Key: Char);
Begin
    If (Key = #13) And (AddNewPlayerButton.Enabled) And
      (AddNewPlayerButton.Visible) Then
        AddNewPlayerButtonClick(Self);
    If Key = Char(VK_ESCAPE) Then
        Close;

End;

Procedure TAddNewPlayerForm.NameEditChange(Sender: TObject);
Begin
    AddNewPlayerButton.Enabled := (NameEdit.Text <> '') And
      (Length(NameEdit.Text) < 11);
    AddNewPlayerButton.Visible := (NameEdit.Text <> '') And
      (Length(NameEdit.Text) < 11) And Not IsExistPlayer(PlayersList,
      NameEdit.Text);

End;

Procedure TAddNewPlayerForm.NameEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    FormKeyPress(Self, Key);
End;

End.
