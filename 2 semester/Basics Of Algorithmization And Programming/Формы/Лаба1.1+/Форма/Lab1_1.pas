unit Lab1_1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, InstructionForm;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    Instruction: TMenuItem;
    AboutDeveloper: TMenuItem;
    OpenTab: TMenuItem;
    SaveTab: TMenuItem;
    ExitTab: TMenuItem;
    N7: TMenuItem;
    TaskLabel: TLabel;
    InputEdit: TEdit;
    OutEdit: TEdit;
    InputLabel: TLabel;
    ОutLabel: TLabel;
    InputButton: TButton;
    procedure InputButtonClick(Sender: TObject);
    procedure InputEditKeyPress(Sender: TObject; var Key: Char);
    procedure InputEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure InstructionClick(Sender: TObject);







  private
    { Private declarations }
  public
    { Public declarations }
  end;

Const
    MIN_MONTH = 1;
    MAX_MONTH = 12;

var
  MainForm: TMainForm;
  Month: String;

implementation

{$R *.dfm}




Function MainAlgorithm(NumOfMonth: Integer): String;
Var
    IsIncorrect: Boolean;
    Month: String;
Begin
    case NumOfMonth of
    3..5:
        Month := 'Весна';
    6..8:
        Month := 'Лето';
    9..11:
        Month := 'Осень';
    1, 2, 12:
        Month := 'Зима';

    end;
    MainAlgorithm := Month;
End;

procedure TMainForm.InputButtonClick(Sender: TObject);
Var
    NumOfMonth: Integer;
begin
   if TryStrToInt(InputEdit.Text, NumOfMonth) then
    Begin
        Month := MainAlgorithm(NumOfMonth);
    End;
    OutEdit.Text := Month;
end;



procedure TMainForm.InputEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_INSERT) and (Shift = [ssShift]) then
    Key := 0;
end;

procedure TMainForm.InputEditKeyPress(Sender: TObject; var Key: Char);
begin
    if (Key = #22) or ((Key = 'v') and (GetKeyState(VK_CONTROL) < 0)) then
    Key := #0;
end;


procedure TMainForm.InstructionClick(Sender: TObject);
Var
    InstructionForm: TInstrForm;
begin
    InstructionForm := TInstrForm.Create(Self);
    InstructionForm.ShowModal;
    InstructionForm.Free;

end;

end.