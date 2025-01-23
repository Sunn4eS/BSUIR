
Function FindLastOccurrence(st1, st2: string): Integer;
var
  LengthOfSecond, j, k, Place: Integer;
  found: Boolean;
begin
    Place := 0;
  If Length(st1) < Length(st2) then
  Begin
    LengthOfSecond := Length(st2);
    While (LengthOfSecond >= 1) and (Place = 0) do
    Begin
      If st2[LengthOfSecond] = st1[Length(st1)] then
      begin
        found := True;
        j := LengthOfSecond;
        k := Length(st1);
        while (j >= 1) and (k >= 1) and (st2[j] = st1[k]) do
        begin
          Dec(j);
          Dec(k);
        end;
        if k <> 0 then
          found := False;
        if found then
          Place := j + 1;
      end;
      Dec(LengthOfSecond);
    end;
  end
  Else
    Place := 0;
    FindLastOccurrence := Place;
end;

// Пример использования
var
  st1, st2: string;
  lastOccurrence: Integer;
begin
  st1 := 'ab';
  st2 := 'abjfdljgd';
  lastOccurrence := FindLastOccurrence(st1, st2);
  WriteLn(lastOccurrence);
  Readln;
end.

