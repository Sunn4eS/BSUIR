Unit EditUnit;

Interface

Uses
    Winapi.Windows,
    System.Classes, System.SysUtils,
    Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
    InputVertexUnit, InputEdgeUnit, VertexListUnit;

Type
    TEditForm = Class(TForm)
        AddButton: TButton;
        DeleteButton: TButton;
        BackButton: TButton;

        Procedure CreateParams(Var Params: TCreateParams); Override;
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure FormShow(Sender: TObject);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);

        Procedure AddButtonClick(Sender: TObject);
        Procedure DeleteButtonClick(Sender: TObject);
        Procedure BackButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    EditForm: TEditForm;

Type
    TInputFormMode = (Add, Delete, Find);

Var
    InputFormMode: TInputFormMode;

Implementation

{$R *.dfm}

Uses
    MenuUnit;

Procedure TEditForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Function TEditForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    Result := False;
End;

Procedure TEditForm.FormShow(Sender: TObject);
Begin
    Case EditFormMode Of
        Vertices:
            Caption := 'Редактирование вершин';
        Edges:
            Caption := 'Редактирование ребер';
    End;
End;

Procedure TEditForm.FormKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    If Key = VK_ESCAPE Then
        Close;
End;

Procedure TEditForm.AddButtonClick(Sender: TObject);
Begin
    Visible := False;
    InputFormMode := Add;
    Case EditFormMode Of
        Vertices:
            If Graph.Count < MAX_VERTEX Then
                InputVertexForm.ShowModal
            Else
                Application.MessageBox
                  (PWideChar('Количество вершин не может превышать ' +
                  IntToStr(MAX_VERTEX)), 'Ошибка', MB_OK + MB_ICONERROR);
        Edges:
            InputEdgeForm.ShowModal;
    End;
    Visible := True;
End;

Procedure TEditForm.DeleteButtonClick(Sender: TObject);
Begin
    Visible := False;
    InputFormMode := Delete;
    Case EditFormMode Of
        Vertices:
            InputVertexForm.ShowModal;
        Edges:
            InputEdgeForm.ShowModal;
    End;
    Visible := True;
End;

Procedure TEditForm.BackButtonClick(Sender: TObject);
Begin
    Close;
End;

End.
