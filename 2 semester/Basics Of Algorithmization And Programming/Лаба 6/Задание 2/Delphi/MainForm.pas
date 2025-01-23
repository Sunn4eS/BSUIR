Unit MainForm;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
    Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.Grids, Vcl.ExtCtrls;

Type
    ERRORS_LIST = (CORRECT, NOT_READABLE, NOT_WRITEABLE, FILE_EMPTY, LINE_ERR,
      INPUT_ERR, NUMBER_ERR, MATRIX_ERR, PATH_ERR);

    TMainTaskForm = Class(TForm)
        MainFormMenu: TMainMenu;
        FileMenu: TMenuItem;
        InstructionMenu: TMenuItem;
        DeveloperMenu: TMenuItem;
        OpenMenu: TMenuItem;
        SaveMenu: TMenuItem;
        N1: TMenuItem;
        QuitMenu: TMenuItem;
        OpenFile: TOpenDialog;
        SaveTextFile: TSaveTextFileDialog;
        AddButton: TButton;
        AddLineButton: TButton;
        FindRouteButton: TButton;
        ClearButton: TButton;
        ScrollBox: TScrollBox;
        TownPaintBox: TPaintBox;
        Label1: TLabel;
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
        Procedure AddLineButtonClick(Sender: TObject);
        Procedure ClearButtonClick(Sender: TObject);
        Procedure FindRouteButtonClick(Sender: TObject);

    Private

        { Private declarations }
    Public
        { Public declarations }
    End;

Const
    ERRORS: Array [ERRORS_LIST] Of String = ('', 'Файл закрыт для чтения!',
      'Файл закрыт для записи!', 'Файл пуст!', 'Неверное число строк в файле',
      'Неверное формат!', 'Неверное значение!',
      'Неверное значение в матрице смежности!', 'В пути указан неверный путь!');

Var
    MainTaskForm: TMainTaskForm;
    IsEdited: Boolean = False;
    Saved: Boolean = True;

Implementation

Uses
    AddLine,
    GraphLinkedList,
    FindPath;

{$R *.dfm}

Var

    PerformCloseQuery: Boolean = True;
    CtrlPressed: Boolean = False;

Procedure TMainTaskForm.AddLineButtonClick(Sender: TObject);
Var
    AddLineForm: TAddLineForm;
Begin
    If CountOfTowns > 1 Then
    Begin
        AddLineForm := TAddLineForm.Create(Self);
        AddLineForm.ShowModal;
        AddLineForm.Free;
        DrawLines(TownPaintBox);
    End
    Else
        Application.MessageBox('Количество городов меньше двух!', 'Ошибка',
          MB_OK + MB_ICONERROR);
    AddButton.Enabled := CanAddTown;
End;

Procedure TMainTaskForm.ClearButtonClick(Sender: TObject);
Begin
    ClearGraph();
    With TownPaintBox.Canvas Do
        FillRect(ClipRect);
    AddButton.Enabled := True;
    Saved := True;
    IsEdited := False;
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
    NumOfString: Integer;
    Error: ERRORS_LIST;
Begin
    I := 1;
    Str := '';
    Error := CORRECT;
    Reset(F);
    Readln(F, Str);
    If TryStrToInt(Str, NumOfString) Then
    Begin

        While Not EOF(F) Do
        Begin
            Readln(F, Str);
            Inc(I);
        End;
        CloseFile(F);
        If (I <> NumOfString + 2) Then
            Error := LINE_ERR;
    End
    Else
        Error := NUMBER_ERR;
    CheckNumOfLines := Error;
End;

Function CheckFileData(Var F: TextFile): ERRORS_LIST;
Var
    Error: ERRORS_LIST;
    Num, I, J: Integer;
    TownsCount: Integer;
    StartT, EndT: Integer;
    GraphMat: TGraphMatrix;
Begin
    TownsCount := 0;
    Error := CORRECT;
    Reset(F);
    Try
        Readln(F, TownsCount);
    Except
        Error := NUMBER_ERR;
    End;

    If Error = Correct Then
    Begin
        I := 0;
        J := 0;
        SetLength(GraphMat, TownsCount, TownsCount);

        While (I < TownsCount) And (Error = CORRECT) Do
        Begin
            While (J < TownsCount) And (Error = Correct) Do
            Begin
                Try
                    Read(F, Num);
                    If (Num = 1) Then
                        GraphMat[I, J] := True
                    Else If Num = 0 Then
                        GraphMat[I, J] := False
                    Else
                        Error := MATRIX_ERR;
                Except
                    Error := NUMBER_ERR;
                End;
                Inc(J);
            End;
            Readln(F);
            Inc(I);
            J := 0;
        End;
        If Error = Correct Then
        Begin
            For I := 0 To High(GraphMat) Do
                For J := 0 To High(GraphMat) Do
                    If GraphMat[I, J] <> GraphMat[J, I] Then
                        Error := MATRIX_ERR;
        End;

        If Error = CORRECT Then
        Begin
            Try
                Read(F, StartT, EndT);
                If (StartT > TownsCount) Or (StartT < 0) Or (EndT > TownsCount)
                  Or (EndT < 0) Or (StartT = EndT) Then
                    Error := PATH_ERR;
            Except
                Error := NUMBER_ERR;
            End;
        End;
    End;

    CloseFile(F);
    CheckFileData := Error;
End;

Procedure TMainTaskForm.GetDataFromFile(Var F: TextFile; Sender: TObject);
Var
    I, J, Num, Count: Integer;
    StartT, EndT: Integer;
Begin
    I := 0;
    J := 0;
    Reset(F);

    Readln(F, Count);
    For Num := 1 To Count Do
        AddTown();
    While (I < CountOfTowns) Do
    Begin
        While (J < CountOfTowns) Do
        Begin

            Read(F, Num);
            If (Num = 1) Then
                GraphMatrix[I, J] := True
            Else If Num = 0 Then
                GraphMatrix[I, J] := False;
            Inc(J);
        End;
        Readln(F);
        Inc(I);
        J := 0;
    End;
    Read(F, StartT, EndT);
    CloseFile(F);

    If FindPathDFS(StartT, EndT) = Nil Then
        ShowMessage('Дороги между данными городами нет!');
    Saved := False;
    IsEdited := True;
    SaveMenu.Enabled := Not Saved;
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
        ClearButtonClick(Self);
        GetDataFromFile(F, Self);
        DrawPath(TownPaintBox);
    End;

    FileReading := ERRORS;
End;

Procedure TMainTaskForm.FindRouteButtonClick(Sender: TObject);
Var
    FindPathForm: TFindPathForm;
Begin

    If CountOfTowns > 1 Then
    Begin
        FindPathForm := TFindPathform.Create(Self);
        FindPathForm.ShowModal;
        FindPathForm.Free;
        DrawPath(TownPaintBox);
    End
    Else
        Application.MessageBox('Количество городов меньше двух!', 'Ошибка',
          MB_OK + MB_ICONERROR);
    AddButton.Enabled := CanAddTown;
    SaveMenu.Enabled := Not Saved;
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
            Error := FileReading(F);
        If Error <> CORRECT Then
            Application.MessageBox(PWideChar(ERRORS[Error]), 'Ошибка',
              MB_OK Or MB_ICONINFORMATION);
    End;
End;

Procedure TMainTaskForm.AddButtonClick(Sender: TObject);
Begin
    If CountOfTowns < 15 Then
    Begin
        With TownPaintBox.Canvas Do
            FillRect(ClipRect);
        AddTown();
        DrawTowns(TownPaintBox);
    End
    Else
        AddButton.Enabled := False;

End;

Procedure TMainTaskForm.SaveMenuClick(Sender: TObject);
Var
    Error: ERRORS_LIST;
    F: TextFile;
    FileName, PathStr: String;
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
                If Path <> Nil Then
                Begin
                    For I := 0 To High(Path) Do
                        PathStr := Concat(PAthStr + IntToStr(Path[I]) + ', ');
                    Write(F, 'Ваш путь: ', PathStr);
                End
                Else
                    Write(F, 'Путь не найден!');
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
            If Path <> Nil Then
            Begin
                For I := 0 To High(Path) Do
                    PathStr := Concat(PAthStr + IntToStr(Path[I]) + ', ');
                Write(F, 'Ваш путь: ', PathStr);
            End
            Else
                Write(F, 'Путь не найден!');
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

End.
