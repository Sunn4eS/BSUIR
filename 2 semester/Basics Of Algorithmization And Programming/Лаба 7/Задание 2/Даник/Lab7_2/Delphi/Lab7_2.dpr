program Lab7_2;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  InstructionUnit in 'InstructionUnit.pas' {InstructionForm},
  DeveloperUnit in 'DeveloperUnit.pas' {DeveloperForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TInstructionForm, InstructionForm);
  Application.CreateForm(TDeveloperForm, DeveloperForm);
  Application.Run;
end.
