Unit ViewGroupListUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
    GroupListActionUnit, GroupsLinkedListUnit, Vcl.Menus, Vcl.ExtDlgs;

Type
    TGroupListForm = Class(TForm)
        AddGroup: TButton;
        DeleteGroup: TButton;
        EditGroup: TButton;
        GroupGrid: TStringGrid;
        ViewStudentsInGroupButton: TButton;
        GroupMainMenu: TMainMenu;
        FileDialog: TMenuItem;
        OpenFile: TMenuItem;
        SaveFile: TMenuItem;
        OpenTextFileDialog: TOpenTextFileDialog;
        SaveTextFileDialog: TSaveTextFileDialog;
        Procedure CreateParams(Var Params: TCreateParams); Override;
        Procedure AddGroupClick(Sender: TObject);
        Procedure DeleteGroupClick(Sender: TObject);
        Procedure EditGroupClick(Sender: TObject);
        Procedure FormShow(Sender: TObject);

        Procedure ViewStudentsInGroupButtonClick(Sender: TObject);
        Procedure GroupGridSelectCell(Sender: TObject; ACol, ARow: Integer;
          Var CanSelect: Boolean);
        Procedure OpenFileClick(Sender: TObject);
        Procedure SaveFileClick(Sender: TObject);

    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    GroupListForm: TGroupListForm;
    OldGroupData: TGroupData;

Implementation

Uses
    MainMenuUnit, ViewStudentsInGroupUnit, FileUnit, StudentLinkedListUnit;

{$R *.dfm}

Procedure TGroupListForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Procedure CreateForm(FormClass: TFormClass);
Var
    Form: TForm;
Begin
    GroupListForm.Visible := False;
    Form := FormClass.Create(MainMenuForm);
    Form.Icon := MainMenuForm.Icon;
    Form.ShowModal;
    GroupListForm.Visible := True;
End;

Procedure CreateActionForm(Const TitleLabelCaption, ActionButtonCaption
  : String);
Begin
    GroupListActionForm := TGroupListActionForm.Create(GroupListActionForm);
    GroupListActionForm.Icon := GroupListForm.Icon;
    GroupListActionForm.TitleLabel.Width := 200;
    GroupListActionForm.TitleLabel.Caption := TitleLabelCaption;
    GroupListActionForm.ActionButton.Caption := ActionButtonCaption;
    GroupListActionForm.ShowModal;
End;

Procedure TGroupListForm.AddGroupClick(Sender: TObject);
Begin
    // Установление типа формы
    StateOfGForm := AddG;
    // Создание формы для добавления группы
    CreateActionForm('Добавление группы', 'Добавить');
    // Нажата ли кнопка добавить
    If IsEdited Then
    Begin
        // Увеличение числа строк на 1
        GroupGrid.RowCount := GroupGrid.RowCount + 1;
        // Заполнение таблицы
        DrawGroupGrid(GroupGrid, GroupList);
        IsEdited := False;
        // Изменение параметров сохранения
        IsSaved := False;
        SaveFile.Enabled := True;
    End;
End;

Procedure TGroupListForm.ViewStudentsInGroupButtonClick(Sender: TObject);
Begin
    CreateForm(TViewStudentsInGroupForm);
End;

Function GetGroupDataFromGrid(GroupGrid: TStringGrid): TGroupData;
Var
    OldGroupData: TGroupData;
Begin
    With GroupGrid, OldGroupData Do
    Begin
        GroupNumber := StrToInt(Cells[0, Row]);
        Year := StrToInt(Cells[1, Row]);
        Code := Cells[2, Row];
        CountOfStudents := StrToInt(Cells[3, Row]);
    End;

    GetGroupDataFromGrid := OldGroupData;
End;

Procedure TGroupListForm.DeleteGroupClick(Sender: TObject);
Var
    Confirmation, GroupCount: Integer;
Begin
    // Выбран редактируемый ряд
    If GroupGrid.Row > 0 Then
    Begin
        // Предупреждение о удалении =
        Confirmation := Application.MessageBox
          ('Вы действительно хотите удалить группу?', 'Удаление кандидата',
          MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
        If Confirmation = IDYES Then
        Begin
            // Удаление группы
            DeleteGroupF(GroupList, GetGroupDataFromGrid(GroupGrid),
              StudentsList);
            // Уменьшение количества строк на 1
            GroupGrid.RowCount := GroupGrid.RowCount - 1;
            // Заполнение таблицы
            DrawGroupGrid(GroupGrid, GroupList);
            // Подсчёт количества групп
            GroupCount := CountGroups(GroupList);
            // Изменение параметров сохранения
            IsSaved := GroupCount = 0;
            SaveFile.Enabled := GroupCount > 0;

        End;
    End
    Else
        // Сообщение об ошибке
        Application.MessageBox('Не выбрано редактируемое поле!',
          'Предупреждение', MB_OK + MB_ICONWARNING);

End;

Procedure TGroupListForm.EditGroupClick(Sender: TObject);
Begin
    If GroupGrid.Row > 0 Then
    Begin
        StateOfGForm := EditG;
        OldGroupData := GetGroupDataFromGrid(GroupGrid);
        CreateActionForm('Изменение группы', 'Изменить');
        If IsEdited Then
        Begin
            DrawGroupGrid(GroupGrid, GroupList);
            IsEdited := False;
            IsSaved := False;
            SaveFile.Enabled := True;

        End;
    End
    Else
        Application.MessageBox('Не выбрано редактируемое поле!',
          'Предупреждение', MB_OK + MB_ICONWARNING);
End;

Procedure TGroupListForm.FormShow(Sender: TObject);
Var
    GroupCount: Integer;
Begin
    GroupCount := CountGroups(GroupList);
    GroupGrid.RowCount := CountGroups(GroupList) + 1;
    SaveFile.Enabled := GroupCount > 0;
    DrawGroupGrid(GroupGrid, GroupList);
End;

Procedure TGroupListForm.GroupGridSelectCell(Sender: TObject;
  ACol, ARow: Integer; Var CanSelect: Boolean);
Begin
    ViewStudentsInGroupButton.Enabled := Not(ARow = 0);
    If ARow > 0 Then
        SelectedGroup := StrToInt(GroupGrid.Cells[0, Arow]);
End;

Procedure TGroupListForm.OpenFileClick(Sender: TObject);
Var
    InputGroupFile: TGroupDataFile;
    InputStudentFile: TStudentDataFile;
    TempGroupList: PGroup;
    TempStudent: PStudent;
    IsCorrect: Boolean;
Begin
    // Изменение базового расширения файла
    OpenTextFileDialog.DefaultExt := 'grplst';
    // Диалоговое окно для открытия файла
    If OpenTextFileDialog.Execute Then
    Begin
        AssignFile(InputGroupFile, OpenTextFileDialog.FileName);
        // Инициализация списка групп
        TempGroupList := Nil;
        // Чтение данных о группах из файла
        IsCorrect := ReadFileData(InputGroupFile, InputStudentFile,
          TempGroupList, TempStudent, True);
        // Если успешное чтение
        If IsCorrect Then
        Begin
            // Очищение старых данных о группах
            ClearGroups(GroupList);
        End
        Else
        Begin
            // Очищение новых данных
            ClearGroups(TempGroupList);
            // Сообщение об ошибке
            Application.MessageBox('Содержимое файла повреждено!', 'Ошибка',
              MB_OK + MB_ICONERROR);
        End;
    End;
    // Если успешное чтение данных о группах
    If IsCorrect Then
    Begin
        // Изменение базового расширения файла
        OpenTextFileDialog.DefaultExt := 'stdlst';
        // Диалоговое окно открытия файла
        If OpenTextFileDialog.Execute Then
        Begin
            // Инициализаця списка студентов
            TempStudent := Nil;
            AssignFile(InputStudentFile, OpenTextFileDialog.FileName);
            // Чтение данных о студентах из файла
            IsCorrect := ReadFileData(InputGroupFile, InputStudentFile,
              TempGroupList, TempStudent, False);
            // Если успешное чтение
            If IsCorrect Then
            Begin
                // Очищение старых данных студентов
                ClearStudents(StudentsList);
                // Запись новых данных
                RecordFileData(GroupList, TempGroupList, StudentsList,
                  TempStudent, GroupGrid);
                // Изменение параметров сохранения
                IsSaved := True;
                SaveFile.Enabled := True;
            End
            Else
            Begin
                // Очищение новых данных студентов
                ClearStudents(TempStudent);
                // Сообщение об ошибке
                Application.MessageBox('Содержимое файла повреждено!', 'Ошибка',
                  MB_OK + MB_ICONERROR);
            End;
        End;
    End;
End;

Procedure TGroupListForm.SaveFileClick(Sender: TObject);
Var
    OutputGroupFile: TGroupDataFile;
    OutputStudentFile: TStudentDataFile;
Begin
    // Изменение базового расширения файла при открытии диалогового окна сохранения групп
    SaveTextFileDialog.DefaultExt := 'grplst';
    // Диалоговое окно сохранения файла групп
    If SaveTextFileDialog.Execute Then
    Begin
        AssignFile(OutputGroupFile, SaveTextFileDialog.FileName);
        // Вызов функции записи в файл групп
        WriteFileData(OutputGroupFile, OutputStudentFile, GroupList,
          StudentsList, True);
    End;
    // Изменение базового расширения файла при открытии диалогового окна сохранения студентов
    SaveTextFileDialog.DefaultExt := 'stdlst';
    // Диалоговое окно сохранения файла студентов
    If SaveTextFileDialog.Execute Then
    Begin
        AssignFile(OutputStudentFile, SaveTextFileDialog.FileName);
        // Вызов функции записи в файл студентов
        WriteFileData(OutputGroupFile, OutputStudentFile, GroupList,
          StudentsList, False);
        // Результат сохранён
        IsSaved := True;
    End;
End;

End.
