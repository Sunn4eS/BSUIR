Unit GraphLinkedList;

Interface

Uses
    Vcl.Grids, Vcl.Graphics, Vcl.ExtCtrls, System.SysUtils, QueueLinkedList;

Type
    TGraphMatrix = Array Of Array Of Boolean;
    TPathArray = Array Of Boolean;
    TArray = Array Of Integer;

    TTownGraph = ^TGNode;

    TGNode = Record
        Number: Integer;
        Next: TTownGraph;
        X: Integer;
        Y: Integer;
    End;

Const
    DIAMETR = 50;
    RADIUS = 150;
    CENTER_X = 200;
    CENTER_Y = 200;

Procedure DrawTowns(PaintBox: TPaintBox);
Procedure AddTown();
Procedure Make();
Procedure AddLink(StartTown, EndTown: Integer);
Procedure DrawLines(Var PaintBox: TPaintBox);
Procedure ClearGraph();
Function DFS(CurrentCity, Target: Integer): Boolean;
Function FindPathDFS(Start, Target: Integer): TArray;
Procedure DrawPath(Var PaintBox: TPaintBox);

Var
    CountOfTowns: Integer = 1;
    Head, Town: TTownGraph;
    GraphMatrix: TGraphMatrix;
    Visited: TPathArray;

    Path: TArray;

Implementation

Function DFS(CurrentCity, Target: Integer): Boolean;
Var
    NeighborCity, J: Integer;
    Ready: Boolean;
Begin
    Visited[CurrentCity - 1] := True;
    Ready := False;
    SetLength(Path, Length(Path) + 1);
    J := 0;
    Path[Length(Path) - 1] := CurrentCity;

    If CurrentCity = Target Then
        Ready := True
    Else
    Begin
        While (J < Length(GraphMatrix)) And (Not Ready) Do
        Begin
            If GraphMatrix[CurrentCity - 1, J] Then
            Begin
                NeighborCity := J + 1;
                If Not Visited[NeighborCity - 1] Then
                    Ready := DFS(NeighborCity, Target);
            End;
            Inc(J);
        End;
        If Not Ready Then
            SetLength(Path, Length(Path) - 1);
    End;
    DFS := Ready
End;

Function FindPathDFS(Start, Target: Integer): TArray;
Var
    I: Integer;
Begin
    SetLength(Visited, CountOfTowns);
    Path := Nil;
    For I := 0 To CountOfTowns - 1 Do
        Visited[I] := False;
        
    If DFS(Start, Target) Then
        FindPathDFS := Path
    Else
        FindPathDFS := Nil;
End;

Procedure AddLink(StartTown, EndTown: Integer);
Begin
    GraphMatrix[StartTown - 1, EndTown - 1] := True;
    GraphMatrix[EndTown - 1, StartTown - 1] := True;
End;

Procedure Make();
Begin
    New(Head);
    Head.Next := Nil;
    Head.Number := CountOfTowns;
End;

Procedure AddTown();
Var
    I, J: Integer;
Begin
    If Head = Nil Then
        Make()
    Else
    Begin
        Town := Head;
        While Town.Next <> Nil Do
            Town := Town^.Next;
        New(Town.Next);
        Town := Town.Next;
        Inc(CountOfTowns);
        Town.Number := CountOfTowns;
        Town.Next := Nil;
    End;
    SetLength(GraphMatrix, CountOfTowns, CountOfTowns);
    For I := 0 To High(GraphMatrix) Do
        For J := 0 To High(GraphMatrix) Do
            GraphMatrix[I, J] := False;
End;

Procedure DrawTowns(PaintBox: TPaintBox);
Var
    DeltaAngle, Angle: Double;
    I: Integer;
Begin
    Town := Head;
    DeltaAngle := 2 * Pi / CountOfTowns;
    With PaintBox.Canvas Do
    Begin
        For I := 0 To CountOfTowns - 1 Do
        Begin
            Angle := DeltaAngle * I;
            Town.X := Round(CENTER_X + Radius * Cos(Angle));
            Town.Y := Round(CENTER_Y + Radius * Sin(Angle));

            With PaintBox.Canvas Do
            Begin
                Pen.Color := ClBlack;
                Ellipse(Town.X, Town.Y, Town.X + Diametr, Town.Y + Diametr);
                TextOut(Town.X + (Diametr - TextWidth(IntToStr(Town.Number)))
                  Div 2, Town.Y + (Diametr - TextHeight(IntToStr(Town.Number)))
                  Div 2, IntToStr(Town.Number));
            End;
            Town := Town^.Next;
        End;

    End;
End;

Procedure DrawLines(Var PaintBox: TPaintBox);
Var
    I, J: Integer;
    StartT, EndT: Integer;
    StartX, StartY, EndX, EndY: Integer;
Begin
    DrawTowns(PaintBox);
    For I := 0 To High(GraphMatrix) Do
        For J := 0 To High(GraphMatrix) Do
        Begin
            If GraphMatrix[I, J] = True Then
            Begin
                StartT := I + 1;
                EndT := J + 1;

                Town := Head;
                While Town.Number <> StartT Do
                    Town := Town.Next;
                StartX := Town.X;
                StartY := Town.Y;

                Town := Head;
                While Town.Number <> EndT Do
                    Town := Town.Next;
                EndX := Town.X;
                EndY := Town.Y;

                With PaintBox.Canvas Do
                Begin
                    Pen.Color := ClBlack;
                    Pen.Width := 3;
                    MoveTo(StartX + DIAMETR Div 2, StartY + DIAMETR Div 2);
                    LineTo(EndX + DIAMETR Div 2, EndY + DIAMETR Div 2);
                End;

            End;

        End;

    DrawTowns(PaintBox);
End;

Procedure DrawPath(Var PaintBox: TPaintBox);
Var
    I, J: Integer;
    StartT, EndT: Integer;
    StartX, StartY, EndX, EndY: Integer;
Begin
    DrawLines(PaintBox);

    For I := 0 To High(Path) - 1 Do
    Begin
        StartT := Path[I];
        EndT := Path[I + 1];

        Town := Head;
        While Town.Number <> StartT Do
            Town := Town.Next;
        StartX := Town.X;
        StartY := Town.Y;

        Town := Head;
        While Town.Number <> EndT Do
            Town := Town.Next;
        EndX := Town.X;
        EndY := Town.Y;

        With PaintBox.Canvas Do
        Begin
            Pen.Color := ClRed;
            Pen.Width := 3;
            MoveTo(StartX + DIAMETR Div 2, StartY + DIAMETR Div 2);
            LineTo(EndX + DIAMETR Div 2, EndY + DIAMETR Div 2);
        End;

    End;
    DrawTowns(PaintBox);

End;

Procedure ClearGraph();
Var
    Buff: TTownGraph;
Begin
    GraphMatrix := Nil;
    Buff := Head;
    While Buff <> Nil Do
    Begin
        Town := Buff^.Next;
        Dispose(Buff);
        Buff := Town
    End;
    Head := Nil;
    CountOfTowns := 1;
    Visited := Nil;
    Path := Nil;
End;

Exports Make, DrawTowns, AddTown, AddLink, ClearGraph, DFS,
  FindPathDFS, DrawPath;

Begin

End.
