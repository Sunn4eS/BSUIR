Unit EdgeListUnit;

Interface

Type
    TValue = Integer;

    PEdge = ^TEdge;
    TEdge = Record
        Value: TValue;
        Next: PEdge;
    End;

    TEdgeList = Record
        Head: PEdge;

        Procedure Create();
        Procedure Add(Const Value: TValue);
        Procedure Delete(Const Value: TValue);
        Function Find(Const Value: TValue) : PEdge;
        Procedure Clear();
    End;

Implementation

Procedure TEdgeList.Create();
Begin
    Head := Nil;
End;

Function CreateNode(Const Value: TValue) : PEdge;
Var
    NewNode: PEdge;
Begin
    New(NewNode);
    NewNode^.Value := Value;
    NewNode^.Next := Nil;
    Result := NewNode;
End;

Procedure TEdgeList.Add(Const Value: TValue);
Var
    NewNode, CurrNode: PEdge;
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
End;

Procedure TEdgeList.Delete(Const Value: TValue);
Var
    TempNode, CurrNode: PEdge;
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
    Dispose(TempNode);
End;

Function TEdgeList.Find(Const Value: TValue) : PEdge;
Var
    CurrNode: PEdge;
Begin
    CurrNode := Head;
    While (CurrNode <> Nil) And (CurrNode^.Value <> Value) Do
        CurrNode := CurrNode^.Next;
    Result := CurrNode;
End;

Procedure TEdgeList.Clear();
Var
    CurrNode, TempNode: PEdge;
Begin
    CurrNode := Head;
    While CurrNode <> Nil Do
    Begin
        TempNode := CurrNode;
        CurrNode := CurrNode^.Next;
        Dispose(TempNode);
    End;
    Head := Nil;
End;

End.
