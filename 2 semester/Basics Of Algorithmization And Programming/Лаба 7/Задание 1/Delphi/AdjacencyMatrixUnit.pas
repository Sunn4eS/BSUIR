Unit AdjacencyMatrixUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids,
    VertexListUnit, EdgeListUnit;

Type
    TAdjacencyMatrixForm = Class(TForm)
        AdjacencyMatrixStringGrid: TStringGrid;

        Procedure CreateParams(Var Params: TCreateParams); Override;
        Function FormHelp(Command: Word; Data: NativeInt; Var CallHelp: Boolean): Boolean;
        Procedure FormShow(Sender: TObject);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    AdjacencyMatrixForm: TAdjacencyMatrixForm;

Implementation

{$R *.dfm}

Uses
    MenuUnit;

Procedure TAdjacencyMatrixForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Function TAdjacencyMatrixForm.FormHelp(Command: Word; Data: NativeInt; Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    Result := False;
End;

Procedure TAdjacencyMatrixForm.FormShow(Sender: TObject);
Var
    CurrVertex: PVertex;
    CurrEdge: PEdge;
    I, J: Integer;
Begin
    AdjacencyMatrixStringGrid.ColCount := Graph.Count + 1;
    AdjacencyMatrixStringGrid.RowCount := Graph.Count + 1;
    CurrVertex := Graph.Head;
    I := 1;
    While CurrVertex <> Nil Do
    Begin
        AdjacencyMatrixStringGrid.Cells[0, I] := IntToStr(CurrVertex.Value);
        AdjacencyMatrixStringGrid.Cells[I, 0] := IntToStr(CurrVertex.Value);
        CurrVertex := CurrVertex^.Next;
        Inc(I);
    End;

    CurrVertex := Graph.Head;
    I := 1;
    While CurrVertex <> Nil Do
    Begin
        CurrEdge := CurrVertex^.Edges.Head;
        J := 1;
        While J <> AdjacencyMatrixStringGrid.ColCount Do
        Begin
            If (CurrEdge <> Nil) And
                (IntToStr(CurrEdge^.Value) = AdjacencyMatrixStringGrid.Cells
                    [J, 0]) Then
            Begin
                AdjacencyMatrixStringGrid.Cells[J, I] := '1';
                CurrEdge := CurrEdge^.Next;
            End
            Else
                AdjacencyMatrixStringGrid.Cells[J, I] := '0';
            Inc(J);
        End;
        CurrVertex := CurrVertex^.Next;
        Inc(I);
    End;
End;

Procedure TAdjacencyMatrixForm.FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
Begin
    If Key = VK_ESCAPE Then
        Close;
End;

End.
