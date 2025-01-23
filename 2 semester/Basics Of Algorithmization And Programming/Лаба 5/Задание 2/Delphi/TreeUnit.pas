Unit TreeUnit;

Interface

Uses
    Vcl.Grids, Vcl.Graphics, Vcl.ExtCtrls, System.SysUtils;

Type

    TTree = ^TNode;

    TNode = Record
        Data: Integer;
        Left: TTree;
        Right: TTree;
    End;

    ERROR_LIST = (CORRECT, ALREADY_EXIST, NOT_EXIST, OVER_DEPTH);

Const
    MAX_DEPTH = 7;
    Diametr = 50;
    ERRORS: Array [ERROR_LIST] Of String = ('', 'Узел уже добавлен!',
      'Узел не существует', 'Слишком большая глубина!');
    DEGREES_OF_TWO: Array [0 .. 6] Of Integer = (1, 2, 4, 8, 16, 32, 64);

Var
    Depth: Integer = 0;

Procedure MakeTree(Var BinaryTree: TTree; Data: Integer);
Procedure Add(BinaryTree: TTree; Data: Integer; Var Error: ERROR_LIST);
Procedure Delete(BinaryTree: TTree; Data: Integer; Var Error: ERROR_LIST);
Procedure Draw(BinarySearchTree: TTree; PaintBox: TPaintBox);
Procedure Clear(Var BinaryTree: TTree);
Procedure DeleteFirstLeaf(Var BinaryTree: TTree; Var Error: ERROR_LIST);
Procedure TraversalTree(BinaryTree: TTree; StringGrid: TStringGrid;
  Var RowCount: Integer);

Implementation

Procedure MakeTree(Var BinaryTree: TTree; Data: Integer);
Begin
    New(BinaryTree);
    BinaryTree.Left := Nil;
    BinaryTree.Right := Nil;
    BinaryTree.Data := Data;
    Depth := 1;
End;

Procedure TraversalTree(BinaryTree: TTree; StringGrid: TStringGrid;
  Var RowCount: Integer);
Begin
    If BinaryTree <> Nil Then
    Begin
        TraversalTree(BinaryTree.Left, StringGrid, RowCount);
        StringGrid.Cells[0, RowCount] := IntToStr(BinaryTree.Data);
        Inc(RowCount);
        StringGrid.RowCount := StringGrid.RowCount + 1;
        TraversalTree(BinaryTree.Right, StringGrid, RowCount);
    End;
End;

Function FindLeaf(BinaryTree: TTree; Data: Integer): TTree;
Begin
    If (BinaryTree = Nil) Or (BinaryTree.Data = Data) Then
        FindLeaf := BinaryTree
    Else If Data < BinaryTree.Data Then
        FindLeaf := FindLeaf(BinaryTree.Left, Data)
    Else
        FindLeaf := FindLeaf(BinaryTree.Right, Data);
End;

Function FindDepth(BinaryTree: TTree): Integer;
Var
    LeftBranchDepth, RightBranchDepth: Integer;
Begin
    If BinaryTree = Nil Then
        FindDepth := 0
    Else
    Begin
        LeftBranchDepth := FindDepth(BinaryTree.Left);
        RightBranchDepth := FindDepth(BinaryTree.Right);
        If LeftBranchDepth > RightBranchDepth Then
            FindDepth := LeftBranchDepth + 1
        Else
            FindDepth := RightBranchDepth + 1;
    End;
End;

Procedure AddLeaf(BinaryTree: TTree; Data: Integer);
Begin
    If (BinaryTree.Left = Nil) And (BinaryTree.Data > Data) Or
      (BinaryTree.Right = Nil) And (BinaryTree.Data < Data) Then
    Begin
        If (BinaryTree.Data > Data) Then
        Begin
            New(BinaryTree.Left);
            BinaryTree := BinaryTree.Left;
        End
        Else
        Begin
            New(BinaryTree.Right);
            BinaryTree := BinaryTree.Right;
        End;
        BinaryTree.Data := Data;
        BinaryTree.Right := Nil;
        BinaryTree.Left := Nil;
    End
    Else 
        If BinaryTree.Data > Data Then
            AddLeaf(BinaryTree.Left, Data)
        Else
            AddLeaf(BinaryTree.Right, Data)
End;

Function FindMinLeaf(BinaryTree: TTree): TTree;
Begin
    While (BinaryTree.Left <> Nil) Do
        BinaryTree := BinaryTree.Left;
    FindMinLeaf := BinaryTree;

End;

Function DeleteLeaf(BinaryTree: TTree; Data: Integer): TTree;
Begin
    If BinaryTree <> Nil Then
    Begin
        If Data < BinaryTree.Data Then
            BinaryTree.Left := DeleteLeaf(BinaryTree.Left, Data)
        Else
        Begin 
            If Data > BinaryTree.Data Then
                BinaryTree.Right := DeleteLeaf(BinaryTree.Right, Data)
            Else
            Begin 
                If (BinaryTree.Left <> Nil) And (BinaryTree.Right <> Nil) Then
                Begin
                    BinaryTree.Data := FindMinLeaf(BinaryTree.Right).Data;
                    BinaryTree.Right := DeleteLeaf(BinaryTree.Right, BinaryTree.Data);
                End
                Else
                Begin
                    If BinaryTree.Left <> Nil Then
                        BinaryTree := BinaryTree.Left
                    Else
                    Begin 
                        If BinaryTree.Right <> Nil Then
                            BinaryTree := BinaryTree.Right
                        Else
                            BinaryTree := Nil;
                    End;
                End;
            End;
        End;
    End;
    DeleteLeaf := BinaryTree
End;

Procedure DeleteFirstLeaf(Var BinaryTree: TTree; Var Error: ERROR_LIST);
Begin
    Error := CORRECT;
    If BinaryTree = Nil Then
        Error := NOT_EXIST
    Else
    Begin
        If (BinaryTree.Left <> Nil) And (BinaryTree.Right <> Nil) Then
        Begin
            BinaryTree.Data := FindMinLeaf(BinaryTree.Right).Data;
            BinaryTree.Right := DeleteLeaf(BinaryTree.Right, BinaryTree.Data);
        End
        Else
        Begin
            If BinaryTree.Left <> Nil Then
                BinaryTree := BinaryTree.Left
            Else If BinaryTree.Right <> Nil Then
                BinaryTree := BinaryTree.Right
            Else
                BinaryTree := Nil;
        End;
        Depth := FindDepth(BinaryTree);
    End;
End;

Procedure Delete(BinaryTree: TTree; Data: Integer; Var Error: ERROR_LIST);
Begin
    Error := CORRECT;
    If BinaryTree = Nil Then
        Error := NOT_EXIST
    Else
    Begin
        If FindLeaf(BinaryTree, Data) = Nil Then
            Error := NOT_EXIST
        Else
        Begin
            DeleteLeaf(BinaryTree, Data);
            Depth := FindDepth(BinaryTree)
        End;
    End;
End;

Procedure Add(BinaryTree: TTree; Data: Integer; Var Error: ERROR_LIST);
Begin
    Error := CORRECT;
    If FindLeaf(BinaryTree, Data) = Nil Then
    Begin
        AddLeaf(BinaryTree, Data);
        Depth := FindDepth(BinaryTree);
        If Depth > MAX_DEPTH Then
        Begin
            Delete(BinaryTree, Data, Error);
            Error := OVER_DEPTH;
        End;

    End
    Else
        Error := ALREADY_EXIST;
End;

Procedure Clear(Var BinaryTree: TTree);
Begin
    If BinaryTree <> Nil Then
    Begin
        Clear(BinaryTree.Left);
        Clear(BinaryTree.Right);
        BinaryTree := Nil;
        Dispose(BinaryTree);
    End;
End;

Procedure DrawBinarySearchTree(BinarySearchTree: TTree; PaintBox: TPaintBox;
  X, Y, Depth: Integer);
Var
    Offset: Integer;
Begin
    If BinarySearchTree <> Nil Then
    Begin
        With PaintBox.Canvas Do
        Begin
            Dec(Depth);
            Offset := 0;
            If Depth <> 0 Then
                Offset := DEGREES_OF_TWO[Depth - 1] * Diametr;
            If BinarySearchTree.Left <> Nil Then
            Begin
                MoveTo(X + Diametr Div 2, Y + Diametr Div 2);
                LineTo(X - Offset + Diametr Div 2,
                  Y + Diametr + Diametr Div 2 + 20);
            End;
            If BinarySearchTree.Right <> Nil Then
            Begin
                MoveTo(X + Diametr Div 2, Y + Diametr Div 2);
                LineTo(X + Offset + Diametr Div 2,
                  Y + Diametr + Diametr Div 2 + 20);
            End;
            Ellipse(X, Y, X + Diametr, Y + Diametr);
            TextOut(X + (Diametr - TextWidth(IntToStr(BinarySearchTree.Data)))
              Div 2, Y + (Diametr - TextHeight(IntToStr(BinarySearchTree.Data)))
              Div 2, IntToStr(BinarySearchTree.Data));
            Inc(Y, Diametr + 20);
            DrawBinarySearchTree(BinarySearchTree.Left, PaintBox, X - Offset,
              Y, Depth);
            DrawBinarySearchTree(BinarySearchTree.Right, PaintBox, X + Offset,
              Y, Depth);
        End;
    End;
End;

Procedure Draw(BinarySearchTree: TTree; PaintBox: TPaintBox);
Var
    XRoot, YRoot: Integer;
Begin
    With PaintBox.Canvas Do
    Begin
        Pen.Color := ClBlack;
        FillRect(ClipRect);
        XRoot := 0;
        If Depth <> 0 Then
            XRoot := (DEGREES_OF_TWO[Depth - 1] - 1) * Diametr;
        YRoot := 0;
        PaintBox.Width := 2 * XRoot + Diametr + 20;
        PaintBox.Height := (Depth + 20) * Diametr + 20;
        DrawBinarySearchTree(BinarySearchTree, PaintBox, XRoot, YRoot, Depth);
    End;
End;

Exports MakeTree;
Begin

End.
