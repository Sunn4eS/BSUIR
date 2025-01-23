Unit GroupListActionUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TGroupListActionForm = Class(TForm)
        TitleLabel: TLabel;
        ActionButton: TButton;
        CancelButton: TButton;
        NumberLabel: TLabel;
        YearLabel: TLabel;
        CodeLabel: TLabel;
        NumberEdit: TEdit;
        YearEdit: TEdit;
        CodeEdit: TEdit;
        Procedure CreateParams(Var Params: TCreateParams); Override;
        Procedure CancelButtonClick(Sender: TObject);
        Procedure EditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure NumberEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure YearEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure CodeEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure EditChange(Sender: TObject);
        Procedure ActionButtonClick(Sender: TObject);
        Procedure EditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure FormClose(Sender: TObject; Var Action: TCloseAction);
        Procedure FormShow(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    GroupListActionForm: TGroupListActionForm;

Implementation

Uses
    InputEditUnit, GroupsLinkedListUnit, MainMenuUnit, ViewGroupListUnit;

{$R *.dfm}

Procedure TGroupListActionForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Function CreateGroup(): TGroupData;
Var
    NewGroup: TGroupData;
Begin
    With NewGroup, GroupListActionForm Do
    Begin
        GroupNumber := StrToInt(NumberEdit.Text);
        Year := StrToInt(YearEdit.Text);
        Code := CodeEdit.Text;
        CountOfStudents := 0;
    End;

    CreateGroup := NewGroup;
End;

Procedure TGroupListActionForm.ActionButtonClick(Sender: TObject);
Var
    NewGroupData: TGroupData;
Begin
    NewGroupData := CreateGroup();
    If StateOfGForm = AddG Then
    Begin
        AddGroup(GroupList, NewGroupData);
    End
    Else If StateOfGForm = EditG Then
    Begin
        EditGroup(GroupList, OldGroupData, NewGroupData, StudentsList);
    End;

    IsEdited := True;
    Close;
End;

Procedure TGroupListActionForm.CancelButtonClick(Sender: TObject);
Begin
    IsEdited := False;
    Close;
End;

Procedure TGroupListActionForm.EditContextPopup(Sender: TObject;
  MousePos: TPoint; Var Handled: Boolean);
Begin
    Handled := True;
End;

Procedure TGroupListActionForm.CodeEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    CheckComboButtons(Key, CodeEdit, NUMBERS_EXT);
    CheckLength(CODE_LENGTH, CodeEdit, Key);
End;

Procedure TGroupListActionForm.EditChange(Sender: TObject);
Var
    NewGroupData: TGroupData;
Begin
    ActionButton.Enabled := False;
    If IsFullFields(NumberEdit, YearEdit, CodeEdit) Then
    Begin
        NewGroupData := CreateGroup();
        ActionButton.Enabled := Not IsExistGroup(GroupList, NewGroupData);
    End;

End;

Procedure TGroupListActionForm.EditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    CheckShiftAndArrows(Key, Shift);
End;

Procedure TGroupListActionForm.FormClose(Sender: TObject;
  Var Action: TCloseAction);
Begin
    IsEdited := False
End;

Procedure SetGroupData(OldGroupData: TGroupData);
Begin
    With GroupListActionForm, OldGroupData Do
    Begin
        NumberEdit.Text := IntToStr(GroupNumber);
        YearEdit.Text := IntToStr(Year);
        CodeEdit.Text := String(Code);
    End;
End;

Procedure TGroupListActionForm.FormShow(Sender: TObject);
Begin
    If StateOfGForm = EditG Then
        SetGroupData(OldGroupData);
End;

Procedure TGroupListActionForm.NumberEditKeyPress(Sender: TObject;
  Var Key: Char);
Begin
    CheckLength(GROUP_LENGTH, NumberEdit, Key);
    CheckComboButtons(Key, NumberEdit, NUMBERS);
End;

Procedure TGroupListActionForm.YearEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    CheckComboButtons(Key, YearEdit, NUMBERS);
    CheckNumberRange(Key, YEAR_MAX, YEAR_MIN, YearEdit.Text)
End;

End.
