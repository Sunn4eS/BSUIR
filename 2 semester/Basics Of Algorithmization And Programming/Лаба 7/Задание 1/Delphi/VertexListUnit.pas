Unit VertexListUnit;

Interface

Uses
    Winapi.Windows,
    System.Classes, Vcl.ExtCtrls, SysUtils,
    EdgeListUnit;

Type
    TValue = Integer;

    PVertex = ^TVertex;

    TVertex = Record
        Value: TValue;
        Edges: TEdgeList;
        Next: PVertex;
    End;

    TValueArray = Array Of Integer;
    TVertArray = Array Of TVertex;
    TWayArr = Array Of Integer;

    TVertexList = Record
        Head: PVertex;
        Count: Integer;

        Procedure Create();
        Procedure Add(Const Value: TValue);
        Procedure DeleteEdges(Const Value: TValue);
        Procedure Delete(Const Value: TValue);
        Function Find(Const Value: TValue): PVertex;
        Procedure Clear();
        Function GetValueArray(): TValueArray;
        Function GetVertexArray(): TVertArray;
        Function FindWay(StartValue: Integer): TWayArr;
    End;

Const
    INF = 2000000000;
    MAX_VERTEX = 32;
    VertexSize = 7;

Procedure DrawVerteces(PaintBox: TPaintBox; Graph: TVertexList;
  Const CenterX, CenterY, Distance: Integer; Const RotateAngle: Real);

Implementation

Procedure DrawEdge(PaintBox: TPaintBox; Const X1, Y1, X2, Y2: Integer);
Var
    TrueVertexSize: Integer;
Begin
    TrueVertexSize := Round(PaintBox.Width * VertexSize / 100);
    With PaintBox.Canvas Do
    Begin
        MoveTo(X1 + TrueVertexSize Div 2, Y1 + TrueVertexSize Div 2);
        LineTo(X2 + TrueVertexSize Div 2, Y2 + TrueVertexSize Div 2);
    End;
End;

Procedure DrawEdges(PaintBox: TPaintBox; Const CenterX, CenterY,
  Distance: Integer; Const RotateAngle: Real; Vertex1: PVertex;
  IndexNode1: Integer);
Var
    CurrNode: PEdge;
    Vertex2: PVertex;
    IndexNode2: Integer;
Begin
    CurrNode := Vertex1^.Edges.Head;
    While CurrNode <> Nil Do
    Begin
        Vertex2 := Vertex1^.Next;
        IndexNode2 := IndexNode1 + 1;
        While (Vertex2 <> Nil) And (Vertex2^.Value <> CurrNode^.Value) Do
        Begin
            Inc(IndexNode2);
            Vertex2 := Vertex2^.Next;
        End;

        If Vertex2 <> Nil Then
            DrawEdge(PaintBox,
              Round(CenterX + Distance * Sin(IndexNode1 * RotateAngle)),
              Round(CenterY - Distance * Cos(IndexNode1 * RotateAngle)),
              Round(CenterX + Distance * Sin(IndexNode2 * RotateAngle)),
              Round(CenterY - Distance * Cos(IndexNode2 * RotateAngle)));
        CurrNode := CurrNode^.Next;
    End;
End;

Procedure DrawVertex(PaintBox: TPaintBox; Const X, Y: Integer;
  Const Text: String);
Var
    TrueVertexSize: Integer;
Begin
    TrueVertexSize := Round(PaintBox.Width * VertexSize / 100);
    With PaintBox.Canvas Do
    Begin
        Ellipse(X, Y, X + TrueVertexSize, Y + TrueVertexSize);
        TextOut(X + (TrueVertexSize - TextWidth(Text)) Div 2,
          Y + (TrueVertexSize - TextHeight(Text)) Div 2, Text);
    End;
End;

Procedure DrawVerteces(PaintBox: TPaintBox; Graph: TVertexList;
  Const CenterX, CenterY, Distance: Integer; Const RotateAngle: Real);
Var
    Angle: Real;
    CurrNode: PVertex;
    IndexNode: Integer;
Begin
    Angle := 0;
    CurrNode := Graph.Head;
    IndexNode := 0;
    While CurrNode <> Nil Do
    Begin
        DrawEdges(PaintBox, CenterX, CenterY, Distance, RotateAngle, CurrNode,
          IndexNode);
        DrawVertex(PaintBox, Round(CenterX + Distance * Sin(Angle)),
          Round(CenterY - Distance * Cos(Angle)), IntToStr(CurrNode^.Value));
        Angle := Angle + RotateAngle;
        CurrNode := CurrNode^.Next;
        Inc(IndexNode);
    End;
End;

Procedure TVertexList.Create();
Begin
    Head := Nil;
    Count := 0;
End;

Function CreateNode(Const Value: TValue): PVertex;
Var
    NewNode: PVertex;
Begin
    New(NewNode);
    NewNode^.Value := Value;
    NewNode^.Edges.Create();
    NewNode^.Next := Nil;
    Result := NewNode;
End;

Procedure TVertexList.Add(Const Value: TValue);
Var
    NewNode, CurrNode: PVertex;
Begin
    NewNode := CreateNode(Value);
    If Head = Nil Then
        Head := NewNode
    Else If Head^.Value > Value Then
    Begin
        NewNode^.Next := Head;
        Head := NewNode;
    End
    Else
    Begin
        CurrNode := Head;
        While (CurrNode^.Next <> Nil) And (CurrNode^.Next^.Value <= Value) Do
            CurrNode := CurrNode^.Next;

        NewNode^.Next := CurrNode^.Next;
        CurrNode^.Next := NewNode;
    End;
    Inc(Count);
End;

Procedure TVertexList.DeleteEdges(Const Value: TValue);
Var
    CurrNode: PVertex;
Begin
    CurrNode := Head;
    While CurrNode <> Nil Do
    Begin
        If CurrNode^.Edges.Find(Value) <> Nil Then
            CurrNode^.Edges.Delete(Value);
        CurrNode := CurrNode^.Next;
    End;
End;

Procedure TVertexList.Delete(Const Value: TValue);
Var
    TempNode, CurrNode: PVertex;
Begin
    If Head^.Value = Value Then
    Begin
        TempNode := Head;
        Head := Head^.Next;
    End
    Else
    Begin
        CurrNode := Head;
        While CurrNode^.Next^.Value <> Value Do
            CurrNode := CurrNode^.Next;

        TempNode := CurrNode^.Next;
        CurrNode^.Next := CurrNode^.Next^.Next;
    End;
    DeleteEdges(TempNode^.Value);
    TempNode^.Edges.Clear();
    Dispose(TempNode);
    Dec(Count);
End;

procedure sdaf(var dsfhj);
begin

end;


Function TVertexList.Find(Const Value: TValue): PVertex;
Var
    CurrNode: PVertex;
Begin
    CurrNode := Head;
    While (CurrNode <> Nil) And (CurrNode^.Value <> Value) Do
        CurrNode := CurrNode^.Next;
    Result := CurrNode;
End;

Function TVertexList.GetValueArray: TValueArray;
Var
    Arr: TValueArray;
    Vertex: PVertex;
    I: Integer;
Begin
    Vertex := Self.Head;
    SetLength(Arr, Self.Count);
    I := 0;
    While (Vertex <> Nil) Do
    Begin
        Arr[I] := Vertex.Value;
        Inc(I);
        Vertex := Vertex^.Next;
    End;

    GetValueArray := Arr;
End;

Function TVertexList.GetVertexArray: TVertArray;
Var
    Arr: TVertArray;
    Vertex: PVertex;
    I: Integer;
Begin
    Vertex := Self.Head;
    SetLength(Arr, Self.Count);
    I := 0;
    While (Vertex <> Nil) Do
    Begin
        Arr[I] := Vertex^;
        Inc(I);
        Vertex := Vertex^.Next;
    End;

    GetVertexArray := Arr;
End;

Procedure TVertexList.Clear();
Var
    CurrNode, TempNode: PVertex;
Begin
    CurrNode := Head;
    While CurrNode <> Nil Do
    Begin
        TempNode := CurrNode;
        CurrNode := CurrNode^.Next;
        TempNode^.Edges.Clear();
        Dispose(TempNode);
    End;
    Head := Nil;
    Count := 0;
End;

Function GetIndex(Value: Integer; Arr: TVertArray): Integer;
Var
    Ind: Integer;
    I: Integer;
Begin
    Ind := -1;
    For I := 0 To High(Arr) Do
    Begin
        If Arr[I].Value = Value Then
            Ind := I;
    End;

    GetIndex := Ind;
End;

Function TVertexList.FindWay(StartValue: Integer): TWayArr;
Var
    WayArr: TWayArr;
    VertArr: TVertArray;
    ValueArr: TValueArray;
    Edge: PEdge;
    I, J, Index: Integer;
Begin
    VertArr := Self.GetVertexArray();
    ValueArr := Self.GetValueArray();
    SetLength(WayArr, Self.Count);

    For I := 0 To High(WayArr) Do
    Begin
        If ValueArr[I] = StartValue Then
            WayArr[I] := 0
        Else
            WayArr[I] := INF;
    End;
    For I := 1 To Self.Count - 1 Do
    Begin
        For J := 0 To High(VertArr) Do
        Begin
            Edge := VertArr[J].Edges.Head;
            While (Edge <> Nil) Do
            Begin
                Index := GetIndex(Edge.Value, VertArr);
                If WayArr[Index] + 1 < WayArr[J] Then
                    WayArr[J] := WayArr[Index] + 1;
                Edge := Edge.Next;
            End;
        End;
    End;
    FindWay := WayArr;
End;

End.
