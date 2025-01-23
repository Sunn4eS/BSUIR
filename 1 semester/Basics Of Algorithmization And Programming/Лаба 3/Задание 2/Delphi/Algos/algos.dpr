program algos;

 // ������������ ����� ��� ������ ������� �����
  Const MaxNumber = 255;

procedure Sieve(num: Integer);
Var
  Numbers: set of 2..maxNumber;
  Prime: Integer;
begin
  Numbers := [2..Num]; // �������������� ��������� ������� �� 2 �� MaxNumber

  Prime := 2;
  while Prime * Prime < Num do // ��������� ����� �� ����� �� MaxNumber
  begin
    if Prime in Numbers then
    begin
      // ������� ��� �����, ������� �������� �������� �����
      for var i := 2 * Prime to Num do
        if i mod Prime = 0 then
          Exclude(Numbers, i);
    end;
    Inc(Prime);
  end;

  // ������� ��� ��������� ������� �����
  for Prime in Numbers do
    WriteLn(Prime);
end;
var
    Num: Integer;

begin
    Readln(Num);
    Sieve(num);
    readln;
end.
