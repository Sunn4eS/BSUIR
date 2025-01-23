Unit MainForm;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
    Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.Grids, Vcl.ExtCtrls, Vcl.Imaging.Pngimage;

Type
    // BirdSt = Array [0..1] Of Integer;
    TMainTaskForm = Class(TForm)
        MainFormMenu: TMainMenu;
        FileMenu: TMenuItem;
        InstructionMenu: TMenuItem;
        DeveloperMenu: TMenuItem;
        N1: TMenuItem;
        QuitMenu: TMenuItem;
        BackGroundImage: TImage;
        BirdImage: TImage;
        Timer: TTimer;
        Procedure DeveloperMenuClick(Sender: TObject);
        Procedure InstructionMenuClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure QuitMenuClick(Sender: TObject);
        Procedure ShowBird(Index: Byte);
        Procedure FormCreate(Sender: TObject);
        Procedure TimerTimer(Sender: TObject);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);

    Private

        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    MainTaskForm: TMainTaskForm;
   BirdSt: Array [0 .. 1] Of String;
    CurrPosition: Byte;
    DownRightPath: String;
    UpRightPath: String;
    DownLeftPath: String;
    UpLeftPath: String;

Implementation

{$R *.dfm}

Procedure TMainTaskForm.DeveloperMenuClick(Sender: TObject);
Var
    DeveloperForm: TDeveloperForm;
Begin
    DeveloperForm := TDeveloperForm.Create(Self);
    DeveloperForm.ShowModal;
    DeveloperForm.Free;
End;

Function TMainTaskForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    InstructionMenuClick(Self)
End;

Procedure TMainTaskForm.FormKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin

    If (BirdImage.Top < 0) And (Key = VK_UP) Then
        Key := 0;
    If (BirdImage.Top + BirdImage.Height > MainTaskForm.ClientHeight) And
      (Key = VK_Down) Then
        Key := 0;
    If (BirdImage.Left < 0) And (Key = VK_Left) Then
        Key := 0;
    If (BirdImage.Left + BirdImage.Width > MainTaskForm.ClientWidth) And
      (Key = VK_Right) Then
        Key := 0;

    Case Key Of
        VK_LEFT:
            Begin
                BirdSt[0] := DownLeftPath;
                BirdSt[1] := UpLeftPath;
                BirdImage.Left := BirdImage.Left - 10;
            End;
        VK_RIGHT:
            Begin
                BirdSt[0] := DownRightPath;
                BirdSt[1] := UpRightPath;
                BirdImage.Left := BirdImage.Left + 10;
            End;
        VK_UP:
            Begin
                BirdImage.Top := BirdImage.Top - 10;
            End;
        VK_DOWN:
            Begin
                BirdImage.Top := BirdImage.Top + 10;
            End;
    End;

End;

Procedure TMainTaskForm.InstructionMenuClick(Sender: TObject);
Var
    InstructionForm: TInstructionForm;
Begin
    InstructionForm := TInstructionForm.Create(Self);
    InstructionForm.ShowModal;
    InstructionForm.Free;
End;

Procedure TMainTaskForm.QuitMenuClick(Sender: TObject);
Begin
    Close;
End;

Procedure TMainTaskForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
    Confirmation: Integer;
Begin
    Confirmation := Application.MessageBox('Вы действительно хотите выйти?',
      'Выход', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
    CanClose := Confirmation = IDYES;
End;

Procedure TMainTaskForm.FormCreate(Sender: TObject);
Var
    BackGroundPath: String;
Begin

    DownRightPath := ExtractFilePath(Application.ExeName) + 'Images\downRight.png';
    UpRightPath := ExtractFilePath(Application.ExeName) + 'Images\upRight.png';
    DownLeftPath := ExtractFilePath(Application.ExeName) + 'Images\downLeft.png';
    UpLeftPath := ExtractFilePath(Application.ExeName) + 'Images\upLeft.png';

    BirdSt[0] := DownRightPath;
    BirdSt[1] := UpRightPath;
    BackGroundImage.Width := MainTaskForm.Width;
    BackGroundImage.Height := MainTaskForm.Height;
    CurrPosition := 0;

    Timer.Interval := 300;
End;

Procedure TMainTaskForm.ShowBird(Index: Byte);
Begin
    BirdImage.Picture.LoadFromFile(BirdSt[Index]);
End;

Procedure TMainTaskForm.TimerTimer(Sender: TObject);
Begin
    if CurrPosition = 100 then
        CurrPosition := 0;	
    ShowBird(CurrPosition Mod 2);
    Inc(CurrPosition);
End;

End.
