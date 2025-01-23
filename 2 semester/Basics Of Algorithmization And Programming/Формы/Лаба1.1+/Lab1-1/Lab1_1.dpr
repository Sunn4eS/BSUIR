program Lab1_1;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MainTaskForm},
  Instruction in 'Instruction.pas' {InstructionForm},
  Developer in 'Developer.pas' {DeveloperForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainTaskForm, MainTaskForm);
  Application.CreateForm(TInstructionForm, InstructionForm);
  Application.CreateForm(TDeveloperForm, DeveloperForm);
  Application.Run;
end.
