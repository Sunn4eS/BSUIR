program Practice;

uses
  Vcl.Forms,
  MainMenuUnit in 'MainMenuUnit.pas' {MainMenuForm},
  ViewGroupListUnit in 'ViewGroupListUnit.pas' {GroupListForm},
  GroupListActionUnit in 'GroupListActionUnit.pas' {GroupListActionForm},
  InputEditUnit in 'InputEditUnit.pas',
  GroupsLinkedListUnit in 'GroupsLinkedListUnit.pas',
  StudentLinkedListUnit in 'StudentLinkedListUnit.pas',
  ViewStudentsInGroupUnit in 'ViewStudentsInGroupUnit.pas' {ViewStudentsInGroupForm},
  StudentsInGroupActionUnit in 'StudentsInGroupActionUnit.pas' {StudentsInGroupActionForm},
  FindStudentUnit in 'FindStudentUnit.pas' {FindStudentForm},
  ListsActionUnit in 'ListsActionUnit.pas' {ListsActionForm},
  FileUnit in 'FileUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainMenuForm, MainMenuForm);
  Application.CreateForm(TGroupListForm, GroupListForm);
  Application.CreateForm(TGroupListActionForm, GroupListActionForm);
  Application.CreateForm(TViewStudentsInGroupForm, ViewStudentsInGroupForm);
  Application.CreateForm(TStudentsInGroupActionForm, StudentsInGroupActionForm);
  Application.CreateForm(TFindStudentForm, FindStudentForm);
  Application.CreateForm(TListsActionForm, ListsActionForm);
  Application.Run;
end.
