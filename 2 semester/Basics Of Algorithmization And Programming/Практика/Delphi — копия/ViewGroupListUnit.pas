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
    Procedure CreateParams(Var Params: TCreateParams); override;
        Procedure AddGroupClick(Sender: TObject);
        Procedure DeleteGroupClick(Sender: TObject);
        Procedure EditGroupClick(Sender: TObject);
        Procedure FormShow(Sender: TObject);
        
    procedure ViewStudentsInGroupButtonClick(Sender: TObject);
    procedure GroupGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure OpenFileClick(Sender: TObject);
    procedure SaveFileClick(Sender: TObject);

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
    MainMenuUnit,  ViewStudentsInGroupUnit, FileUnit, StudentLinkedListUnit;

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
    StateOfGForm := AddG;
    CreateActionForm('Добавление группы', 'Добавить');
    If IsEdited Then
    Begin
        GroupGrid.RowCount := GroupGrid.RowCount + 1;
        DrawGroupGrid(GroupGrid, GroupList);
        IsEdited := False;
        IsSaved := False;
        SaveFile.Enabled := True; 
    End;
End;

procedure TGroupListForm.ViewStudentsInGroupButtonClick(Sender: TObject);
begin
    CreateForm(TViewStudentsInGroupForm);
end;

Function GetGroupDataFromGrid(GroupGrid: TStringGrid): TGroupData;
var 
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

    StateOfGForm := DeleteG;
    If GroupGrid.Row > 0 Then
    Begin
        Confirmation := Application.MessageBox('Вы действительно хотите удалить группу?', 'Удаление кандидата', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
        If Confirmation = IDYES Then
        Begin
            DeleteGroupF(GroupList, GetGroupDataFromGrid(GroupGrid), StudentsList);
            GroupGrid.RowCount := GroupGrid.RowCount - 1;
            DrawGroupGrid(GroupGrid, GroupList);
            GroupCount := CountGroups(GroupList);
            
            IsSaved := GroupCount = 0;
            SaveFile.Enabled := GroupCount > 0;
    
        End;
    End
    Else
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
        If isEdited Then
        Begin
            DrawGroupGrid(GroupGrid, GroupList);
            IsEdited := False;
            IsSaved := False;
            SaveFile.Enabled := True;
           
        End;
    End
    Else
        Application.MessageBox('Не выбрано редактируемое поле!', 'Предупреждение', MB_OK + MB_ICONWARNING);
End;

Procedure TGroupListForm.FormShow(Sender: TObject);
Var
    GroupCount : Integer;
Begin
    GroupCount := CountGroups(GroupList);
    GroupGrid.RowCount := CountGroups(GroupList) + 1;
    SaveFile.Enabled := GroupCount > 0;
    DrawGroupGrid(GroupGrid, GroupList);
End;


procedure TGroupListForm.GroupGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
    ViewStudentsInGroupButton.Enabled := Not (ARow = 0);
    if ARow > 0 Then
        SelectedGroup := StrToInt(GroupGrid.Cells[0, Arow]);
end;

procedure TGroupListForm.OpenFileClick(Sender: TObject);
Var
    InputGroupFile: TGroupDataFile;
    InputStudentFile: TStudentDataFile;
    
    TempGroupList: PGroup;
    TempStudent: PStudent;
    
    IsCorrect: Boolean;
Begin
    OpenTextFileDialog.DefaultExt := 'grplst';
    If OpenTextFileDialog.Execute Then
    Begin
        AssignFile(InputGroupFile, OpenTextFileDialog.FileName);
        TempGroupList := Nil;
        IsCorrect := ReadFileData(InputGroupFile, InputStudentFile, TempGroupList, TempStudent, True);
        If IsCorrect Then
        Begin
            ClearGroups(GroupList);
            //RecordFileData(GroupList, TempGroupList, GroupGrid);
            IsSaved := True;
            SaveFile.Enabled := True;
        End
        Else
        Begin
            ClearGroups(TempGroupList);
            Application.MessageBox('Содержимое файла повреждено!', 'Ошибка', MB_OK + MB_ICONERROR);
        End;
    End;
    OpenTextFileDialog.DefaultExt := 'stdlst';
    If OpenTextFileDialog.Execute Then
    Begin
        
        TempStudent := Nil;
        AssignFile(InputStudentFile, OpenTextFileDialog.FileName);
        IsCorrect := ReadFileData(InputGroupFile, InputStudentFile, TempGroupList, TempStudent, False);
        If IsCorrect Then
        Begin
            ClearStudents(StudentsList);
            RecordFileData(GroupList, TempGroupList, StudentsList, TempStudent,
             GroupGrid);
            IsSaved := True;
            SaveFile.Enabled := True;
        End
        Else
        Begin
            ClearStudents(TempStudent);
            Application.MessageBox('Содержимое файла повреждено!', 'Ошибка', MB_OK + MB_ICONERROR);
        End;
    End; 
end;

procedure TGroupListForm.SaveFileClick(Sender: TObject);
Var
    OutputGroupFile: TGroupDataFile;
    OutputStudentFile: TStudentDataFile;
Begin
       SaveTextFileDialog.DefaultExt := 'grplst';
    If SaveTextFileDialog.Execute Then
    Begin
        AssignFile(OutputGroupFile, SaveTextFileDialog.FileName);
        WriteFileData(OutputGroupFile, OutputStudentFile, GroupList, StudentsList, True);
        IsSaved := True;
    End;
    SaveTextFileDialog.DefaultExt := 'stdlst';
    If SaveTextFileDialog.Execute Then
    Begin
        AssignFile(OutputStudentFile, SaveTextFileDialog.FileName);
        WriteFileData(OutputGroupFile, OutputStudentFile, GroupList, StudentsList, False);
        IsSaved := True;
    End;
end;

End.
