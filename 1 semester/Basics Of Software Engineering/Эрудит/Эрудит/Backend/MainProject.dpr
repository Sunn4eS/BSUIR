program MainProject;

uses
  Vcl.Forms,
  BackendGamerUnit in 'BackendGamerUnit.pas',
  BackendGameDictionaryUnit in 'BackendGameDictionaryUnit.pas',
  BackendLetterBankUnit in 'BackendLetterBankUnit.pas',
  BackendStartForm in 'BackendStartForm.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
