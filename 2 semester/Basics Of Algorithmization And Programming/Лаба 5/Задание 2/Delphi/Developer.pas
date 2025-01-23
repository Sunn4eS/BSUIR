Unit Developer;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TDeveloperForm = Class(TForm)
        DeveloperLabel: TLabel;
        Procedure Button1Click(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    DeveloperForm: TDeveloperForm;

Implementation

{$R *.dfm}

Procedure TDeveloperForm.Button1Click(Sender: TObject);
Begin
    Close;
End;

Procedure CenterDeveloperFormOnScreen(DeveloperForm: TDeveloperForm);
Begin
    DeveloperForm.Left := (Screen.Width - DeveloperForm.Width) Div 2;
    DeveloperForm.Top := (Screen.Height - DeveloperForm.Height) Div 2;
End;

Procedure TDeveloperForm.FormCreate(Sender: TObject);
Begin
    CenterDeveloperFormOnScreen(Self);
    DeveloperLabel.Caption := 'Разработчик: Бражалович Александр Иванович' +
      #13#10 + 'Группа: 351005' + #13#10 + 'Tg: @Sunn4es';
    DeveloperLabel.Update;
End;

End.
