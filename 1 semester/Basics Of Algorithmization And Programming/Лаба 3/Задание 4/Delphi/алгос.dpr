program алгос;

uses
  SysUtils;

function DecmalToHex(decimalNumber: Integer): string;
var
  hexNumber: string;
  remainder: Integer;
begin
  hexNumber := '';

  while decimalNumber > 0 do
  begin
    remainder := decimalNumber mod 16;

    case remainder of
      0..9:
        hexNumber := IntToStr(remainder) + hexNumber;
      10:
        hexNumber := 'A' + hexNumber;
      11:
        hexNumber := 'B' + hexNumber;
      12:
        hexNumber := 'C' + hexNumber;
      13:
        hexNumber := 'D' + hexNumber;
      14:
        hexNumber := 'E' + hexNumber;
      15:
        hexNumber := 'F' + hexNumber;
    end;

    decimalNumber := decimalNumber div 16;
  end;

  Result := hexNumber;
end;

var
  decimalNumber: Integer;
  hexNumber: string;
begin
  decimalNumber := 999999984; // замените на нужное десятичное число

  hexNumber := DecmalToHex(decimalNumber);

  WriteLn(hexNumber);
  Readln;
end.
