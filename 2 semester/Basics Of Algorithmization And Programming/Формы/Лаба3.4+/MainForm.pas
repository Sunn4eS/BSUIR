unit MainForm;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, Instruction,
    Developer, Vcl.ExtDlgs;

type
    ERRORS_LIST = (CORRECT, RANGE_ERR, NUM_ERR, NOT_READABLE, NOT_WRITEABLE,
      FILE_EMPTY, LINE_ERR);

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
        procedure EnterEditContextPopup(Sender: TObject; MousePos: TPoint;
          var Handled: Boolean);
        procedure EnterEditKeyPress(Sender: TObject; var Key: Char);
        procedure EnterEditKeyDown(Sender: TObject; var Key: Word;
          Shift: TShiftState);
        procedure EnterEditClick(Sender: TObject);
        function FormHelp(Command: Word; Data: NativeInt;
          var CallHelp: Boolean): Boolean;

    private
        { Private declarations }
    public
        { Public declarations }
    end;

Const
    ERRORS: Array [ERRORS_LIST] Of String = ('',
      'Значение не попадает в диапазон!',
      'Проверьте корректность ввода данных!', 'Файл закрыт для чтения!',
      'Файл закрыт для записи!', 'Файл пуст!', 'Неверное число строк в файле');
    DIGITS = ['0' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_DAY = 0;
    MAX_DAY = 1000000;
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

Function IsCorrectRange(Value: Integer; Const MIN, MAX: Real): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
Begin
    ERRORS := CORRECT;

    if (MIN > Value) Or (MAX < Value) then
    Begin
        ERRORS := RANGE_ERR;
    End;
    IsCorrectRange := ERRORS;
End;

procedure TMainTaskForm.FormCreate(Sender: TObject);
begin
    TaskLabel.Caption := 'Данная программа переводит числа из 10 с\с в 16 с\с';
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
                Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка',
                  MB_OK Or MB_ICONINFORMATION);
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

Procedure MainAlgorithm(DecNum: Integer);
Const
    HexCharList: Array [0 .. 15] Of Char = ('0', '1', '2', '3', '4', '5', '6',
      '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
Var
    HexNum: String;
    ModFromDec: Integer;
Begin
    ModFromDec := 0;
    HexNum := '';
    if DecNum = 0 then
        MainTaskForm.OutEdit.Text := '0'
    Else
    Begin
        While (DecNum > 0) Do
        Begin
            ModFromDec := DecNum Mod 16;
            HexNum := HexCharList[ModFromDec] + HexNum;
            DecNum := DecNum Div 16;
        End;
        MainTaskForm.OutEdit.Text := HexNum;
    End;
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

Function CheckFileData(Var F: TextFile): ERRORS_LIST;
Const
    LINES = 1;
Var
    ERRORS: ERRORS_LIST;
    Value: Integer;
Begin
    Value := 0;
    ERRORS := CheckNumOfLines(F, LINES);
    Reset(F);
    Try
        Readln(F, Value);
    Except
        ERRORS := NUM_ERR;
    End;
    if ERRORS = CORRECT then
        ERRORS := IsCorrectRange(Value, MIN_DAY, MAX_DAY);

    CloseFile(F);
    CheckFileData := ERRORS;
End;

Procedure TMainTaskForm.GetDataFromFile(Var F: TextFile; Sender: TObject);
Var
    Num: String;
Begin
    Reset(F);
    Readln(F, Num);
    EnterEdit.Text := Num;

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
        ERRORS := CheckFileData(F);
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
    NumOfDay: Integer;

begin

    if TryStrToInt(EnterEdit.Text, NumOfDay) then
    Begin
        MainAlgorithm(NumOfDay);
    End;

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
    ResultButton.Enabled := (EnterEdit.Text <> '');
    OutEdit.Text := '';
end;

procedure TMainTaskForm.EnterEditClick(Sender: TObject);
begin
    If EnterEdit.SelStart <> Length(EnterEdit.Text) Then
        EnterEdit.SelStart := Length(EnterEdit.Text);
end;

procedure TMainTaskForm.EnterEditContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
    Handled := True;
end;

procedure TMainTaskForm.EnterEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (Key = VK_INSERT) and (Shift = [ssShift]) then
        Key := 0;
    If (Key = VK_LEFT) Or (Key = VK_UP) Then
        Key := 0
    Else If (Key = VK_RIGHT) Or (Key = VK_DOWN) Then
        Key := 0;
    if Key = VK_DELETE then
        Key := 0;
end;

Procedure CheckInput(const Edit: TEdit; Var Key: Char);

var
    Value: Integer;
    ERRORS: ERRORS_LIST;
begin
    Value := 0;
    if TryStrToInt(Edit.Text + Key, Value) then
    Begin
        ERRORS := IsCorrectRange(Value, MIN_DAY, MAX_DAY);
        if ERRORS <> CORRECT then
        Begin
            Key := #0;
        End;

    End;
end;

procedure TMainTaskForm.EnterEditKeyPress(Sender: TObject; var Key: Char);
begin
    if (Key = #22) or ((Key = 'v') and (GetKeyState(VK_CONTROL) < 0)) then
        Key := #0;

    If Not CharInSet(Key, DIGITS) And (Key <> #8) Then
        Key := #0;
    if (EnterEdit.Text = '0') and (Key in DIGITS) then
        Key := #0;
    if (EnterEdit.Text <> '') And (EnterEdit.SelStart = 0) And (Key = #8) then
        Key := #0;

    CheckInput(TEdit(Sender), Key);
end;

end.
