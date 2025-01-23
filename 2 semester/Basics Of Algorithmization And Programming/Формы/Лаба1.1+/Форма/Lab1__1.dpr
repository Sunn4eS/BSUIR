program Lab1__1;

uses
  Vcl.Forms,
  Lab1_1 in 'Lab1_1.pas' {MainForm},
  InstructionForm in 'InstructionForm.pas' {InstrForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TInstrForm, InstrForm);
  Application.Run;
end.
