Unit MainMenuUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus,
    FindStudentUnit, ViewGroupListUnit, StudentLinkedListUnit,
    GroupsLinkedListUnit;

Type
    TStateGroup = (AddG, DeleteG, EditG);
    TStateStudent = (AddS, DeleteS, EditS);
    TStateLists = (Debt, Expel);

    TMainMenuForm = Class(TForm)
        GroupListButton: TButton;
        FindStudentButton: TButton;
        DebtStudentButton: TButton;
        ExpellStudentButton: TButton;
        DevAndInstMainMenu: TMainMenu;
        InstructionMenu: TMenuItem;
        DeveloperMenu: TMenuItem;
        Procedure DeveloperMenuClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure InstructionMenuClick(Sender: TObject);
        Procedure GroupListButtonClick(Sender: TObject);
        Procedure CreateForm(FormClass: TFormClass);
        Procedure FindStudentButtonClick(Sender: TObject);
        Procedure FormShow(Sender: TObject);
        Procedure DebtStudentButtonClick(Sender: TObject);
        Procedure ExpellStudentButtonClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Const
    MAX_AMOUNT_GROUPS = 50;

Var
    MainMenuForm: TMainMenuForm;
    StateOfGForm: TStateGroup;
    StateOfSForm: TStateStudent;
    GroupList: PGroup;
    StudentsList: PStudent;
    IsEdited: Boolean = False;
    SelectedGroup: Integer = 0;
    StateListForm: TStateLists;
    IsSaved: Boolean = True;

Implementation

Uses
    ListsActionUnit;

{$R *.dfm}

Procedure TMainMenuForm.CreateForm(FormClass: TFormClass);
Var
    Form: TForm;
Begin
    MainMenuForm.Visible := False;
    Form := FormClass.Create(MainMenuForm);
    Form.Icon := MainMenuForm.Icon;
    Form.ShowModal;
    MainMenuForm.Visible := True;
End;

Procedure CreateActionForm(Const TitleLabelCaption: String);
Begin
    ListsActionForm := TListsActionForm.Create(ListsActionForm);
    ListsActionForm.Icon := GroupListForm.Icon;
    ListsActionForm.TitleLabel.Width := 600;
    ListsActionForm.TitleLabel.Caption := TitleLabelCaption;

    ListsActionForm.ShowModal;
End;

Procedure CreateModalForm(CaptionText, LabelText: String;
  ModalWidth, ModalHeight: Integer);
Var
    ModalForm: TForm;
    ModalLabel: TLabel;
Begin
    ModalForm := TForm.Create(Nil);
    Try
        ModalForm.BorderIcons := [BiSystemMenu];
        ModalForm.BorderStyle := BsSingle;
        ModalForm.Caption := CaptionText;
        ModalForm.Height := ModalHeight;
        ModalForm.Icon := MainMenuForm.Icon;
        ModalForm.Position := PoScreenCenter;
        ModalForm.Width := ModalWidth;
        ModalForm.OnHelp := MainMenuForm.FormHelp;

        ModalLabel := TLabel.Create(ModalForm);
        ModalLabel.Caption := LabelText;
        ModalLabel.Font.Size := 12;
        ModalLabel.Left := (ModalForm.ClientWidth - ModalLabel.Width) Div 2;
        ModalLabel.Parent := ModalForm;
        ModalLabel.Top := (ModalForm.ClientHeight - ModalLabel.Height) Div 2;

        ModalForm.ShowModal;
    Finally
        ModalForm.Free;
    End;
End;

Procedure TMainMenuForm.DebtStudentButtonClick(Sender: TObject);
Var
    NewStudentList: PStudent;
Begin
    StateListForm := Debt;

    CreateActionForm('Список задолжников')
End;

Procedure TMainMenuForm.DeveloperMenuClick(Sender: TObject);
Begin
    CreateModalForm('О разработчике', 'Группа: 351004'#13#10 +
      'Разработчик: Бражалович Александр Иванович', 600, 150);
End;

Procedure TMainMenuForm.ExpellStudentButtonClick(Sender: TObject);
Var
    NewStudentList: PStudent;
Begin
    StateListForm := Expel;
    NewStudentList := FindExpellStudents(StudentsList);
    If NewStudentList <> Nil Then
        CreateActionForm('Список на отчисление')
    Else
        Application.MessageBox('Студентов на отчилсение нет :(', 'Информация',
          MB_OK + MB_ICONINFORMATION);
End;

Procedure TMainMenuForm.FindStudentButtonClick(Sender: TObject);
Begin
    CreateForm(TFindStudentForm);
End;

Procedure TMainMenuForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
    Confirmation: Integer;
Begin
    If IsSaved Then
    Begin
        Confirmation := Application.MessageBox('Вы действительно хотите выйти?',
          'Выход', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
        CanClose := Confirmation = IDYES;
    End
    Else
    Begin
        Confirmation := Application.MessageBox
          ('Вы не сохранили файл, хотите ли сохранить файл?', 'Выход',
          MB_YESNOCANCEl + MB_ICONQUESTION + MB_DEFBUTTON2);
        Case Confirmation Of
            MrYes:
                Begin
                    GroupListForm.SaveFileClick(Sender);
                    CanClose := IsSaved;
                End;
            MrNo:
                CanClose := True;
            MrCancel:
                CanClose := False;
        End;
    End;
End;

Function TMainMenuForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    FormHelp := False;
End;

Procedure TMainMenuForm.FormShow(Sender: TObject);
Begin
    FindStudentButton.Enabled := StudentsList <> Nil;
    ExpellStudentButton.Enabled := StudentsList <> Nil;
    DebtStudentButton.Enabled := StudentsList <> Nil;
End;

Procedure TMainMenuForm.GroupListButtonClick(Sender: TObject);
Begin
    CreateForm(TGroupListForm);
End;

Procedure TMainMenuForm.InstructionMenuClick(Sender: TObject);
Begin
    CreateModalForm('Инструкция', 'Список групп:'#13#10 +
      '1. Для добавления кандидата нажмите кнопку "Добавить".'#13#10
      + '2. Для изменения группы нажмите кнопку "Изменить".'#13#10
      + '3. Для удаления группы нажмите кнопку "Удалить".'#13#10
      + '4. Для получения диапазона для ввода поля наведитесь на него.'#13#10#13#10
      + 'Файлы:'#13#10 + '1. Файл имеет расширение .grplst'#13#10#13#10 +
      'Поиск:'#13#10 +
      'Для использования поиска введите ФИО студента и нажмите кнопку "Найти".'#13#10#13#10
      + 'Работает на русской системе Windows.', 1000, 450);
End;

End.
