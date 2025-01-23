Unit ListsActionUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids;

Type
    TListsActionForm = Class(TForm)
        FindStudentGrid: TStringGrid;
        TitleLabel: TLabel;
        DiciplineComboBox: TComboBox;
        ChooseLabel: TLabel;
        Procedure CreateParams(Var Params: TCreateParams); Override;
        Procedure FormCreate(Sender: TObject);
        Procedure DiciplineComboBoxChange(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    ListsActionForm: TListsActionForm;

Implementation

{$R *.dfm}

Uses
    MainMenuUnit, StudentLinkedListUnit;

Procedure TListsActionForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Procedure TListsActionForm.DiciplineComboBoxChange(Sender: TObject);
Var
    CurrentDicipline: Integer;
    NewStudent: PStudent;
Begin
    ClearStudentGrid(FindStudentGrid);

    CurrentDicipline := DiciplineComboBox.ItemIndex;
    NewStudent := FindDeptStudents(StudentsList, CurrentDicipline + 1);
    If NewStudent <> Nil Then
        DrawStudentsInGroupGrid(FindStudentGrid, NewStudent, 1)
    Else
    Begin
        Application.MessageBox('Студентов должников нет :(', 'Информация',
          MB_OK + MB_ICONINFORMATION);
        ClearStudentGrid(FindStudentGrid);
    End;
End;

Procedure TListsActionForm.FormCreate(Sender: TObject);
Var
    NewStudentList: PStudent;
Begin
    DiciplineComboBox.Items.Add('Логика');
    DiciplineComboBox.Items.Add('ЛАиАГ');
    DiciplineComboBox.Items.Add('История');
    DiciplineComboBox.Items.Add('ДМ');
    DiciplineComboBox.Items.Add('ОАиП');
    DiciplineComboBox.Items.Add('ОПИ');
    If StateListForm = Expel Then
    Begin
        ChooseLabel.Visible := False;
        DiciplineComboBox.Visible := False;
        NewStudentList := FindExpellStudents(StudentsList);
        If NewStudentList <> Nil Then
        Begin
            DrawStudentsInGroupGrid(FindStudentGrid, NewStudentList, 1);
        End
        Else
        Begin
            Application.MessageBox('Студентов на отчилсение нет :(',
              'Информация', MB_OK + MB_ICONINFORMATION);
            Close;
        End;
    End;
    If StateListForm = Debt Then
    Begin
        DrawStudentsInGroupGrid(FindStudentGrid, Nil, 1);

    End;

End;

End.
