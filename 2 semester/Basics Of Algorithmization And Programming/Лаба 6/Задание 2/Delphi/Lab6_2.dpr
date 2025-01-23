program Lab6_2;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MainTaskForm},
  Developer in 'Developer.pas' {DeveloperForm},
  Instruction in 'Instruction.pas' {InstructionForm},
  GraphLinkedList in 'GraphLinkedList.pas',
  AddLine in 'AddLine.pas' {AddLineForm},
  QueueLinkedList in 'QueueLinkedList.pas',
  FindPath in 'FindPath.pas' {FindPathForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainTaskForm, MainTaskForm);
  Application.CreateForm(TDeveloperForm, DeveloperForm);
  Application.CreateForm(TInstructionForm, InstructionForm);
  Application.CreateForm(TAddLineForm, AddLineForm);
  Application.CreateForm(TFindPathForm, FindPathForm);
  Application.Run;
end.
