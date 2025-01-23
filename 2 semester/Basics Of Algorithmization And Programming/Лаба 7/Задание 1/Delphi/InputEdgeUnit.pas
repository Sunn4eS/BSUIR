Unit InputEdgeUnit;

Interface

Uses
    Winapi.Windows,
    System.Classes, System.SysUtils,
    Vcl.Controls, Vcl.Dialogs, Vcl.Forms, Vcl.StdCtrls,
    VertexListUnit, EdgeListUnit, PositiveNumberComponentUnit;

Type
    TInputEdgeForm = Class(TForm)
        Edit1: TEdit;
        Edit2: TEdit;
        OkButton: TButton;
        BackButton: TButton;

        Procedure CreateParams(Var Params: TCreateParams); Override;
        Function FormHelp(Command: Word; Data: NativeInt; Var CallHelp: Boolean): Boolean;
        Procedure FormShow(Sender: TObject);
        Procedure FormHide(Sender: TObject);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);

        Procedure EditChange(Sender: TObject);
        Procedure EditContextPopup(Sender: TObject; MousePos: TPoint; Var Handled: Boolean);
        Procedure EditKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
        Procedure EditKeyPress(Sender: TObject; Var Key: Char);
        Procedure EditKeyUp(Sender: TObject; Var Key: Word; Shift: TShiftState);

        Procedure OkButtonClick(Sender: TObject);
        Procedure BackButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    InputEdgeForm: TInputEdgeForm;

Implementation

{$R *.dfm}

Uses
    MenuUnit, EditUnit;

Procedure TInputEdgeForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Function TInputEdgeForm.FormHelp(Command: Word; Data: NativeInt; Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    Result := False;
End;

Procedure TInputEdgeForm.FormShow(Sender: TObject);
Begin
    Edit1.SetFocus;
    Case InputFormMode Of
        Add:
        Begin
            Caption := 'Добавление ребра';
            OkButton.Caption := 'Добавить';
        End;
        Delete:
        Begin
            Caption := 'Удаление ребра';
            OkButton.Caption := 'Удалить';
        End;
    End;
End;

Procedure TInputEdgeForm.FormHide(Sender: TObject);
Begin
    Edit1.Text := '';
    Edit2.Text := '';
End;

Procedure TInputEdgeForm.FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
Begin
    If Key = VK_ESCAPE Then
        Close;
End;


Procedure TInputEdgeForm.EditChange(Sender: TObject);
Begin
    OkButton.Enabled := (Edit1.Text <> '') And (Edit2.Text <> '');
End;

Procedure TInputEdgeForm.EditContextPopup(Sender: TObject; MousePos: TPoint; Var Handled: Boolean);
Var
    Edit: TEdit;
Begin
    Edit := TEdit(Sender);
    PositiveNumberComponentContextPopup(Edit.Text, Edit.SelStart, Edit.SelLength, MAX_VERTEX, Handled);
End;

Procedure TInputEdgeForm.EditKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
Var
    Edit: TEdit;
Begin
    Edit := TEdit(Sender);
    PositiveNumberComponentKeyDown(Edit.Text, Edit.SelStart, Edit.SelLength, MAX_VERTEX, Key, Shift);
    If (Key = 13) And OkButton.Enabled Then
        OkButtonClick(OkButton);
End;

Procedure TInputEdgeForm.EditKeyPress(Sender: TObject; Var Key: Char);
Var
    Edit: TEdit;
Begin
    Edit := TEdit(Sender);
    PositiveNumberComponentKeyPress(Edit.Text, Edit.SelStart, Edit.SelLength, MAX_VERTEX, Key);
End;

Procedure TInputEdgeForm.EditKeyUp(Sender: TObject; Var Key: Word; Shift: TShiftState);
Begin
    PositiveNumberComponentKeyUp();
End;


Procedure TInputEdgeForm.OkButtonClick(Sender: TObject);
Var
    Value1, Value2: TValue;
    Vertex1, Vertex2: PVertex;
Begin
    Value1 := StrToInt(Edit1.Text);
    Value2 := StrToInt(Edit2.Text);
    Vertex1 := Graph.Find(Value1);
    Vertex2 := Graph.Find(Value2);
    Case InputFormMode Of
        Add:
            If (Vertex1 <> Nil) And (Vertex2 <> Nil) And (Vertex1^.Edges.Find(Value2) = Nil) And (Vertex1 <> Vertex2) Then
            Begin
                Vertex1^.Edges.Add(Value2);
                Vertex2^.Edges.Add(Value1);
                IsSaved := False;
                Close;
            End
            Else
                Application.MessageBox('Такой вершины не существует или такое ребро уже существует!', 'Ошибка', MB_OK + MB_ICONERROR);
        Delete:
            If (Vertex1 <> Nil) And (Vertex2 <> Nil) And (Vertex1^.Edges.Find(Value2) <> Nil) Then
            Begin
                Vertex1^.Edges.Delete(Value2);
                Vertex2^.Edges.Delete(Value1);
                IsSaved := False;
                Close;
            End
            Else
                Application.MessageBox('Такой вершины не существует или такое ребро не существует!', 'Ошибка', MB_OK + MB_ICONERROR);
    End;
End;

Procedure TInputEdgeForm.BackButtonClick(Sender: TObject);
Begin
    Close;
End;

End.
