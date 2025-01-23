Unit WaysUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, VertexListUnit,
    Vcl.ExtCtrls, System.Math;

Type
    TWayForm = Class(TForm)
        WaysGrid: TStringGrid;
        PaintBox: TPaintBox;
        Procedure FormShow(Sender: TObject);
        Procedure FormInit(Graph: TVertexList; Value: Integer);
        Procedure PaintBoxPaint(Sender: TObject);
        Procedure WaysGridSelectCell(Sender: TObject; ACol, ARow: Integer;
          Var CanSelect: Boolean);
    Private
        Graph: TVertexList;
        Value: Integer;
    Public
        { Public declarations }
    End;

Var
    WayForm: TWayForm;

Implementation

{$R *.dfm}

Procedure Clear(Grid: TStringGrid);
Var
    I: Integer;
    J: Integer;
Begin
    For I := 0 To Grid.ColCount Do
        For J := 0 To Grid.RowCount Do
            Grid.Cells[I, J] := '';
    Grid.ColCount := 0;
    Grid.RowCount := 0;
End;

Procedure TWayForm.FormInit(Graph: TVertexList; Value: Integer);
Begin
    Self.Graph := Graph;
    Self.Value := Value;
End;

Procedure TWayForm.FormShow(Sender: TObject);
Var
    WayArr: TWayArr;
    Vertex: PVertex;
    I, Ind: Integer;
Begin
    WayArr := Graph.FindWay(Value);
    Clear(WaysGrid);
    With WaysGrid Do
    Begin
        Ind := 0;
        ColCount := 3;
        RowCount := Graph.Count - 1;
        Vertex := Graph.Head;
        For I := 0 To RowCount - 1 Do
        Begin
            Cells[0, I] := IntToStr(Value) + ':';
            //Cells[1, I] := '-->';
            If Value = Vertex^.Value Then
            Begin
                Vertex := Vertex.Next;
                Inc(Ind);
            End;
            Cells[1, I] := IntTostr(Vertex^.Value);
            If WayArr[Ind] = INF Then
                Cells[2, I] := 'Нет'
            Else
                Cells[2, I] := IntToStr(WayArr[Ind]);
            Inc(Ind);
            Vertex := Vertex.Next;
        End;
    End;
End;

Procedure TWayForm.PaintBoxPaint(Sender: TObject);
Var
    CenterX, CenterY, Distance: Integer;
    RotateAngle: Real;
Begin
    PaintBox.Canvas.Brush.Color := ClWhite;
    PaintBox.Canvas.FillRect(PaintBox.Canvas.ClipRect);
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

Procedure TWayForm.WaysGridSelectCell(Sender: TObject; ACol, ARow: Integer;
  Var CanSelect: Boolean);
Begin
    PaintBoxPaint(Self);
End;

End.
