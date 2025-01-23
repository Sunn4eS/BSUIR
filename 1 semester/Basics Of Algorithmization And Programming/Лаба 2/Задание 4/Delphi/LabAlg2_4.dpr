Program LabAlg2_4;
uses
  System.SysUtils;

Var
    Flag: Boolean;
    N: Integer;
    I: Integer;
    Arr: Array of Integer;
Begin
    Flag := True;
    Write('Input number of elements:');
    Read(N);
    Setlength(Arr, N);

    For I := Low(Arr) To High(Arr) Do
    Begin
        Writeln('Input ', I + 1, ' element: ');
        Readln(Arr[I]);
    End;

    For I := Low(Arr) To (High(Arr) - 1) Do
    Begin
        If Arr[I] < Arr[I + 1] Then
            Flag := False
        Else
            Flag := True;
    End;

    if Flag then
        Writeln('Dont up')
    Else
        Writeln('hui');
    Readln;



End.

