Unit MainForm;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Instruction, Developer,
    Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.Grids, Vcl.ExtCtrls, TreeUnit, AddLeaf,
    DeleteLeaf;

Type
    TArr = Array Of Integer;
    ERRORS_LIST = (CORRECT, NOT_READABLE, NOT_WRITEABLE, FILE_EMPTY, LINE_ERR,
      NAME_ERR, NUMBER_ERR);

    TMainTaskForm = Class(TForm)
        MainFormMenu: TMainMenu;
        FileMenu: TMenuItem;
        InstructionMenu: TMenuItem;
        DeveloperMenu: TMenuItem;
        N1: TMenuItem;
        QuitMenu: TMenuItem;
        AddButton: TButton;
        DeleteButton: TButton;
        ScrollBox: TScrollBox;
        TreePaintBox: TPaintBox;
        TraversalButton: TButton;
        TreeGrid: TStringGrid;
        Procedure DeveloperMenuClick(Sender: TObject);
        Procedure InstructionMenuClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: NativeInt;
          Var CallHelp: Boolean): Boolean;
        Procedure FormDestroy(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure QuitMenuClick(Sender: TObject);
        Procedure TreePaintBoxPaint(Sender: TObject);
        Procedure AddButtonClick(Sender: TObject);
        Procedure DeleteButtonClick(Sender: TObject);
        Procedure DrawGrid(Var ListGrid: TStringGrid);
        Procedure TraversalButtonClick(Sender: TObject);
   

    Private

        { Private declarations }
    Public
        { Public declarations }
    End;

Const
    ERRORS: Array [ERRORS_LIST] Of String = ('', 'Файл закрыт для чтения!',
      'Файл закрыт для записи!', 'Файл пуст!', 'Неверное число строк в файле',
      'Неверное имя пользователя!', 'Введён неверный номер!');
    DIGITS = ['0' .. '9'];
    NO_ZERO_DIGITS = ['1' .. '9'];
    BACKSPACE = #8;
    NONE = #0;
    MIN_N = 1;
    MAX_N = 100;
    MIN_X = -100;
    MAX_X = 100;
    MAX_SIGNS = 4;
    LINES = 2;
    ALPHABET = ['A' .. 'Z', 'a' .. 'z'];

Var
    MainTaskForm: TMainTaskForm;
    IsEdited: Boolean = False;
    Saved: Boolean = True;
    BinaryTree: TTree;

Implementation

{$R *.dfm}

Procedure ClearGrid(Grid: TStringGrid);
Var
    I: Integer;
Begin
    For I := 1 To Grid.ColCount Do
    Begin
        Grid.Cells[0, I] := '';
        Grid.Cells[1, I] := '';
    End;
    Grid.RowCount := 1;
    Grid.Visible := False;
End;

Procedure TMainTaskForm.AddButtonClick(Sender: TObject);
Var
    AddLeafForm: TAddLeafForm;
Begin
    AddLeafForm := TAddLeafForm.Create(Self);
    AddLeafForm.ShowModal;
    AddLeafForm.Free;
    ClearGrid(TreeGrid);
End;

Procedure TMainTaskForm.DeleteButtonClick(Sender: TObject);
Var
    DeleteLeafForm: TDeleteLeafForm;
Begin
    DeleteLeafForm := TDeleteLeafForm.Create(Self);
    DeleteLeafForm.ShowModal;
    DeleteLeafForm.Free;
End;

Procedure TMainTaskForm.DeveloperMenuClick(Sender: TObject);
Var
    DeveloperForm: TDeveloperForm;
Begin
    DeveloperForm := TDeveloperForm.Create(Self);
    DeveloperForm.ShowModal;
    DeveloperForm.Free;
End;

Procedure TMainTaskForm.FormDestroy(Sender: TObject);
Begin
    Clear(BinaryTree)
End;

Function TMainTaskForm.FormHelp(Command: Word; Data: NativeInt;
  Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    InstructionMenuClick(Self)
End;

Procedure TMainTaskForm.InstructionMenuClick(Sender: TObject);
Var
    InstructionForm: TInstructionForm;
Begin
    InstructionForm := TInstructionForm.Create(Self);
    InstructionForm.ShowModal;
    InstructionForm.Free;
End;

Procedure TMainTaskForm.QuitMenuClick(Sender: TObject);
Begin
    Close;
End;

Procedure TMainTaskForm.DrawGrid(Var ListGrid: TStringGrid);
Begin
    ListGrid.ColCount := 1;
    ListGrid.ColWidths[0] := ListGrid.DefaultColWidth;

    If ListGrid.RowCount > 7 Then
    Begin
        ListGrid.ScrollBars := TScrollStyle.SsVertical;
        ListGrid.Height := 250;
        ListGrid.RowCount := ListGrid.RowCount - 1;
        
    End
    Else
    Begin
        ListGrid.ScrollBars := TScrollStyle.SsNone;
        ListGrid.Height := (ListGrid.DefaultRowHeight) *
          (ListGrid.RowCount - 1);
    End;
    ListGrid.Width := ListGrid.DefaultColWidth * 1;
    ListGrid.Visible := True;
End;

Procedure TMainTaskForm.TraversalButtonClick(Sender: TObject);
Var
    RowCount: Integer;
Begin
    RowCount := 0;
    ClearGrid(TreeGrid);

    TraversalTree(BinaryTree, TreeGrid, RowCount);
    DrawGrid(TreeGrid);
End;



Procedure TMainTaskForm.TreePaintBoxPaint(Sender: TObject);
Begin
    Draw(BinaryTree, TreePaintBox);
    ClearGrid(TreeGrid);
End;

Procedure TMainTaskForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
    Confirmation: Integer;
Begin
    Confirmation := Application.MessageBox('Вы действительно хотите выйти?',
      'Выход', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2);
    CanClose := Confirmation = IDYES;
End;

End.
