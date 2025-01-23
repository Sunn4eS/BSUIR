program SpiralSum;

uses
    System.SysUtils;
Type
    TMatrix = Array Of Array Of Integer;

Procedure ReadMatrix(Var Matrix: TMatrix);
var
  I, J, Order: Integer;
begin
  // ¬вод размера матрицы
  Writeln('¬ведите размер матрицы:');
  Readln(Order);

  // —оздание и заполнение матрицы
  SetLength(Matrix, Order);
  for I := 0 to Order - 1 do
  begin
    SetLength(Matrix[I], Order);
    for J := 0 to Order - 1 do
    begin
      Writeln('¬ведите элемент [', I, '][', J, ']:');
      Readln(Matrix[I][J]);
    end;
  end;
End;






Function FindSum(Matrix: TMatrix): Integer;
Var
    I, J, Count, Sum, K: Integer;
begin
    Sum := 0;
    I := 0;
    J := 0;
    Count := High(Matrix) Div 2;
    For K := 0 To Count Do
    Begin
        For J := K To High(Matrix) - K Do
            Sum := Sum + Matrix[K][J];
        For I := K + 1 to High(Matrix) - K Do
            Sum := Sum + Matrix[I][High(Matrix) - K];
        For J := High(Matrix) - K - 1 DownTo K Do
            Sum := Sum + Matrix[High(Matrix) - K][J];
        For I := High(Matrix) - K - 1 DownTo K + 1 Do
            Sum := Sum + Matrix[I][K];
    End;
    FindSum := Sum;
end;






Var
    Sum: Integer;
    Matrix: TMatrix;
Begin
    ReadMatrix(Matrix);
    Sum := FindSum(Matrix);
    Writeln(Sum);
    Readln;
End.
