unit MainForm;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, Instruction,
    Developer, Vcl.ExtDlgs;

type
    ERRORS_LIST = (CORRECT, RANGE_ERR, NUM_ERR,
      NOT_READABLE, NOT_WRITEABLE, FILE_EMPTY, LINE_ERR);

    TMainTaskForm = class(TForm)
        TaskLabel: TLabel;
        MainFormMenu: TMainMenu;
        FileMenu: TMenuItem;
        OpenMenu: TMenuItem;
        SaveMenu: TMenuItem;
        N1: TMenuItem;
        QuitMenu: TMenuItem;
        InstructionMenu: TMenuItem;
        DeveloperMenu: TMenuItem;
        OpenFile: TOpenDialog;
        EnterEdit: TEdit;
        OutEdit: TEdit;
        EnterLabel: TLabel;
        OutLabel: TLabel;
        ResultButton: TButton;
    SaveTextFile: TSaveTextFileDialog;
    EnterStr2Edit: TEdit;
    Enter2Label: TLabel;
        procedure FormCreate(Sender: TObject);
        procedure DeveloperMenuClick(Sender: TObject);
        procedure InstructionMenuClick(Sender: TObject);
        procedure SaveMenuClick(Sender: TObject);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure QuitMenuClick(Sender: TObject);
        procedure OpenMenuClick(Sender: TObject);
        Function FileReading(Var F: TextFile): ERRORS_LIST;
        Procedure GetDataFromFile(Var F: TextFile; Sender: TObject);
        procedure ResultButtonClick(Sender: TObject);
        procedure OutEditChange(Sender: TObject);
        procedure EnterEditChange(Sender: TObject);
    procedure EnterStr2EditChange(Sender: TObject);
    function FormHelp(Command: Word; Data: NativeInt;
      var CallHelp: Boolean): Boolean;
     {   procedure EnterEditContextPopup(Sender: TObject; MousePos: TPoint;
          var Handled: Boolean);
        procedure EnterEditKeyPress(Sender: TObject; var Key: Char);
        procedure EnterEditKeyDown(Sender: TObject; var Key: Word;
          Shift: TShiftState);
        procedure EnterEditClick(Sender: TObject); }

    private
        { Private declarations }
    public
        { Public declarations }
    end;

Const
    ERRORS: Array [ERRORS_LIST] Of String = ('',
      'Значение не попадает в диапазон!',
      'Проверьте корректность ввода данных!',
      'Файл закрыт для чтения!',
      'Файл закрыт для записи!', 'Файл пуст!',
      'Неверное число строк в файле');
    DIGITS = ['0' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_DAY = 1;
    MAX_DAY = 10000;
    PERCENTAGE = 0.1;
    SECONDDAY = 2;

var
    MainTaskForm: TMainTaskForm;

implementation

{$R *.dfm}

Var
    Saved: Boolean = True;
    PerformCloseQuery: Boolean = True;

procedure TMainTaskForm.DeveloperMenuClick(Sender: TObject);
Var
    DeveloperForm: TDeveloperForm;
begin
    DeveloperForm := TDeveloperForm.Create(Self);
    DeveloperForm.ShowModal;
    DeveloperForm.Free;
end;

procedure TMainTaskForm.FormCreate(Sender: TObject);
begin
    TaskLabel.Caption := 'Данная программа оределить номер позиции' + #13#10 + 'последнего вхождения строки st1 в строку st2.' + #13#10 + 'Если такого нет, то выводит 0.';
    ResultButton.Enabled := False;
end;

function TMainTaskForm.FormHelp(Command: Word; Data: NativeInt;
  var CallHelp: Boolean): Boolean;
begin
    CallHelp := False;
    InstructionMenuClick(Self);
end;

procedure TMainTaskForm.InstructionMenuClick(Sender: TObject);
Var
    InstructionForm: TInstructionForm;
begin
    InstructionForm := TInstructionForm.Create(Self);
    InstructionForm.ShowModal;
    InstructionForm.Free;
end;

Function IsReadable(Var F: TextFile): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
Begin
    ERRORS := CORRECT;
    Try
        Try
            Reset(F);
        Finally
            CloseFile(F);
        End;
    Except
        ERRORS := NOT_READABLE;
    End;
    IsReadable := ERRORS;
End;

procedure TMainTaskForm.SaveMenuClick(Sender: TObject);
Var
    Error: ERRORS_LIST;
    F: TextFile;
    FileName: String;
Begin
    If SaveTextFile.Execute Then
    Begin
        FileName := SaveTextFile.FileName;
        FileName := ChangeFileExt(FileName, '.txt');
        AssignFile(F, FileName);
        If FileExists(FileName) Then
        Begin
            Error := IsReadable(F);
            If Error = CORRECT Then
            Begin
                Rewrite(F);
                Write(F, OutEdit.Text);
                CloseFile(F);
                Saved := True;
            End;
            If Error <> CORRECT Then
            Begin
                Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка', MB_OK Or MB_ICONINFORMATION);
                Saved := False;
            End;
        End
        Else
        Begin
            Rewrite(F);
            Write(F, OutEdit.Text);
            CloseFile(F);
            Saved := True;
        End;

    End;
End;


procedure TMainTaskForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
Var
    Confirmation: Integer;
Begin
    If PerformCloseQuery Then
    Begin
        If (Saved = False) Then
        Begin
            Confirmation := Application.MessageBox
              ('Вы не сохранили файл, хотите ли сохранить?', 'Выход',
              MB_YESNOCANCEl + MB_ICONQUESTION + MB_DEFBUTTON2);
            Case Confirmation Of
                mrYes:
                    Begin
                        SaveMenuClick(Sender);
                        If Saved = True Then
                            CanClose := True
                        Else
                            FormCloseQuery(Sender, CanClose);
                    End;
                mrNo:
                    CanClose := True;
                mrCancel:
                    CanClose := False;
            End;
        End
        Else
        Begin
            Confirmation := Application.MessageBox
              ('Вы действительно хотите выйти?', 'Выход',
              MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
            CanClose := Confirmation = IDYES;
        End;
    End;
End;

procedure TMainTaskForm.QuitMenuClick(Sender: TObject);
Var
    Confirmation: Integer;
Begin
    PerformCloseQuery := False;
    If (Saved = False) Then
    Begin
        Confirmation := Application.MessageBox
          ('Вы не сохранили файл, хотите ли сохранить?', 'Выход',
          MB_YESNOCANCEl + MB_ICONQUESTION + MB_DEFBUTTON2);
        Case Confirmation Of
            mrYes:
                Begin
                    SaveMenuClick(Sender);
                    If Saved = True Then
                        Close
                    Else
                        QuitMenuClick(Sender);
                End;
            mrNo:
                Close;
        End;

    End
    Else
    Begin
        Confirmation := Application.MessageBox('Вы действительно хотите выйти?',
          'Выход', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
        If Confirmation = IDYES Then
            Close;
    End;
    PerformCloseQuery := True;
End;

Procedure MainAlgorithm(Edit1: TEdit; Edit2: TEdit);
Var
    LengthOfStr2, LengthOfStr1, IndOfStr1, IndOfStr2, Place: Integer;
    EndOfStr1: Boolean;
    Str1, Str2: String;
Begin
    Str1 := Edit1.Text;
    Str2 := Edit2.Text;
    LengthOfStr1 := Length(Edit1.Text);
    LengthOfStr2 := Length(Edit2.Text);
    Place := 0;
    IndOfStr1 := 0;
    IndOfStr2 := 0;
    EndOfStr1 := False;
    While (LengthOfStr2 > 0) And (Place = 0) Do
    Begin
        If Str1[LengthOfStr1] = Str2[LengthOfStr2] Then
        Begin
            IndOfStr1 := LengthOfStr1;
            IndOfStr2 := LengthOfStr2;
            While (IndOfStr1 > 0) And (IndOfStr2 > 0) And (Str1[IndOfStr1] = Str2[IndOfStr2]) do
            Begin
                Dec(IndOfStr1);
                Dec(IndOfStr2);
            End;
            If (IndOfStr1 <> 0) Then
                EndOfStr1 := True;
            If (Not EndOfStr1) Then
                Place := IndOfStr2 + 1;
        End;
        Dec(LengthOfStr2);
    End;
    MainTaskForm.OutEdit.Text := IntToStr(Place);

End;

Function IsCorrectRange(Value: Integer; Const MAX, MIN: Integer): Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    if (Value >= MIN) And (Value <= MAX) then
        IsCorrect := True;
    IsCorrectRange := IsCorrect;
End;

Function CheckNumOfLines(Var F: TextFile; Const NUM_OF_LINES: Integer)
  : ERRORS_LIST;
Var
    I: Integer;
    Str: String;
    Error: ERRORS_LIST;
Begin
    I := 0;
    Str := '';
    Error := CORRECT;
    Reset(F);
    while Not EOF(F) do
    Begin
        Readln(F, Str);
        Inc(I);
    End;
    CloseFile(F);
    if I <> NUM_OF_LINES then
        Error := LINE_ERR;
    CheckNumOfLines := Error;

End;
 {
Function CheckFileData(Var F: TextFile): ERRORS_LIST;
Const
    LINES = 1;
Var
    ERRORS: ERRORS_LIST;
    Value: String;
Begin
    Value := 0;
    ERRORS := CheckNumOfLines(F, LINES);
    Reset(F);
    Readln(F, Value);
    CloseFile(F);
    CheckFileData := ERRORS;
End;  }

Procedure TMainTaskForm.GetDataFromFile(Var F: TextFile; Sender: TObject);
Var
    Num: String;
Begin
    Reset(F);
    Readln(F, Num);
    EnterEdit.Text := Num;
    Readln(F, Num);
    EnterStr2Edit.Text := Num;

    CloseFile(F);
End;

Function TMainTaskForm.FileReading(Var F: TextFile): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
Begin
    ERRORS := CORRECT;
    Reset(F);
    if EOF(F) then
        ERRORS := FILE_EMPTY;
    CloseFile(F);
    if (ERRORS = CORRECT) then
       ERRORS := CheckNumOfLines(F, 2);
    if ERRORS = CORRECT then
        GetDataFromFile(F, Self);
    FileReading := ERRORS;
End;

procedure TMainTaskForm.OpenMenuClick(Sender: TObject);
Var
    Error: ERRORS_LIST;
    F: TextFile;
    FileName: String;
Begin
    If OpenFile.Execute Then
    Begin
        FileName := OpenFile.FileName;
        AssignFile(F, FileName);
        Error := IsReadable(F);
        If Error = CORRECT Then
            Error := FileReading(F);
        If Error <> CORRECT Then
            Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка',
              MB_OK Or MB_ICONINFORMATION);
    End;
End;

Procedure TMainTaskForm.ResultButtonClick(Sender: TObject);
Var
    N: Integer;
begin

    MainAlgorithm(EnterEdit, EnterStr2Edit);


end;

procedure TMainTaskForm.OutEditChange(Sender: TObject);
begin

    if OutEdit.Text = '' then
    Begin
        Saved := True;
        SaveMenu.Enabled := False;
        OutEdit.Enabled := False;
    End
    Else
    Begin
        Saved := False;
        SaveMenu.Enabled := True;
        OutEdit.Enabled := True;
    End;

end;

procedure TMainTaskForm.EnterEditChange(Sender: TObject);
begin
    If (EnterEdit.Text = '') Or (EnterStr2Edit.Text = '') Then
        ResultButton.Enabled := False
    Else
        ResultButton.Enabled := True;
    OutEdit.Text := '';
end;


procedure TMainTaskForm.EnterStr2EditChange(Sender: TObject);
begin
    If (EnterEdit.Text = '') Or (EnterStr2Edit.Text = '') Then
        ResultButton.Enabled := False
    Else
        ResultButton.Enabled := True;
    OutEdit.Text := '';
end;

{
procedure TMainTaskForm.EnterEditClick(Sender: TObject);
begin
    If EnterEdit.SelStart <> Length(EnterEdit.Text) Then
        EnterEdit.SelStart := Length(EnterEdit.Text);
end;

procedure TMainTaskForm.EnterEditContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
    Handled := True;
end;  }
{
procedure TMainTaskForm.EnterEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (Key = VK_INSERT) and (Shift = [ssShift]) then
        Key := 0;
    If (Key = VK_LEFT) Or (Key = VK_UP) Then
        Key := 0
    Else If (Key = VK_RIGHT) Or (Key = VK_DOWN) Then
        Key := 0;
end;

Procedure CheckInput(const Edit: TEdit; Var Key: Char);

var
    Value: Integer;
begin
    Value := 0;
    if TryStrToInt(Edit.Text + Key, Value) then
    Begin
        if Not IsCorrectRange(Value, MAX_DAY, MIN_DAY) then
        Begin
            Key := #0;
        End;

    End;
end;   }
{
procedure TMainTaskForm.EnterEditKeyPress(Sender: TObject; var Key: Char);
begin
    if (Key = #22) or ((Key = 'v') and (GetKeyState(VK_CONTROL) < 0)) then
        Key := #0;
    If Not CharInSet(Key, DIGITS) And (Key <> #8) Then
        Key := #0;
    if (EnterEdit.Text = '0') and (Key in DIGITS) then
        Key := #0;
    CheckInput(TEdit(Sender), Key);
end;
 }
end.
