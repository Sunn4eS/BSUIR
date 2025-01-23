Unit StudentsInGroupActionUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, MainMenuUnit,
    Math;

Type
    TStudentsInGroupActionForm = Class(TForm)
        TitleLabel: TLabel;
        NameLabel: TLabel;
        SurnameLabel: TLabel;
        PatronymicLabel: TLabel;
        NameEdit: TEdit;
        SurnameEdit: TEdit;
        PatronymicEdit: TEdit;
        MarkGrid: TStringGrid;
        ActionButton: TButton;
        CancelButton: TButton;
        MarksLabel: TLabel;
        GroupNumberLabel: TLabel;
        GroupNumberEdit: TEdit;

        Procedure CreateParams(Var Params: TCreateParams); Override;
        Procedure CancelButtonClick(Sender: TObject);
        Procedure FormShow(Sender: TObject);
        Procedure MarkGridKeyPress(Sender: TObject; Var Key: Char);
        Procedure ActionButtonClick(Sender: TObject);
        Procedure EditChange(Sender: TObject);
        Procedure EditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure EditKeyPress(Sender: TObject; Var Key: Char);
        Procedure EditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure MarkGridSetEditText(Sender: TObject; ACol, ARow: Integer;
          Const Value: String);
        Procedure GroupNumberEditKeyPress(Sender: TObject; Var Key: Char);

    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    StudentsInGroupActionForm: TStudentsInGroupActionForm;

Implementation

{$R *.dfm}

Uses
    StudentLinkedListUnit, InputEditUnit, GroupsLinkedListUnit,
    ViewStudentsInGroupUnit;

Procedure TStudentsInGroupActionForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Procedure SetStudentData(OldStudentData: TStudentData);
Begin
    With StudentsInGroupActionForm, OldStudentData, MarkGrid Do
    Begin

        NameEdit.Text := String(OldStudentData.Name);
        SurnameEdit.Text := String(Surname);
        PatronymicEdit.Text := String(Patronymic);
        // GroupNumberEdit.Text := IntToStr(GroupNumber);
        GroupNumberEdit.Text := IntToStr(SelectedGroup);
        Cells[0, 1] := IntToStr(Marks[Logic]);
        Cells[1, 1] := IntToStr(Marks[Algebra]);
        Cells[2, 1] := IntToStr(Marks[History]);
        Cells[3, 1] := IntToStr(Marks[DM]);
        Cells[4, 1] := IntToStr(Marks[BAAP]);
        Cells[5, 1] := IntToStr(Marks[BPE]);

    End;
End;

Function CreateStudentData(): TStudentData;
Var
    NewStudent: TStudentData;
    I: Integer;
Begin
    With NewStudent, StudentsInGroupActionForm Do
    Begin
        GroupNumber := StrToInt(GroupNumberEdit.Text);
        NewStudent.Name := String(NameEdit.Text);
        Surname := String(SurnameEdit.Text);
        Patronymic := String(PatronymicEdit.Text);
        With MarkGrid Do
        Begin
            Marks[Logic] := StrToInt(Cells[0, 1]);
            Marks[Algebra] := StrToInt(Cells[1, 1]);
            Marks[History] := StrToInt(Cells[2, 1]);
            Marks[DM] := StrToInt(Cells[3, 1]);
            Marks[BAAP] := StrToInt(Cells[4, 1]);
            Marks[BPE] := StrToInt(Cells[5, 1]);
        End;
        AvgMark :=
          RoundTo(((Marks[Logic] + Marks[Algebra] + Marks[History] + Marks[DM] +
          Marks[BAAP] + Marks[BPE]) / 6), -2);
    End;

    CreateStudentData := NewStudent;
End;

Procedure TStudentsInGroupActionForm.ActionButtonClick(Sender: TObject);
Var
    NewStudentData: TStudentData;
Begin
    NewStudentData := CreateStudentData();
    If StateOfSForm = AddS Then
    Begin

        AddStudent(StudentsList, NewStudentData);
        AddStudentToGroup(GroupList, SelectedGroup);
    End
    Else If StateOfSForm = EditS Then
    Begin
        EditStudent(GroupList, OldStudentData, NewStudentData, StudentsList);
    End;

    IsEdited := True;
    Close;
End;

Procedure TStudentsInGroupActionForm.CancelButtonClick(Sender: TObject);
Begin
    IsEdited := False;
    Close;

End;

Procedure TStudentsInGroupActionForm.FormShow(Sender: TObject);
Begin
    If StateOfSForm = AddS Then
    Begin
        GroupNumberEdit.Text := IntToStr(SelectedGroup);
        GroupNumberEdit.Visible := False;
        GroupNumberLabel.Visible := False;
    End;
    If StateOfSForm = EditS Then
    Begin
        GroupNumberEdit.Text := IntToStr(SelectedGroup);
        GroupNumberEdit.Visible := True;
        GroupNumberLabel.Visible := True;
        SetStudentData(OldStudentData);
    End;
    DrawMarksGrid(MarkGrid);

End;

Procedure TStudentsInGroupActionForm.GroupNumberEditKeyPress(Sender: TObject;
  Var Key: Char);
Begin
    CheckLength(GROUP_LENGTH, GroupNumberEdit, Key);
    CheckComboButtons(Key, GroupNumberEdit, NUMBERS);
End;

Procedure TStudentsInGroupActionForm.MarkGridKeyPress(Sender: TObject;
  Var Key: Char);
Begin
    CheckValidMarks(MarkGrid, Key);
End;

Procedure TStudentsInGroupActionForm.MarkGridSetEditText(Sender: TObject;
  ACol, ARow: Integer; Const Value: String);
Begin
    ActionButton.Enabled := IsFullFieldsStudents(NameEdit, SurnameEdit,
      PatronymicEdit, GroupNumberEdit, MarkGrid) And
      (FindCountInGroup(GroupList, SelectedGroup) < 40) And
      IsExistGroupByNumber(GroupList, StrToInt(GroupNumberEdit.Text));

End;

Procedure TStudentsInGroupActionForm.EditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShiftAndArrows(Key, Shift);
End;

Procedure TStudentsInGroupActionForm.EditKeyPress(Sender: TObject;
  Var Key: Char);
Var
    Edit: TEdit;
Begin
    Edit := TEdit(Sender);

    NameComponentKeyPress(Edit.Text, Edit.SelStart, Edit.SelLength,
      NAME_LENGTH, Key);

End;

Procedure TStudentsInGroupActionForm.EditContextPopup(Sender: TObject;
  MousePos: TPoint; Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TStudentsInGroupActionForm.EditChange(Sender: TObject);
Var
    NewStudentData: TStudentData;
    CanPress: Boolean;
Begin
    ActionButton.Enabled := False;
    If IsFullFieldsStudents(NameEdit, SurnameEdit, PatronymicEdit,
      GroupNumberEdit, MarkGrid) Then
    Begin
        NewStudentData := CreateStudentData();
        CanPress := (Not IsExistStudent(StudentsList, NewStudentData)) And
          IsExistGroupByNumber(GroupList, StrToInt(GroupNumberEdit.Text));
        ActionButton.Enabled := CanPress;
    End;
End;

End.
