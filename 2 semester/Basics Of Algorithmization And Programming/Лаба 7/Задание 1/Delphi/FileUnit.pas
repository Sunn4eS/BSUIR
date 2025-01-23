Unit FileUnit;

Interface

Uses
    VertexListUnit, EdgeListUnit;

Function ReadFileGraph(Var InputFile: TextFile; Var TempGraph: TVertexList) : Boolean;
Procedure WriteFileGraph(Var OutputFile: TextFile; Graph: TVertexList);

Implementation

Uses
    System.SysUtils,
    MenuUnit;

Function ReadFileVerteces(Var InputFile: TextFile; Var TempGraph: TVertexList) : Boolean;
Var
    IsCorrect: Boolean;
    TempString: String;
    Value: TValue;
Begin
    IsCorrect := True;
    ReadLn(InputFile, TempString);
    While IsCorrect And (TempString <> '') Do
    Begin
        IsCorrect := TryStrToInt(TempString, Value) And (TempGraph.Find(Value) = Nil) And (TempGraph.Count < MAX_VERTEX);
        If IsCorrect Then
            TempGraph.Add(Value);
        ReadLn(InputFile, TempString);
    End;
    Result := IsCorrect;
End;

Function ReadFileEdges(Var InputFile: TextFile; Var TempGraph: TVertexList) : Boolean;
Var
    IsCorrect: Boolean;
    Value1, Value2: TValue;
    Vertex1, Vertex2: PVertex;
Begin
    IsCorrect := True;
    Value1 := 0;
    Value2 := 0;
    Vertex1 := Nil;
    Vertex2 := Nil;
    While IsCorrect And Not seekEOF(InputFile) Do
    Begin
        Try
            Read(InputFile, Value1);
            Read(InputFile, Value2);
        Except
            IsCorrect := False;
        End;
        If IsCorrect Then
        Begin
            Vertex1 := TempGraph.Find(Value1);
            Vertex2 := TempGraph.Find(Value2);
        End;
        IsCorrect := (Vertex1 <> Nil) And (Vertex2 <> Nil);
        If IsCorrect And (Vertex1^.Edges.Find(Value2) = Nil) Then
        Begin
            Vertex1^.Edges.Add(Value2);
            Vertex2^.Edges.Add(Value1);
        End;
    End;
    Result := IsCorrect;
End;

Function ReadFileGraph(Var InputFile: TextFile; Var TempGraph: TVertexList) : Boolean;
Var
    IsCorrect: Boolean;
Begin
    Reset(InputFile);
    IsCorrect := ReadFileVerteces(InputFile,  TempGraph);
    If IsCorrect Then
        IsCorrect := ReadFileEdges(InputFile,  TempGraph);
    CloseFile(InputFile);
    Result := IsCorrect;
End;


Procedure WriteFileVerteces(Var OutputFile: TextFile; Graph: TVertexList);
Var
    CurrVertex: PVertex;
Begin
    CurrVertex := Graph.Head;
    While CurrVertex <> Nil Do
    Begin
        WriteLn(OutputFile, CurrVertex^.Value);
        CurrVertex := CurrVertex^.Next;
    End;
    WriteLn(OutputFile);
End;

Procedure WriteFileEdges(Var OutputFile: TextFile; Graph: TVertexList);
Var
    CurrVertex: PVertex;
    CurrEdge: PEdge;
Begin
    CurrVertex := Graph.Head;
    While CurrVertex <> Nil Do
    Begin
        CurrEdge := CurrVertex^.Edges.Head;
        While CurrEdge <> Nil Do
        Begin
            WriteLn(OutputFile, IntToStr(CurrVertex^.Value) + ' ' + IntToStr(CurrEdge^.Value));
            CurrEdge := CurrEdge^.Next;
        End;
        CurrVertex := CurrVertex^.Next;
    End;
End;

Procedure WriteFileGraph(Var OutputFile: TextFile; Graph: TVertexList);
Begin
    ReWrite(OutputFile);
    WriteFileVerteces(OutputFile, Graph);
    WriteFileEdges(OutputFile, Graph);
    CloseFile(OutputFile);
End;

End.
