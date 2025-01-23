program ProjectGPT;

const
  N = 3; // Размерность матрицы

type
  TMatrix = array[1..N, 1..N] of Integer;

procedure SwapRows(var matrix: TMatrix; row1, row2: Integer);
var
  temp: TMatrix;
begin
  temp := matrix;
  matrix[row1] := temp[row2];
  matrix[row2] := temp[row1];
end;

procedure SortRowsBySecondaryDiagonal(var matrix: TMatrix);
var
  i, j, minIndex: Integer;
begin
  for i := 1 to N - 1 do
  begin
    minIndex := i;
    for j := i + 1 to N do
    begin
      if matrix[j, N - j + 1] < matrix[minIndex, N - minIndex + 1] then
        minIndex := j;
    end;
    if minIndex <> i then
      SwapRows(matrix, i, minIndex);
  end;
end;

procedure PrintMatrix(const matrix: TMatrix);
var
  i, j: Integer;
begin
  for i := 1 to N do
  begin
    for j := 1 to N do
      Write(matrix[i, j], ' ');
    Writeln;
  end;
  Writeln;
end;

var
  matrix: TMatrix;

begin
  matrix[1, 1] := 5;
  matrix[1, 2] := 4;
  matrix[1, 3] := 3;
  matrix[2, 1] := 2;
  matrix[2, 2] := 1;
  matrix[2, 3] := 6;
  matrix[3, 1] := 9;
  matrix[3, 2] := 8;
  matrix[3, 3] := 7;

  Writeln('Исходная матрица:');
  PrintMatrix(matrix);

  SortRowsBySecondaryDiagonal(matrix);

  Writeln('Матрица после сортировки по побочной диагонали:');
  PrintMatrix(matrix);
  Readln;
end.
