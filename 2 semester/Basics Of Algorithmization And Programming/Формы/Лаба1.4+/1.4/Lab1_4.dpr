program Lab1_4;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MainTaskForm},
  Developer in 'Developer.pas' {DeveloperForm},
  Instruction in 'Instruction.pas' {InstructionForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainTaskForm, MainTaskForm);
  Application.CreateForm(TDeveloperForm, DeveloperForm);
  Application.CreateForm(TInstructionForm, InstructionForm);
  Application.Run;
end.
