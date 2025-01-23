program ApplicationLab7_1;

uses
  Vcl.Forms,
  MenuUnit in 'MenuUnit.pas' {MenuForm},
  EditUnit in 'EditUnit.pas' {EditForm},
  InputVertexUnit in 'InputVertexUnit.pas' {InputVertexForm},
  InputEdgeUnit in 'InputEdgeUnit.pas' {InputEdgeForm},
  VertexListUnit in 'VertexListUnit.pas',
  EdgeListUnit in 'EdgeListUnit.pas',
  PositiveNumberComponentUnit in 'PositiveNumberComponentUnit.pas',
  FileUnit in 'FileUnit.pas',
  AdjacencyMatrixUnit in 'AdjacencyMatrixUnit.pas' {AdjacencyMatrixForm},
  WaysUnit in 'WaysUnit.pas' {WayForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMenuForm, MenuForm);
  Application.CreateForm(TEditForm, EditForm);
  Application.CreateForm(TInputVertexForm, InputVertexForm);
  Application.CreateForm(TInputEdgeForm, InputEdgeForm);
  Application.CreateForm(TAdjacencyMatrixForm, AdjacencyMatrixForm);
  Application.CreateForm(TWayForm, WayForm);
  Application.Run;
end.
