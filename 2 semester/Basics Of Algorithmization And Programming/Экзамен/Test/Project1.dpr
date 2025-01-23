Program Project1;

(*
  ≈сть массив записи студентов.  ажда€ запись имеет фамилию, дату, изучаемый 
  €зык. Ќайти студента с самым большим кол-вом €зыков, если одинаковы, вывести 
  любого студента.
*)

(*
  ‘айл:

  5
  1
  1
  1
  1
  1
  2
  2
  2
  2
  3
  3
  3
  4
  4
  4
*)

{$APPTYPE CONSOLE}
{$R *.res}

Type
    TUser = Record
        Name: String;
        Date: Integer;
        Language: String;
    End;

    TArr = Array Of TUser;

Function SearchStudentIndex(Var Arr: TArr): Integer;
Var
    Count, MaxCount, Res, I, J: Integer;
Begin
    Res := 0;
    Count := -1;
    For I := Low(Arr) To High(Arr) Do
    Begin
        Count := 0;
        For J := Low(Arr) To High(Arr) Do
            Inc(Count, Ord(Arr[J].Name = Arr[I].Name));
        If (Count > MaxCount) Then
        Begin
            MaxCount := Count;
            Res := I;
        End;
    End;
    Result := Res;
End;

Var
    Arr: TArr;
    F: TextFile;
    Size, I: Integer;
    StudentIndex: Integer;

Begin
    Assign(F, 'test.txt');
    Reset(F);
    Readln(F, Size);
    SetLength(Arr, Size);
    For I := Low(Arr) To High(Arr) Do
    Begin
        Readln(F, Arr[I].Name);
        Readln(F, Arr[I].Date);
        Readln(F, Arr[I].Language);
    End;
    Close(F);
    StudentIndex := SearchStudentIndex(Arr);
    Write(Arr[StudentIndex].Name);
    Arr := Nil; // по сути и тут нужно в record string очищать, мне лень.
    Readln;

End.
