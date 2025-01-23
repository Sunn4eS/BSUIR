Unit AboutTheDevelopersUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TDeveloperForm = Class(TForm)
    DevelopersLabel: TLabel;
    procedure DeveloperFormOnCreate(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    DeveloperForm: TDeveloperForm;

Implementation

{$R *.dfm}

procedure TDeveloperForm.DeveloperFormOnCreate(Sender: TObject);
begin
    DevelopersLabel.Caption := 'Группа 351005'#13#10'1. Захвей Иван - Менеджер'#13#10'2. Егоров Александр - Тим Лид'#13#10'3. Бетеня Константин - Программист'#13#10'4. Галуха Павел - Программист'#13#10'5. Буневич Полина - Аналитик'#13#10'6. Бражалович Александр - Тестировщик'#13#10'7. Гасюк Даниил - Тестировщик';
end;

End.
