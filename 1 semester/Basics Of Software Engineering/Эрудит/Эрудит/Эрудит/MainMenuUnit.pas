Unit MainMenuUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus,
    AboutTheDevelopersUnit, InstructionUnit, GameUnit, BackendGamerUnit,
    BackendStartUnit, ExitUnit;

Type
    TStartForm = Class(TForm)
        TabsMainMenu: TMainMenu;
        InstructionTab: TMenuItem;
        DeveloperTab: TMenuItem;

        TitleLabel: TLabel;

        LanguageLabel: TLabel;
        LanguageComboBox: TComboBox;

        PlayersLabel: TLabel;
        PlayersComboBox: TComboBox;

        PlayButton: TButton;

        Procedure FormCreate(Sender: TObject);

        Procedure InstructionTabOnClick(Sender: TObject);
        Procedure DeveloperTabOnClick(Sender: TObject);

        Procedure LanguageComboBoxChange(Sender: TObject);
        Procedure PlayersComboBoxChange(Sender: TObject);

        Procedure PlayersComboBoxClick(Sender: TObject);
        Procedure PlayersComboBoxKeyDown(Sender: TObject; Var Key: Word;
            Shift: TShiftState);

        Procedure PlayButtonClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
    Private
    Public
    End;

Var
    StartForm: TStartForm;

Implementation

{$R *.dfm}

Procedure TStartForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Begin
    Application.CreateForm(TExitForm, ExitForm);
    ExitForm.ShowModal;
    CanClose := ExitForm.GetStatus();
    ExitForm.Destroy();
End;

Procedure TStartForm.FormCreate(Sender: TObject);
Begin
    Start := TStart.Create();
End;

Procedure TStartForm.InstructionTabOnClick(Sender: TObject);
Var
    InstructionForm: TInstructionForm;
Begin
    InstructionForm := TInstructionForm.Create(Self);
    // InstructionForm.Icon := MainForm.Icon;
    InstructionForm.ShowModal;
    InstructionForm.Free;
End;

Procedure TStartForm.DeveloperTabOnClick(Sender: TObject);
Var
    DeveloperForm: TDeveloperForm;
Begin
    DeveloperForm := TDeveloperForm.Create(Self);
    // InstructionForm.Icon := MainForm.Icon;
    DeveloperForm.ShowModal;
    DeveloperForm.Free;
End;

Procedure TStartForm.LanguageComboBoxChange(Sender: TObject);
Begin
    If LanguageComboBox.Items[LanguageComboBox.ItemIndex] = 'Русский' Then
        Start.SetLanguage(TLanguage.RUS)
    Else
        Start.SetLanguage(TLanguage.EN);
End;

Procedure TStartForm.PlayersComboBoxChange(Sender: TObject);
Begin
    Start.SetPlayers(StrToInt(PlayersComboBox.Items
        [PlayersComboBox.ItemIndex]));
End;

Procedure TStartForm.PlayersComboBoxClick(Sender: TObject);
Begin
    If (PlayersComboBox.Text <> '') And (LanguageComboBox.Text <> '') Then
        PlayButton.Enabled := True
    Else
        PlayButton.Enabled := False;
End;

Procedure TStartForm.PlayersComboBoxKeyDown(Sender: TObject; Var Key: Word;
    Shift: TShiftState);
Begin
    If (Key = 13) And (PlayersComboBox.Text <> '') And
        (LanguageComboBox.Text <> '') Then
        PlayButtonClick(PlayButton);
End;

Procedure TStartForm.PlayButtonClick(Sender: TObject);
Begin
    Application.CreateForm(TGameForm, GameForm);
    StartForm.Hide;
    GameForm.ShowModal;
    GameForm.Destroy();
    StartForm.Show;
End;

End.
