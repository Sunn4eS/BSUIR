Unit InputVertexUnit;

Interface

Uses
    Winapi.Windows,
    System.Classes, System.SysUtils,
    Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
    VertexListUnit, EdgeListUnit, PositiveNumberComponentUnit, WaysUnit;

Type
    TInputVertexForm = Class(TForm)
        Edit: TEdit;
        OkButton: TButton;
        BackButton: TButton;

        Procedure CreateParams(Var Params: TCreateParams); Override;
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure FormShow(Sender: TObject);
        Procedure FormHide(Sender: TObject);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);

        Procedure EditChange(Sender: TObject);
        Procedure EditContextPopup(Sender: TObject; MousePos: TPoint;
          Var Handled: Boolean);
        Procedure EditKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
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
    InputVertexForm: TInputVertexForm;

Implementation

{$R *.dfm}

Uses
    MenuUnit, EditUnit;

Procedure TInputVertexForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Function TInputVertexForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    Result := False;
End;

Procedure TInputVertexForm.FormShow(Sender: TObject);
Begin
    Edit.SetFocus;
    Case InputFormMode Of
        Add:
            Begin
                Caption := 'Добавление вершины';
                OkButton.Caption := 'Добавить';
            End;
        Delete:
            Begin
                Caption := 'Удаление вершины';
                OkButton.Caption := 'Удалить';
            End;
        Find:
            Begin
                Caption := 'Поиск путей';
                OkButton.Caption := 'Найти';
            End;
    End;
End;

Procedure TInputVertexForm.FormHide(Sender: TObject);
Begin
    Edit.Text := '';
End;

Procedure TInputVertexForm.FormKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    If Key = VK_ESCAPE Then
        Close;
End;

Procedure TInputVertexForm.EditChange(Sender: TObject);
Begin
    OkButton.Enabled := Edit.Text <> '';
End;

Procedure TInputVertexForm.EditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    PositiveNumberComponentContextPopup(Edit.Text, Edit.SelStart,
      Edit.SelLength, MAX_VERTEX, Handled);
End;

Procedure TInputVertexForm.EditKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    PositiveNumberComponentKeyDown(Edit.Text, Edit.SelStart, Edit.SelLength,
      MAX_VERTEX, Key, Shift);
    If (Key = Ord(ENTER)) And OkButton.Enabled Then
        OkButtonClick(OkButton);
End;

Procedure TInputVertexForm.EditKeyPress(Sender: TObject; Var Key: Char);
Begin
    PositiveNumberComponentKeyPress(Edit.Text, Edit.SelStart, Edit.SelLength,
      MAX_VERTEX, Key);
End;

Procedure TInputVertexForm.EditKeyUp(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    PositiveNumberComponentKeyUp();
End;

Procedure TInputVertexForm.OkButtonClick(Sender: TObject);
Var
    Value: TValue;
Begin
    Value := StrToInt(Edit.Text);
    Case InputFormMode Of
        Add:
            If Graph.Find(Value) = Nil Then
            Begin
                Graph.Add(Value);
                IsSaved := Graph.Head = Nil;
                Close;
            End
            Else
                Application.MessageBox('Такая вершина уже существует!',
                  'Ошибка', MB_OK + MB_ICONERROR);
        Delete:
            If Graph.Find(Value) <> Nil Then
            Begin
                Graph.Delete(Value);
                IsSaved := Graph.Head = Nil;
                Close;
            End
            Else
                Application.MessageBox('Такой вершины не существует!', 'Ошибка',
                  MB_OK + MB_ICONERROR);
        Find:
            If Graph.Find(Value) <> Nil Then
            Begin
                WayForm.FormInit(Graph, Value);
                self.Visible := False;
                WayForm.ShowModal();
                self.Visible := True;
                Close;
            End
            Else
                Application.MessageBox('Такой вершины не существует!', 'Ошибка',
                  MB_OK + MB_ICONERROR);
    End;
End;

Procedure TInputVertexForm.BackButtonClick(Sender: TObject);
Begin
    Close;
End;

End.
