unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
  Vcl.StdCtrls, Vcl.ExtDlgs;

type
    ERRORS_LIST = (CORRECT, RANGE_ERR, NUM_ERR,
      NOT_READABLE, NOT_WRITEABLE, FILE_EMPTY, LINE_ERR);
  TMainTaskForm = class(TForm)
    MainFormMenu: TMainMenu;
    FileMenu: TMenuItem;
    InstructionMenu: TMenuItem;
    DeveloperMenu: TMenuItem;
    OpenMenu: TMenuItem;
    SaveMenu: TMenuItem;
    N1: TMenuItem;
    QuitMenu: TMenuItem;
    TaskLabel: TLabel;
    ResultButton: TButton;
    OpenFile: TOpenDialog;
    EnterXEdit: TEdit;
    EnterEPSEdit: TEdit;
    OutEdit: TEdit;
    EnterXLabel: TLabel;
    EnterEPSLabel: TLabel;
    OutLabel: TLabel;
    SaveTextFile: TSaveTextFileDialog;
    procedure DeveloperMenuClick(Sender: TObject);
    procedure InstructionMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EnterXEditContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure EnterEPSEditContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    Procedure GetDataFromFile(Var F: TextFile; Sender: TObject; Edit: TEdit);
      Function FileReading(Var F: TextFile): ERRORS_LIST;
    procedure ResultButtonClick(Sender: TObject);
    Procedure LnSeries(X, EPS: Real);
    procedure OutEditChange(Sender: TObject);
    procedure EnterXEditChange(Sender: TObject);
    procedure EnterEPSEditChange(Sender: TObject);
    procedure QuitMenuClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EnterXEditKeyPress(Sender: TObject; var Key: Char);
    procedure EnterXEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EnterEPSEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EnterEPSEditKeyPress(Sender: TObject; var Key: Char);
    procedure EnterXEditExit(Sender: TObject);
    procedure EnterEPSEditExit(Sender: TObject);
    procedure EnterXEditClick(Sender: TObject);
    procedure EnterEPSEditClick(Sender: TObject);
    procedure SaveMenuClick(Sender: TObject);
    procedure OpenMenuClick(Sender: TObject);
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
      'Проверьте корректность ввода данных!',
      'Файл закрыт для чтения!',
      'Файл закрыт для записи!', 'Файл пуст!',
      'Неверное число строк в файле');
    DIGITS = ['0' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_X = -0.9999999999999;
    MAX_X = 1;
    MIN_EPS = 0;
    MAX_EPS = 1;
    MAX_SIGNS = 4;

var
  MainTaskForm: TMainTaskForm;

implementation

{$R *.dfm}
Var
    Saved:Boolean = True;
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
    ResultButton.Enabled := False;
    TaskLabel.Caption := 'Данная программа считает значение функции LN(1+X) для введённого' + #13#10 + 'значения X, а также подсчитывает количество чисел из ряда Маклорена' + #13#10 + 'больших EPS:';
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

procedure TMainTaskForm.EnterEPSEditContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
    Handled := True;
end;

procedure TMainTaskForm.EnterXEditContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
    Handled := True;
end;

Procedure GiveZeroOrNone (Edit: TEdit);
Var
    Num: Double;
Begin
    if TryStrToFloat(Edit.Text, Num) And (Num = 0) then
        Edit.Text := '0';
    if (Length(Edit.Text) = 1) And (Edit.Text[1] = '-') then
        Edit.Text := '';

    If (Length(Edit.Text) > 0) And (Edit.Text[1] = ',') Then
        Edit.Text := '';
        //для эпсилона нужно заменить на пустоту





End;

procedure TMainTaskForm.EnterXEditExit(Sender: TObject);
begin
    GiveZeroOrNone(EnterXEdit);
end;

procedure TMainTaskForm.EnterEPSEditExit(Sender: TObject);

Var
    Num: Double;
begin
    if TryStrToFloat(EnterEPSEdit.Text, Num) And (Num = 0) then
        EnterEPSEdit.Text := '';
    If (Length(EnterEPSEdit.Text) > 0) And (EnterEPSEdit.Text[1] = ',') Then
        EnterEPSEdit.Text := '';
end;

Procedure TMainTaskForm.LnSeries(X, EPS: Real);
var
  Sum, Current, XUp: Double;
  N: Integer;
  OutRes:String;
Begin
    Current := X;
    Sum := X;
    N := 1;
    XUp := X;
    Repeat
        XUp := XUp * (-X);
        Current := XUp / (N + 1);
        Sum := Sum + Current;
        Inc(N);
    Until Abs(Current) < EPS;
    OutRes := Concat('Сумма ряда: ',FloatToStrF(Sum, ffFixed, 15, 4), '; Кол-во элементов: ', IntToStr(N));
    OutEdit.Text := OutRes;
end;

Function IsCorrectRange(Value: Real; Const MAX, MIN: Real): Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := False;

    if (Value >= MIN) And (Value <= MAX) then
        IsCorrect := True;
    IsCorrectRange := IsCorrect;
End;

Function CheckNumOfLines(Var F: TextFile; Const NUM_OF_LINES: Integer): ERRORS_LIST;
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
    LINES = 2;
Var
    ERRORS: ERRORS_LIST;
    Value: String;
    Num: Double;
Begin
    
    Errors := CheckNumOfLines(F, LINES);
    Reset(F);

    Readln(F, Value);
    if TryStrToFloat(Value, Num) then
    Begin
        If (Length(Value) - Pos(',', Value) > MAX_SIGNS) And (Pos(',', Value) <> 0) Then
            ERRORS := RANGE_ERR
        Else
            IF Not IsCorrectRange(Num, MAX_X, MIN_X) Then
                ERRORS := RANGE_ERR;
            
       
        
    End
    Else
        ERRORS := NUM_ERR;

    Readln(F, Value);
    if TryStrToFloat(Value, Num) then
    Begin
        If (Length(Value) - Pos(',', Value) > MAX_SIGNS) And (Pos(',', Value) <> 0) Then
            ERRORS := RANGE_ERR
        Else
            IF Not IsCorrectRange(Num, MAX_EPS, MIN_EPS) Then
                ERRORS := RANGE_ERR;
            
    End
    Else
        ERRORS := NUM_ERR;    
   

    CloseFile(F);
    CheckFileData := ERRORS;
End;

Procedure TMainTaskForm.GetDataFromFile(Var F: TextFile; Sender: TObject; Edit: TEdit);
Var
    NumStr: String;
Begin
    Readln(F, NumStr);
    Edit.Text := NumStr;
End;

//допилить несколько чисел
Function TMainTaskForm.FileReading(Var F: TextFile): ERRORS_LIST;
Const
    LINES = 2;
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
    if (ERRORS = CORRECT) then
        Errors := CheckNumOfLines(F, LINES);
    FileReading := ERRORS;
End;

procedure TMainTaskForm.ResultButtonClick(Sender: TObject);
Var
    XEdit, EPSEdit: String;
    X, EPS: Real;
begin
    XEdit := EnterXEdit.Text;
    EPSEdit := EnterEPSEdit.Text;
    X := StrToFloat(XEdit);
    EPS := StrToFloat(EPSEdit);
    LnSeries(X,EPS);
end;

procedure TMainTaskForm.OpenMenuClick(Sender: TObject);
Var
    Error: ERRORS_LIST;
    F: TextFile;
    Num, FileName: String;

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
        If Error = CORRECT Then
        begin
            Reset(F);
            Readln(F, Num);
            EnterXEdit.Text := Num;
            Readln(F, Num);
            EnterEPSEdit.Text := Num;

            CloseFile(F);
        End;
    End;
End;

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

End;

procedure TMainTaskForm.EnterXEditChange(Sender: TObject);
begin
    ResultButton.Enabled := ((EnterXEdit.Text <> '') And (EnterEPSEdit.Text <> ''));
    OutEdit.Text := '';


end;

procedure TMainTaskForm.EnterEPSEditChange(Sender: TObject);
begin
    ResultButton.Enabled := ((EnterXEdit.Text <> '') And (EnterEPSEdit.Text <> ''));
    OutEdit.Text := '';
end;

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
                Append(F);
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

Procedure CheckInput(const Edit: TEdit; Var Key: Char; Const MAX, MIN: Real);

var
    Value: Double;
begin
    Value := 0;
    if TryStrToFloat(Edit.Text + Key, Value) then
    Begin
        if Not IsCorrectRange(Value, MAX, MIN) then
        Begin
            Key := #0;
        End;
    End;

end;

Procedure CheckComboButtons (Var Key: Char; Edit: TEdit);
Begin
    if (Key = #22) or ((Key = 'v') and (GetKeyState(VK_CONTROL) < 0)) then
        Key := #0;
    If Not CharInSet(Key, DIGITS) And (Key <> #8)  And (Key <> ',') Then
        Key := #0;

    if (Edit.Text = '0') And (Key <> ',') And (Key <> #8) then
        Key := #0;
    If (Length(Edit.Text) - Pos(',', Edit.Text) > 4) And (Pos(',', Edit.Text) <> 0) And (Key <> #8) Then
        Key := #0;
    if (Pos(',', Edit.Text) <> 0) And (Key = ',') then
        Key := #0;
End;
Procedure CheckComboButtonsX (Var Key: Char; Edit: TEdit);
Begin
    if (Key = #22) or ((Key = 'v') and (GetKeyState(VK_CONTROL) < 0)) then
        Key := #0;
    If Not CharInSet(Key, DIGITS) And (Key <> #8) And (Key <> '-') And (Key <> ',') Then
        Key := #0;

    if (Edit.Text = '0') And (Key <> ',') And (Key <> #8) then
        Key := #0;
    If (Length(Edit.Text) - Pos(',', Edit.Text) > 4) And (Pos(',', Edit.Text) <> 0) And (Key <> #8) Then
        Key := #0;
    if (Pos(',', Edit.Text) <> 0) And (Key = ',') then
        Key := #0;
End;

Procedure CheckShftAndArrows (var Key: Word;
  Shift: TShiftState);
Begin
    if (Key = VK_INSERT) and (Shift = [ssShift]) then
        Key := 0;
    If (Key = VK_LEFT) Or (Key = VK_UP) Then
        Key := 0
    Else If (Key = VK_RIGHT) Or (Key = VK_DOWN) Then
        Key := 0;
End;

procedure TMainTaskForm.EnterXEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    CheckShftAndArrows (Key, Shift);
end;

procedure TMainTaskForm.EnterXEditKeyPress(Sender: TObject; var Key: Char);
begin

    CheckComboButtonsX(Key, EnterXEdit);
    
    if (EnterXEdit.Text = '-0') And (Key <> ',') And (Key <> #8) then
        Key := #0;
    if (Pos('-', EnterXEdit.Text) = 1) And (Key = '-') then
        Key := #0;
    if (EnterXEdit.Text = '-') And (Key <> '0') And (Key <> #8) then
        Key := #0;
    CheckInput(TEdit(Sender), Key, MAX_X, MIN_X);
end;

procedure TMainTaskForm.EnterEPSEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    CheckShftAndArrows (Key, Shift);
end;

procedure TMainTaskForm.EnterEPSEditKeyPress(Sender: TObject; var Key: Char);
begin
    CheckComboButtons(Key, EnterEPSEdit);
    CheckInput(TEdit(Sender), Key, MAX_EPS, MIN_EPS);
end;

Procedure BlockClick (Edit: TEdit);
Begin
    If Edit.SelStart <> Length(Edit.Text) Then
        Edit.SelStart := Length(Edit.Text);
End;

procedure TMainTaskForm.EnterXEditClick(Sender: TObject);
begin
    BlockClick(EnterXEdit);
end;

procedure TMainTaskForm.EnterEPSEditClick(Sender: TObject);
begin
    BlockClick(EnterEPSEdit);
end;

end.
