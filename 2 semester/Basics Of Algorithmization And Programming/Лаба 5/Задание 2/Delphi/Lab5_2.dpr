program Lab5_2;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MainTaskForm},
  Developer in 'Developer.pas' {DeveloperForm},
  Instruction in 'Instruction.pas' {InstructionForm},
  TreeUnit in 'TreeUnit.pas',
  AddLeaf in 'AddLeaf.pas' {AddLeafForm},
  DeleteLeaf in 'DeleteLeaf.pas' {DeleteLeafForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainTaskForm, MainTaskForm);
  Application.CreateForm(TDeveloperForm, DeveloperForm);
  Application.CreateForm(TInstructionForm, InstructionForm);
  Application.CreateForm(TAddLeafForm, AddLeafForm);
  Application.CreateForm(TDeleteLeafForm, DeleteLeafForm);
  Application.Run;
end.
