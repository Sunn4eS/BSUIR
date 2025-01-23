program Lab5_1;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MainTaskForm},
  Developer in 'Developer.pas' {DeveloperForm},
  Instruction in 'Instruction.pas' {InstructionForm},
  AddContact in 'AddContact.pas' {AddContactForm},
  DoubleLinkedList in 'DoubleLinkedList.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainTaskForm, MainTaskForm);
  Application.CreateForm(TDeveloperForm, DeveloperForm);
  Application.CreateForm(TInstructionForm, InstructionForm);
  Application.CreateForm(TAddContactForm, AddContactForm);
  Application.Run;
end.
