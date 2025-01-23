program DeleteWords;

uses
  System.SysUtils;
Var
    F: TextFile;
    WF: TextFile;
    Num, I, Count: Integer;
    PathToInFile, PathToOutFile: String;
    Words, Check: String;

begin
    Count := 0;
    I := 0;
    PathToInFile := 'C:\Users\User\Desktop\Текстовый документ.txt';
    PathToOutFile := 'C:\Users\User\Desktop\NewWordsRus.txt';
    AssignFile(F, PathToInFile);
    AssignFile(WF, PathToOutFile);
    Reset(F);
    ReWrite(WF);
    while Not EOF(F) Do
    Begin
        Readln(F, Words);
        Check := Words;
        while Not EOF(F) do
        Begin
            Readln(F, Words);
            if Words <> Check then
                Writeln(WF, Words);
        End;
    End;
    closeFile(f);
    CloseFile(WF);
end.
