


Program Project6;

{$APPTYPE CONSOLE}
{$R *.res}

Uses
    System.SysUtils;

Type
    TTimeArr = Array Of Integer;
    TVaveyko = 19 .. 20;

    TClient = Class
    Public
        Constructor Create(Arr: TTimeArr; Priority: Integer);
        Function IsInEnterState(): Boolean;
    Private
        Priority, EnterTime, CurrInd: Integer;
        TaskArr: TTimeArr;
    End;

    // кол-во человек
    TClientArr = Array [0 .. 5] Of TClient;

    PQueueElem = ^TQueueElem;

    TQueueElem = Record
        Data: TClient;
        Next, Prev: PQueueElem;
    End;

    TQueue = Class
    Public
        Constructor Create();
        Procedure Add(Var Elem: TClient);
        Function Get(): TClient;
        Function IsEmpty(): Boolean;
    Private
        Head, Tail: PQueueElem;
    End;

    { TClient }

Constructor TClient.Create(Arr: TTimeArr; Priority: Integer);
Begin
    Self.TaskArr := Arr;
    Self.Priority := Priority;
    Self.EnterTime := 0;
    CurrInd := 0;
End;

Function TClient.IsInEnterState: Boolean;
Begin
    IsInEnterState := Self.EnterTime > 0;
End;

{ TQeue }

Constructor TQueue.Create;
Begin
    Self.Head := Nil;
    Self.Tail := Nil;
End;

Procedure TQueue.Add(Var Elem: TClient);
Var
    PElem, Buff: PQueueElem;
Begin
    New(PElem);
    PElem^.Data := Elem;
    PElem^.Next := Nil;
    PElem^.Prev := Nil;
    If (Head = Nil) Then
    Begin
        Head := PElem;
        Tail := Head;
    End
    Else
    Begin
        Buff := Tail;
        While ((Buff <> Nil) And (Buff^.Data.Priority > Elem.Priority)) Do
            Buff := Buff^.Next;

        If (Buff = Nil) Then
        Begin
            PElem^.Prev := Head;
            Head^.Next := PElem;
            Head := PElem;
        End
        Else
        Begin
            PElem^.Prev := Buff^.Prev;
            PElem^.Next := Buff;
            Buff^.Prev := PElem;
            If (PElem^.Prev <> Nil) Then
                PElem^.Prev^.Next := PElem;
            While (Tail^.Prev <> Nil) Do
                Tail := Tail^.Prev;
        End;
    End;
End;

Function TQueue.Get(): TClient;
Var
    Buff: PQueueElem;
Begin
    If ((Head <> Nil) And (Head^.Data.IsInEnterState)) Then
    Begin
        Buff := Head^.Prev;
        While ((Buff <> Nil) And (Buff^.Data.IsInEnterState)) Do
            Buff := Buff^.Prev;
        If (Buff <> Nil) Then
        Begin
            Buff^.Next^.Prev := Buff^.Prev;
            If (Buff^.Prev <> Nil) Then
                Buff^.Prev^.Next := Buff^.Next
            Else
                Tail := Buff^.Next;
        End;
    End
    Else
    Begin
        Buff := Head;
        If (Head <> Nil) Then
        Begin
            Head := Head^.Prev;
            If (Head <> Nil) Then
                Head^.Next := Nil;
        End;
    End;
    If Buff <> Nil Then
        Get := Buff^.Data
    Else
        Get := Nil;
End;

Function TQueue.IsEmpty: Boolean;
Begin
    IsEmpty := Head = Nil;
End;

Function Tick(Var Arr: TClientArr; Var Que: TQueue;
  CurrTickTime, CurrEnterTime: Integer): Integer;
Var
    CurrClient: TClient;
    UselesTick, I: Integer;
Begin
    UselesTick := 0;
    CurrClient := Que.Get();
    If CurrClient <> Nil Then
    Begin
        With CurrClient Do
        Begin
            TaskArr[CurrInd] := TaskArr[CurrInd] - CurrTickTime;
            If (TaskArr[CurrInd] <= 0) Then
            Begin
                UselesTick := (-1) * TaskArr[CurrInd];

                EnterTime := CurrEnterTime;
                EnterTime := EnterTime - UselesTick;
                Inc(CurrInd);
            End;
            If (CurrInd < Length(TaskArr)) Then
            Begin
                Que.Add(CurrClient);
            End;
        End;
    End
    Else
        UselesTick := CurrTickTime;

    For I := Low(Arr) To High(Arr) Do
    Begin
        If (Arr[I] <> CurrClient) And (Arr[I].IsInEnterState) Then
            Arr[I].EnterTime := Arr[I].EnterTime - CurrTickTime;
    End;

    Tick := UselesTick;
End;

Function Emulate(TickCount, EnterTime: Integer;
  Var TotalUselesTick: Integer): Integer;
Var
    Que: TQueue;
    Tacts, I: Integer;
    ClientArr: TClientArr;
Const
    Arr1: TTimeArr = [6, 4, 3, 4, 5, 8, 5, 9, 7];
    Arr2: TTimeArr = [3, 2, 1, 6, 8, 9, 7, 4, 3, 1];
    Arr3: TTimeArr = [2, 1, 2, 3, 1, 6, 1, 8, 9, 7];
    Arr4: TTimeArr = [5, 3, 5, 6, 6, 7, 8, 2, 1, 8];
    Arr5: TTimeArr = [5, 4, 3, 2, 1, 8, 7, 6, 3, 2, 1];
    Arr6: TTimeArr = [5, 9, 3, 1, 2, 9, 7, 6, 4, 2, 1];
Begin
    TotalUselesTick := 0;
    Tacts := 0;
    ClientArr[0] := TClient.Create(Arr1, 1);
    ClientArr[1] := TClient.Create(Arr2, 2);
    ClientArr[2] := TClient.Create(Arr3, 2);
    ClientArr[3] := TClient.Create(Arr4, 2);
    ClientArr[4] := TClient.Create(Arr5, 3);
    ClientArr[5] := TClient.Create(Arr5, 3);
    Que := TQueue.Create();
    For I := Low(ClientArr) To High(ClientArr) Do
        Que.Add(ClientArr[I]);

    While (Not Que.IsEmpty) Do
    Begin
        Inc(Tacts);
        TotalUselesTick := TotalUselesTick + Tick(ClientArr, Que, TickCount,
          EnterTime);
    End;
    Emulate := Tacts;
End;

Var
    TickCount, EnterTime, CurrTacts, CurrUseles, I: Integer;

Begin
    Write('|':5);
    For EnterTime := 0 To 10 Do
    Begin
        Write(EnterTime:2, '|':10);
    End;
    Writeln;
    For TickCount := 1 To 10 Do
    Begin
        Write(TickCount:2, '|':2);
        For EnterTime := 0 To 10 Do
        Begin
            CurrTacts := Emulate(TickCount, EnterTime, CurrUseles);
            Write(CurrUseles:3, '':1,((CurrTacts * TickCount - CurrUseles) / ((CurrTacts * TickCount)) * 100) :1 :3, '%|':1);
        End;
        Writeln;
        Writeln;
    End;
    Readln;

End.
