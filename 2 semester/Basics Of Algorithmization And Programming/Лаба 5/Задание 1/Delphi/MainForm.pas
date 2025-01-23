Unit MainForm;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
    Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.Grids;

Type
    TEStringGrid = Class(TStringGrid);
    TArr = Array Of Integer;
    ERRORS_LIST = (CORRECT, NOT_READABLE, NOT_WRITEABLE, FILE_EMPTY, LINE_ERR,
      NAME_ERR, NUMBER_ERR);

    TMainTaskForm = Class(TForm)
        MainFormMenu: TMainMenu;
        FileMenu: TMenuItem;
        InstructionMenu: TMenuItem;
        DeveloperMenu: TMenuItem;
        OpenMenu: TMenuItem;
        SaveMenu: TMenuItem;
        N1: TMenuItem;
        QuitMenu: TMenuItem;
        TaskLabel: TLabel;
        OpenFile: TOpenDialog;
        SaveTextFile: TSaveTextFileDialog;
        StringGrid: TStringGrid;
        AddButton: TButton;
        DeleteButton: TButton;
        ReverseButton: TButton;
        StarightButton: TButton;
        Procedure DeveloperMenuClick(Sender: TObject);
        Procedure InstructionMenuClick(Sender: TObject);
        Procedure GetDataFromFile(Var F: TextFile; Sender: TObject);
        Function FileReading(Var F: TextFile): ERRORS_LIST;
        Procedure QuitMenuClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure SaveMenuClick(Sender: TObject);
        Procedure OpenMenuClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure AddButtonClick(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure DrawGrid(Var ListGrid: TStringGrid);
        Procedure DeleteButtonClick(Sender: TObject);
        Procedure ReverseButtonClick(Sender: TObject);
        Procedure StarightButtonClick(Sender: TObject);

    Private

        { Private declarations }
    Public
        { Public declarations }
    End;

Const
    ERRORS: Array [ERRORS_LIST] Of String = ('', 'Файл закрыт для чтения!',
      'Файл закрыт для записи!', 'Файл пуст!', 'Неверное число строк в файле',
      'Неверное имя пользователя!', 'Введён неверный номер!');
    DIGITS = ['0' .. '9'];
    NO_ZERO_DIGITS = ['1' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_N = 1;
    MAX_N = 100;
    MIN_X = -100;
    MAX_X = 100;
    MAX_SIGNS = 4;
    LINES = 2;
    ALPHABET = ['A' .. 'Z', 'a' .. 'z'];

Var
    MainTaskForm: TMainTaskForm;
    IsEdited: Boolean = False;
    Saved: Boolean = True;

Implementation

Uses
    AddContact;
// DoubleLinkedList;

Procedure AddNewContact(Name, Number: String; Var StringGrid: TStringGrid);
  External 'DoubleLinkedList.dll';
Procedure DeleteContact(Place: Integer); External 'DoubleLinkedList.dll';
Procedure PrintUpDownList(Var ListGrid: TStringGrid);
  External 'DoubleLinkedList.dll';
Procedure PrintDownUpList(Var ListGrid: TStringGrid);
  External 'DoubleLinkedList.dll';
Procedure ClearList(); External 'DoubleLinkedList.dll';

{$R *.dfm}

Var

    PerformCloseQuery: Boolean = True;
    CtrlPressed: Boolean = False;

Procedure TMainTaskForm.DeleteButtonClick(Sender: TObject);
Var
    Confirmation: Integer;
Begin
    If StringGrid.Row > 0 Then
    Begin
        Confirmation := Application.MessageBox
          ('Вы действительно хотите удалить телефон?', 'Удаление',
          MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
        If Confirmation = IDYES Then
        Begin
            DeleteContact(StringGrid.Row);
            StringGrid.Cells[0, StringGrid.RowCount - 1] := '';
            StringGrid.RowCount := StringGrid.RowCount - 1;
            PrintUpDownList(StringGrid);
            DrawGrid(StringGrid);
        End;
    End
    Else
        Application.MessageBox('Не выбрано редактируемое поле!', 'Ошибка',
          MB_OK + MB_ICONERROR);
End;

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

Procedure TMainTaskForm.InstructionMenuClick(Sender: TObject);
Var
    InstructionForm: TInstructionForm;
Begin
    InstructionForm := TInstructionForm.Create(Self);
    InstructionForm.ShowModal;
    InstructionForm.Free;
End;

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

Function CheckNumOfLines(Var F: TextFile): ERRORS_LIST;
Var
    I: Integer;
    Str: String;
    Error: ERRORS_LIST;
Begin
    I := 0;
    Str := '';
    Error := CORRECT;
    Reset(F);
    While Not EOF(F) Do
    Begin
        Readln(F, Str);
        Inc(I);
    End;
    CloseFile(F);
    If (I Mod 2) <> 0 Then
        Error := LINE_ERR;
    CheckNumOfLines := Error;
End;

Function CheckFileData(Var F: TextFile): ERRORS_LIST;
Var
    Error: ERRORS_LIST;
    Value: Integer;
    Num, I: Integer;
    Number, Name: String;
Begin
    Error := CORRECT;
    Reset(F);

    While (Not EOF(F)) And (Error = CORRECT) Do
    Begin
        Readln(F, Name);
        If (Length(Name) > 15) Or (Trim(Name) = '') Then
            Error := NAME_ERR;
        Readln(F, Number);
        If (Length(Number) <> 9) Or (Not(TryStrToInt(Number, Value))) Then
            Error := NUMBER_ERR;
    End;

    CloseFile(F);
    CheckFileData := Error;
End;

Procedure ClearGrid(Grid: TStringGrid);
Var
    I: Integer;
Begin
    For I := 1 To Grid.ColCount Do
    Begin
        Grid.Cells[0, I] := '';
        Grid.Cells[1, I] := '';
    End;
    Grid.RowCount := 1;
End;

Procedure TMainTaskForm.GetDataFromFile(Var F: TextFile; Sender: TObject);
Var
    Number, Name: String;
    I: Integer;
Begin
    I := 1;
    Reset(F);
    ClearList();
    ClearGrid(StringGrid);
    While Not EOF(F) Do
    Begin
        Readln(F, Name);
        Readln(F, Number);
        AddNewContact(Name, Number, StringGrid);
        StringGrid.RowCount := StringGrid.RowCount + 1;

    End;
    CloseFile(F);
    PrintUpDownList(StringGrid);
    DrawGrid(StringGrid);

End;

Function TMainTaskForm.FileReading(Var F: TextFile): ERRORS_LIST;
Var
    ERRORS: ERRORS_LIST;
Begin
    ERRORS := CORRECT;
    Reset(F);
    If EOF(F) Then
        ERRORS := FILE_EMPTY;
    CloseFile(F);
    If (ERRORS = CORRECT) Then
        ERRORS := CheckNumOfLines(F);
    If (ERRORS = CORRECT) Then
        ERRORS := CheckFileData(F);
    If (ERRORS = CORRECT) Then
    Begin
        GetDataFromFile(F, Self);
    End;

    FileReading := ERRORS;
End;

Procedure TMainTaskForm.OpenMenuClick(Sender: TObject);
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
        Begin
            Error := FileReading(F);

        End;
        If Error <> CORRECT Then
            Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка',
              MB_OK Or MB_ICONINFORMATION);
    End;
End;

Procedure FillGrid(Grid: TStringGrid);
Var
    I, J: Integer;
    NumArr: TArr;
Begin
    Grid.Cells[0, 0] := 'Имя';
    Grid.Cells[1, 0] := 'Номер';
    Grid.ColWidths[0] := Grid.DefaultColWidth * 2;
    Grid.ColWidths[1] := Grid.DefaultColWidth * 2;
    Grid.Width := Grid.DefaultColWidth * 4;
    Grid.Height := Grid.DefaultRowHeight + 4;
    Grid.Enabled := True;
    Grid.ColCount := 2;
    Grid.RowCount := 1;

End;

Procedure TMainTaskForm.AddButtonClick(Sender: TObject);
Var
    AddContactForm: TAddContactForm;
Begin
    If StringGrid.RowCount <= MAX_N Then
    Begin
        AddContactForm := TAddContactForm.Create(Self);
        AddContactForm.ShowModal;
        AddContactForm.Free;
        If IsEdited Then
        Begin
            DrawGrid(StringGrid);
            IsEdited := False;
        End;
    End
    Else
        Application.MessageBox('Слишком много номеров!', 'Ошибка',
          MB_OK + MB_ICONERROR);

End;

Procedure TMainTaskForm.SaveMenuClick(Sender: TObject);
Var
    Error: ERRORS_LIST;
    F: TextFile;
    FileName: String;
    I: Integer;
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
                For I := 0 To StringGrid.RowCount - 1 Do
                Begin
                    Write(F, StringGrid.Cells[0, I], ' ');
                    Writeln(F, Stringgrid.Cells[1, I]);
                End;
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
            For I := 0 To StringGrid.RowCount - 1 Do
            Begin
                Write(F, StringGrid.Cells[0, I], ' ');
                Writeln(F, Stringgrid.Cells[1, I]);
            End;
            CloseFile(F);
            Saved := True;
        End;

    End;
End;

Procedure TMainTaskForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
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
                MrYes:
                    Begin
                        SaveMenuClick(Sender);
                        If Saved = True Then
                            CanClose := True
                        Else
                            FormCloseQuery(Sender, CanClose);
                    End;
                MrNo:
                    CanClose := True;
                MrCancel:
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

Procedure TMainTaskForm.DrawGrid(Var ListGrid: TStringGrid);
Begin
    ListGrid.ColCount := 2;
    ListGrid.ColWidths[0] := ListGrid.DefaultColWidth * 2;
    ListGrid.ColWidths[1] := ListGrid.DefaultColWidth * 2;
    ListGrid.Cells[1, 0] := 'Номер';
    ListGrid.Cells[0, 0] := 'Имя';
    If ListGrid.RowCount > 10 Then
    Begin
        ListGrid.ScrollBars := TScrollStyle.SsVertical;
        ListGrid.Height := 400
    End
    Else
    Begin
        ListGrid.ScrollBars := TScrollStyle.SsNone;
        ListGrid.Height := (ListGrid.DefaultRowHeight + ListGrid.GridLineWidth)
          * ListGrid.RowCount + 5;

    End;

    SaveMenu.Enabled := StringGrid.RowCount > 1;
    Saved := ListGrid.RowCount = 1;

    ListGrid.Width := ListGrid.DefaultColWidth * 4;

End;

Procedure TMainTaskForm.FormCreate(Sender: TObject);
Begin
    FillGrid(StringGrid);
End;

Procedure TMainTaskForm.QuitMenuClick(Sender: TObject);
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
            MrYes:
                Begin
                    SaveMenuClick(Sender);
                    If Saved = True Then
                        Close
                    Else
                        QuitMenuClick(Sender);
                End;
            MrNo:
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

Procedure TMainTaskForm.ReverseButtonClick(Sender: TObject);
Begin
    PrintDownUpList(StringGrid);
    DrawGrid(StringGrid);
End;

Procedure TMainTaskForm.StarightButtonClick(Sender: TObject);
Begin
    PrintUpDownList(StringGrid);
    DrawGrid(StringGrid);
End;

End.
