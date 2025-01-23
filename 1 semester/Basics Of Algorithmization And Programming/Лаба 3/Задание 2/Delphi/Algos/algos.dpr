program algos;

 // ћаксимальное число дл€ поиска простых чисел
  Const MaxNumber = 255;

procedure Sieve(num: Integer);
Var
  Numbers: set of 2..maxNumber;
  Prime: Integer;
begin
  Numbers := [2..Num]; // »нициализируем множество числами от 2 до MaxNumber

  Prime := 2;
  while Prime * Prime < Num do // ѕровер€ем числа до корн€ из MaxNumber
  begin
    if Prime in Numbers then
    begin
      // ”дал€ем все числа, кратные текущему простому числу
      for var i := 2 * Prime to Num do
        if i mod Prime = 0 then
          Exclude(Numbers, i);
    end;
    Inc(Prime);
  end;

  // ¬ыводим все найденные простые числа
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
