Unit ViewStudentsInGroupUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Math,
    StudentsInGroupActionUnit, StudentLinkedListUnit;

Type
    TViewStudentsInGroupForm = Class(TForm)
        StudentInGroupGrid: TStringGrid;
        AddStudentButton: TButton;
        DeleteStudentButton: TButton;
        EditStudentButton: TButton;
        Procedure CreateParams(Var Params: TCreateParams); Override;
        Procedure AddStudentButtonClick(Sender: TObject);
        Procedure FormShow(Sender: TObject);
        Procedure DeleteStudentButtonClick(Sender: TObject);
        Procedure EditStudentButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    ViewStudentsInGroupForm: TViewStudentsInGroupForm;
    OldStudentData: TStudentData;

Implementation

Uses
    MainMenuUnit, GroupsLinkedListUnit, ViewGroupListUnit;

{$R *.dfm}

Procedure TViewStudentsInGroupForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Function GetStudentDataFromGrid(StudentsInGroupGrid: TStringGrid): TStudentData;
Var
    OldStudentData: TStudentData;
Begin
    With StudentsInGroupGrid, OldStudentData Do
    Begin
        GroupNumber := StrToInt(Cells[0, Row]);
        OldStudentData.Name := Cells[2, Row];
        Surname := Cells[1, Row];
        Patronymic := Cells[3, Row];
        Marks[Logic] := StrToInt(Cells[4, Row]);
        Marks[Algebra] := StrToInt(Cells[5, Row]);
        Marks[History] := StrToInt(Cells[6, Row]);
        Marks[DM] := StrToInt(Cells[7, Row]);
        Marks[BAAP] := StrToInt(Cells[8, Row]);
        Marks[BPE] := StrToInt(Cells[9, Row]);
        AvgMark :=
          RoundTo(((Marks[Logic] + Marks[Algebra] + Marks[History] + Marks[DM] +
          Marks[BAAP] + Marks[BPE]) / 6), -2);
    End;

    GetStudentDataFromGrid := OldStudentData;
End;

Procedure TViewStudentsInGroupForm.DeleteStudentButtonClick(Sender: TObject);
Var
    Confirmation, StudentsCount: Integer;
Begin
    StateOfSForm := DeleteS;
    If StudentInGroupGrid.Row > 0 Then
    Begin
        Confirmation := Application.MessageBox
          ('Вы действительно хотите удалить студента?', 'Удаление кандидата',
          MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
        If Confirmation = IDYES Then
        Begin
            DeleteStudent(StudentsList,
              GetStudentDataFromGrid(StudentInGroupGrid));
            StudentInGroupGrid.RowCount := StudentInGroupGrid.RowCount - 1;
            DrawStudentsInGroupGrid(StudentInGroupGrid, StudentsList,
              SelectedGroup);
            StudentsCount := FindCountInGroup(GroupList, SelectedGroup);
            DeleteOneStudent(GroupList, SelectedGroup);
            GroupListForm.SaveFile.Enabled := ( StudentsCount > 0);
        End;
    End
    Else
        Application.MessageBox('Не выбрано редактируемое поле!',
          'Предупреждение', MB_OK + MB_ICONWARNING);

End;

Procedure CreateActionForm(Const TitleLabelCaption, ActionButtonCaption
  : String);
Begin
    StudentsInGroupActionForm := TStudentsInGroupActionForm.Create
      (StudentsInGroupActionForm);
    StudentsInGroupActionForm.Icon := ViewStudentsInGroupForm.Icon;
    StudentsInGroupActionForm.TitleLabel.Width := 200;
    StudentsInGroupActionForm.TitleLabel.Caption := TitleLabelCaption;
    StudentsInGroupActionForm.ActionButton.Caption := ActionButtonCaption;
    StudentsInGroupActionForm.ShowModal;
End;

Procedure TViewStudentsInGroupForm.EditStudentButtonClick(Sender: TObject);
Begin
    If StudentInGroupGrid.Row > 0 Then
    Begin
        StateOfSForm := EditS;
        OldStudentData := GetStudentDataFromGrid(StudentInGroupGrid);
        CreateActionForm('Изменение информации', 'Изменить');
        If IsEdited Then
        Begin
            DrawStudentsInGroupGrid(StudentInGroupGrid, StudentsList,
              SelectedGroup);
            IsEdited := False;
            IsSaved := False;
            GroupListForm.SaveFile.Enabled := True;
            // ContentEdit.Text := '';
        End;
    End
    Else
        Application.MessageBox('Не выбрано редактируемое поле!',
          'Предупреждение', MB_OK + MB_ICONWARNING);

End;

Procedure TViewStudentsInGroupForm.FormShow(Sender: TObject);
Var
    StudentsCount: Integer;
Begin
    StudentsCount := FindCountInGroup(GroupList, SelectedGroup);
    StudentInGroupGrid.RowCount := StudentsCount + 1;
    
    GroupListForm.SaveFile.Enabled := ( StudentsCount > 0);
    DrawStudentsInGroupGrid(StudentInGroupGrid, StudentsList, SelectedGroup);

End;

Procedure TViewStudentsInGroupForm.AddStudentButtonClick(Sender: TObject);
Begin
    StateOfSForm := AddS;
    CreateActionForm('Добавление студента', 'Добавить');
    If IsEdited Then
    Begin
        StudentInGroupGrid.RowCount := FindCountInGroup(GroupList,
          SelectedGroup) + 1;
        DrawStudentsInGroupGrid(StudentInGroupGrid, StudentsList,
          SelectedGroup);
    End;

End;

End.
