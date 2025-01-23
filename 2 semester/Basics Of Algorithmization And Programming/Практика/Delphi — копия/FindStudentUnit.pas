Unit FindStudentUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids;

Type
    TFindStudentForm = Class(TForm)
        TitleLabel: TLabel;
        NameLabel: TLabel;
        SurnameLabel: TLabel;
        PatronymicLabel: TLabel;
        NameEdit: TEdit;
        SurnameEdit: TEdit;
        PatronymicEdit: TEdit;
        FindStudentGrid: TStringGrid;
        SearchButton: TButton;
        Procedure FormCreate(Sender: TObject);
        Procedure CreateParams(Var Params: TCreateParams); Override;
        Procedure SearchButtonClick(Sender: TObject);
        Procedure EditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure EditKeyPress(Sender: TObject; Var Key: Char);
        Procedure EditOnChange(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    FindStudentForm: TFindStudentForm;

Implementation

{$R *.dfm}

USes
    MainMenuUnit, StudentLinkedListUnit, InputEditUnit;

Procedure TFindStudentForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Procedure TFindStudentForm.EditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShiftAndArrows(Key, Shift);
End;

Procedure TFindStudentForm.EditKeyPress(Sender: TObject; Var Key: Char);
Var
    Edit: TEdit;
Begin
    Edit := TEdit(Sender);

    NameComponentKeyPress(Edit.Text, Edit.SelStart, Edit.SelLength,
      NAME_LENGTH, Key);

End;

Procedure TFindStudentForm.EditOnChange(Sender: TObject);
Var
    NewStudentData: TStudentData;
    CanPress: Boolean;
Begin
    SearchButton.Enabled := False;
    If IsFullFieldsStudentsNSP(NameEdit, SurnameEdit, PatronymicEdit) Then
    Begin
        CanPress := (IsExistStudentNSP(StudentsList, Trim(NameEdit.Text),
          Trim(SurnameEdit.Text), Trim(PatronymicEdit.Text)));
        SearchButton.Enabled := CanPress;
    End;

End;

Procedure TFindStudentForm.FormCreate(Sender: TObject);
Begin
    FindStudentGrid.RowCount := 1;
    DrawStudentsInGroupGrid(FindStudentGrid, Nil, 0);
End;

Procedure TFindStudentForm.SearchButtonClick(Sender: TObject);
Var
    FoundStudent: PStudent;
Begin
    FoundStudent := SearchStudentNSP(StudentsList, Trim(NameEdit.Text),
      Trim(SurnameEdit.Text), Trim(PatronymicEdit.Text));
    FindStudentGrid.RowCount := FindStudentGrid.RowCount + 1;
    DrawStudentsInGroupGrid(FindStudentGrid, FoundStudent, 0)
End;

End.
