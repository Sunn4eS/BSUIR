Program Lab3_3_Alg;
uses
  System.SysUtils;

Type
    TMatrix = Array of Array of Integer;
    TArr = Array Of Integer;

Procedure SwapMatrixColumns(DiagonalJ: TMatrix; Col1, Col2: Integer);
Var
    I, Temp: Integer;
begin
    For I := 0 To High(DiagonalJ) Do
    Begin
        Temp := DiagonalJ[I][Col1];
        DiagonalJ[I][Col1] := DiagonalJ[I][Col2];
        DiagonalJ[I][Col2] := Temp;
    End;
End;

Function CreateMatrixOfElements (Matrix:TMatrix): TMatrix;
Var
    DiagonalJ: TMatrix;
    I: Integer;
Begin
    Setlength(DiagonalJ, 2, High(Matrix) + 1);
    For I := 0 to High(Matrix) do
    Begin
        DiagonalJ[0][I] := Matrix[I][High(Matrix) - I];
        DiagonalJ[1][I] := I;
    End;
    CreateMatrixOfElements := DiagonalJ;
End;

Function SortDiagonalJ(DiagonalJ: TMatrix): TMatrix;
Var
    J, I, MinInColumn, NumOfColumn: Integer;
Begin
    For J := 0 To Length(DiagonalJ[0]) - 1 Do
    Begin
        I := J + 1;
        MinInColumn := DiagonalJ[0][J];
        NumOfcolumn := J;
        While (I < Length(DiagonalJ[0])) Do
        Begin
            If MinInColumn > DiagonalJ[0][I] Then
            Begin
                MinInColumn := DiagonalJ[0][I];
                NumOfColumn := I;
            End;
            Inc(I);
        End;
        If NumOfColumn <> J Then
        SwapMatrixColumns(DiagonalJ, J, NumOfColumn);
    End;
    SortDiagonalJ := DiagonalJ;
End;

Procedure Create(ResMatrix, Matrix: TMatrix; NewLine, PrevLine: Integer);
Begin
    ResMatrix[PrevLine] := Matrix[NewLine];
End;

Function SortMatrix(Matrix, DiagonalJ: TMatrix; N: Integer): TMatrix;
Var
    ResMatrix,Temp: TMatrix;
    I, J, K, NewLine: Integer;
Begin
    SetLength(ResMatrix, N, N);
    ResMatrix := Copy(Matrix);
    NewLine := 0;
    For I := 0 To Length(DiagonalJ[1]) - 1 Do
    Begin
        NewLine := DiagonalJ[1][I];
        Create(ResMatrix, Matrix, NewLine, I);
        For J := 0 To High(ResMatrix) Do
        Begin
            For K := 0 To High(ResMatrix) Do
                Write(ResMatrix[J][K], ' ');
            Writeln;
        End;
        Writeln;
        Writeln;
    End;
    SortMatrix := ResMatrix;
End;

Function ReadMatrix(Matrix: TMatrix): TMatrix;
Var
    I,J: Integer;
Begin
    for I := 0 to High(Matrix) Do
        for J:= 0 to High(Matrix) Do
        Begin
            Write('Enter Element in line ', I + 1,  ' column ', J + 1, ' = ' );
            Readln(Matrix[I][J]);
        End;
    ReadMatrix := Matrix;
End;

Procedure PrintMatrix(ResMatrix: TMatrix);
Var
     I,J: Integer;
Begin
    I := 0;
    J := 0;
    for I := 0 to High(ResMatrix) Do
        for J:= 0 to High(ResMatrix) Do
        Begin
            Writeln('Element in line ', I + 1,  ' column ', J + 1, ' = ', ResMatrix[I][J]);
        End;
End;

Var
    Matrix, DiagonalJ, ResMatrix: TMatrix;
    N: Integer;
Begin
    Write('Order of Matrix = ');
    Readln(N);
    SetLength(Matrix, N, N);
    Matrix := ReadMatrix(Matrix);

    DiagonalJ := CreateMatrixOfElements(Matrix);
    DiagonalJ := SortDiagonalJ(DiagonalJ);
    ResMatrix := SortMatrix(Matrix, DiagonalJ, N);
    PrintMatrix(ResMatrix);
    Readln;
End.
