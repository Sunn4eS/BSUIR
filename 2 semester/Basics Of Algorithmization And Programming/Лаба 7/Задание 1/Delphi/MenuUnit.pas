Unit MenuUnit;

Interface

Uses
    Winapi.Windows,
    System.Classes,
    Vcl.Graphics,
    Vcl.Controls, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.Forms, Vcl.Menus, Vcl.StdCtrls,
    EditUnit, AdjacencyMatrixUnit, VertexListUnit, EdgeListUnit, ViewGraphUnit,
    FileUnit, WaysUnit, InputVertexUnit,
    Vcl.ExtCtrls, SysUtils;

Type
    TMenuForm = Class(TForm)
        MainMenu: TMainMenu;
        FileMenuItem: TMenuItem;
        OpenMenuItem: TMenuItem;
        SaveMenuItem: TMenuItem;
        SeparatorMenuItem: TMenuItem;
        ExitMenuItem: TMenuItem;
        InstructionMenuItem: TMenuItem;
        DeveloperMenuItem: TMenuItem;

        OpenTextFileDialog: TOpenTextFileDialog;
        SaveTextFileDialog: TSaveTextFileDialog;

        EditVerticesButton: TButton;
        EditEdgesButton: TButton;
        AdjacencyMatrixButton: TButton;
        PaintBox: TPaintBox;
        WayButton: TButton;

        Procedure FormCreate(Sender: TObject);
        Procedure FormDestroy(Sender: TObject);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);

        Procedure InstructionMenuItemClick(Sender: TObject);
        Procedure DeveloperMenuItemClick(Sender: TObject);
        Procedure OpenMenuItemClick(Sender: TObject);
        Procedure SaveMenuItemClick(Sender: TObject);
        Procedure ExitMenuItemClick(Sender: TObject);

        Procedure EditVerticesButtonClick(Sender: TObject);
        Procedure EditEdgesButtonClick(Sender: TObject);
        Procedure AdjacencyMatrixButtonClick(Sender: TObject);
        Procedure PaintBoxPaint(Sender: TObject);
        Procedure WayButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    MenuForm: TMenuForm;

Type
    TEditFormMode = (Vertices, Edges);

Var
    Graph: TVertexList;
    EditFormMode: TEditFormMode;
    IsSaved: Boolean = True;

Implementation

{$R *.dfm}

Uses
    Math;

Procedure TMenuForm.FormCreate(Sender: TObject);
Begin
    Graph.Create();
End;

Procedure TMenuForm.FormDestroy(Sender: TObject);
Begin
    Graph.Clear();
End;

Function TMenuForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    Result := False;
End;

Procedure TMenuForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
    Confirmation: Integer;
Begin
    If Not IsSaved Then
    Begin
        Confirmation := Application.MessageBox
          ('Вы не сохранили файл, хотите ли сохранить файл?', 'Выход',
          MB_YESNOCANCEl + MB_ICONQUESTION + MB_DEFBUTTON2);
        Case Confirmation Of
            MrYes:
                Begin
                    SaveMenuItemClick(Sender);
                    CanClose := IsSaved;
                End;
            MrNo:
                CanClose := True;
            MrCancel:
                CanClose := False;
        End;
    End;
End;

Procedure CreateModalForm(Const CaptionText, LabelText: String;
  Const ModalWidth, ModalHeight: Integer);
Var
    ModalForm: TForm;
    ModalLabel: TLabel;
Begin
    ModalForm := TForm.Create(Nil);
    Try
        ModalForm.BorderIcons := [BiSystemMenu];
        ModalForm.BorderStyle := BsSingle;
        ModalForm.Caption := CaptionText;
        ModalForm.Height := ModalHeight;
        ModalForm.Icon := MenuForm.Icon;
        ModalForm.Position := PoScreenCenter;
        ModalForm.Width := ModalWidth;
        ModalForm.OnHelp := MenuForm.FormHelp;

        ModalLabel := TLabel.Create(ModalForm);
        ModalLabel.Caption := LabelText;
        ModalLabel.Font.Size := 12;
        ModalLabel.Left := (ModalForm.ClientWidth - ModalLabel.Width) Div 2;
        ModalLabel.Parent := ModalForm;
        ModalLabel.Top := (ModalForm.ClientHeight - ModalLabel.Height) Div 2;

        ModalForm.ShowModal;
    Finally
        ModalForm.Free;
    End;
End;

Procedure TMenuForm.InstructionMenuItemClick(Sender: TObject);
Begin
    CreateModalForm('Инструкция', 'Файл должен содержать следующую структуру:' + #13#10 +
                                  'Первыми перечилсяются номера вершин, каждая с новой строки.' + #13#10 +
                                  'Дальее идёт пустая строка и перечилсяються вершины, которые' + #13#10 +
                                  'нужно соеденить. ', 800, 400);
End;

Procedure TMenuForm.DeveloperMenuItemClick(Sender: TObject);
Begin
    CreateModalForm('О разработчике', 'Бражалович Александр Иванович'#13#10 +
      'Группа 351004'#13#10, 500, 150);
End;

Procedure TMenuForm.OpenMenuItemClick(Sender: TObject);
Var
    InputFile: TextFile;
    TempGraph: TVertexList;
    IsCorrect: Boolean;
Begin
    If OpenTextFileDialog.Execute Then
    Begin
        AssignFile(InputFile, OpenTextFileDialog.FileName);
        TempGraph.Create();
        IsCorrect := ReadFileGraph(InputFile, TempGraph);
        If IsCorrect Then
        Begin
            Graph.Clear();
            Graph := TempGraph;
        End
        Else
        Begin
            TempGraph.Clear();
            Application.MessageBox('Содержимое файла повреждено!', 'Ошибка',
              MB_OK + MB_ICONERROR);
        End;
    End;
    PaintBoxPaint(PaintBox);
End;

Procedure TMenuForm.PaintBoxPaint(Sender: TObject);
Var
    CenterX, CenterY, Distance: Integer;
    RotateAngle: Real;
Begin
    PaintBox.Canvas.Brush.Color := ClWhite;
    PaintBox.Canvas.FillRect(PaintBox.Canvas.ClipRect);
    WayButton.Enabled := Graph.Count <> 0;
    If Graph.Count <> 0 Then
    Begin
        PaintBox.Canvas.Pen.Width := 1;

        CenterX := PaintBox.Width Div 2;
        CenterY := PaintBox.Height Div 2;
        Distance := Round(LogN(2, Graph.Count) *
          (PaintBox.Width * VertexSize / 100));
        RotateAngle := 2 * Pi / Graph.Count;

        DrawVerteces(PaintBox, Graph, CenterX, CenterY, Distance, RotateAngle);
    End;
End;

Procedure TMenuForm.SaveMenuItemClick(Sender: TObject);
Var
    OutputFile: TextFile;
Begin
    If SaveTextFileDialog.Execute Then
    Begin
        AssignFile(OutputFile, SaveTextFileDialog.FileName);
        WriteFileGraph(OutputFile, Graph);
        IsSaved := True;
    End;
End;

Procedure TMenuForm.WayButtonClick(Sender: TObject);
Begin
    InputFormMode := Find;
    InputVertexForm.ShowModal();
End;

Procedure TMenuForm.ExitMenuItemClick(Sender: TObject);
Begin
    Close;
End;

Procedure TMenuForm.EditVerticesButtonClick(Sender: TObject);
Begin
    EditFormMode := Vertices;
    EditForm.ShowModal;
    PaintBoxPaint(PaintBox);
End;

Procedure TMenuForm.EditEdgesButtonClick(Sender: TObject);
Begin
    EditFormMode := Edges;
    EditForm.ShowModal;
    PaintBoxPaint(PaintBox);
End;

Procedure TMenuForm.AdjacencyMatrixButtonClick(Sender: TObject);
Begin
    AdjacencyMatrixForm.ShowModal;
End;

End.
