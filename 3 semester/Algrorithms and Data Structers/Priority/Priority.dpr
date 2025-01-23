PROGRAM Priority;

{$APPTYPE CONSOLE}
{$R *.res}

USES
    SYSTEM.SYSUTILS;

Type
    PQueue = ^TNode;

    TNode = Record

        Value: Integer;
        Next: PQueue;
        Ring: Integer;

    End;
    TState = (Wait, Proc, Enter);

Var
    PriorityArray: Array [0 .. 5] Of PQueue;
    StateArr: Array [0..5] Of TState = (Wait, Wait, Wait, Wait, Wait, Wait);

Procedure Enqueue(Value: Integer; Priority: Integer; Ring: Integer);
Var
    NewNode: PQueue;
Begin
    If (Priority < 0) Or (Priority > 5) Then
        Raise Exception.Create('Некорректный приоритет');

    New(NewNode);
    NewNode^.Value := Value;
    NewNode^.Ring := Ring;
    NewNode^.Next := PriorityArray[Priority];
    PriorityArray[Priority] := NewNode;

End;
(*
  Procedure Enqueue(Value: Integer; Priority: Integer);
  Var
  NewNode: PQueue;
  CurrNode, PrevNode: PQueue;
  Begin
  New(NewNode);
  NewNode^.Value := Value;

  NewNode^.Next := Nil;
  If (Head = Nil) Or (Priority > Head^.Priority) Then
  Begin
  NewNode^.Next := Head;
  Head := NewNode;
  End
  Else
  Begin
  CurrNode := Head;
  PrevNode := Nil;

  // Найдем позицию для вставки
  While (CurrNode <> Nil) And (CurrNode^.Priority >= Priority) Do
  Begin
  PrevNode := CurrNode;
  CurrNode := CurrNode^.Next;
  End;

  // Вставляем новый узел
  NewNode^.Next := CurrNode;
  If PrevNode <> Nil Then
  PrevNode^.Next := NewNode;
  End;
  End;
*)

(*
Function Dequeue: Integer;
Var
    Temp: PQueue;
Begin
    If Head = Nil Then
        Writeln('Очередь пуста')
    Else
    Begin
        Dequeue := Head^.Value;
        Temp := Head;
        Head := Head^.Next;
        Dispose(Temp);
    End;
End;
*)

function Dequeue(Priority: Integer): Integer;
var
  Res: Integer;
  Temp: PQueue;
begin
    if PriorityArray[Priority] <> nil then
    begin
      Res := PriorityArray[Priority]^.Value;
      Temp := PriorityArray[Priority];
      PriorityArray[Priority] := PriorityArray[Priority]^.Next;
      Dispose(Temp);
      Result := Res;
    end;
end;

Procedure InputFunc(Var TickTime, EnterTime: Integer);
Const
    FirstQueue: Array [0 .. 8] Of Integer = (6, 4, 3, 4, 6, 8, 5, 9, 7);
    SecondQueue: Array [0 .. 9] Of Integer = (3, 2, 1, 6, 8, 9, 7, 4, 3, 1);
    ThirdQueue: Array [0 .. 9] Of Integer = (2, 1, 2, 3, 1, 6, 1, 8, 9, 7);
    FourthQueue: Array [0 .. 9] Of Integer = (5, 3, 5, 6, 6, 7, 8, 2, 1, 8);
    FifthQueue: Array [0 .. 10] Of Integer = (5, 4, 3, 2, 1, 8, 7, 6, 3, 2, 1);
    SixthQueue: Array [0 .. 10] Of Integer = (5, 9, 3, 1, 2, 9, 7, 6, 4, 2, 1);

Var
    IsEnd: Boolean;
    Choose: Integer;
    Prior: Integer;
    Value: Integer;
    Ring: Integer;



Begin
    IsEnd := True;
    While IsEnd Do
    Begin
        Writeln;
        Writeln('Выберите действие: ');
        Writeln('1. Новый элемент очереди');
        Writeln('2. Данные задачи');
        Writeln('3. Закончить');
        Readln(Choose);
        If Choose = 1 Then
        Begin
            Write('Введите номер: ');
            Readln(Prior);

            Write('Введите Значение: ');
            Readln(Value);
            Write('Введите уровень: ');
            Readln(Ring);

            Enqueue(Value, Prior, Ring);
        End
        Else
        Begin
            If Choose = 3 Then
                IsEnd := False
            Else
            Begin
                For Var I := 0 To 5 Do
                Begin
                    Case I Of
                        0:
                            For Var J := High(FirstQueue) downto 0 Do
                                Enqueue(FirstQueue[J], I, 1);
                        1:
                            For Var J := High(SecondQueue) downto 0 Do
                                Enqueue(SecondQueue[J], I, 2);
                        2:
                            For Var J := High(ThirdQueue) downto 0 Do
                                Enqueue(ThirdQueue[J], I, 2);
                        3:
                            For Var J := High(FourthQueue) downto 0 Do
                                Enqueue(FourthQueue[J], I, 2);
                        4:
                            For Var J := High(FifthQueue) downto 0 Do
                                Enqueue(FifthQueue[J], I, 3);
                        5:
                            For Var J := High(SixthQueue) downto 0 Do
                                Enqueue(SixthQueue[J], I, 3);

                    End;
                End;

                IsEnd := False;
            End;
        End;
    End;
    Write('Введите значение такта процессора: ');
    Readln(TickTime);
    Write('Введите время ввода: ');
    Readln(EnterTime);

End;

Function CheckEmptyQueues(): Boolean;
Var
    I: Integer;
    Counter: Integer;
Begin
    Counter := 0;
    For I := 0 To High(PriorityArray) Do
    Begin
        If PriorityArray[I] = nil Then
            Inc(Counter);
    End;
    Result := Counter = High(PriorityArray) + 1;
End;

Function IsRingEmpty(Ring: Integer): Boolean;
Var
    I: Integer;
    Res: Boolean;

Begin
    Res := False;

    Case Ring Of
    1:
        If PriorityArray[0] = nil Then
            Res := True;
    2:
        If (PriorityArray[1] = nil) And (PriorityArray[2] = nil) And (PriorityArray[3] = nil) Then
            Res := True;
    3:
        If (PriorityArray[4] = nil) And (PriorityArray[5] = nil) Then
            Res := True;

    End;
    Result := Res;
End;

Function FindNextRing(PrevRing: Integer): Integer;
Var
    I: Integer;
    NextRing: Integer;
    IsRingFound: Boolean;
Begin
    I := 0;
    IsRingFound := False;
    While (I <= 3) And Not IsRingFound Do
    Begin
        If PriorityArray[I] <> nil Then
        Begin
            If (PriorityArray[I].Ring = PrevRing) And (PrevRing <> 3) Then
            Begin
                NextRing := PrevRing + 1;
                IsRingFound := True;
            End;

        End
        Else
        Begin
            If PriorityArray[I].Ring + 1 < 4 Then
                NextRing := PriorityArray[I].Ring + 1
        End;
        Inc(I);
    End;
End;

Function GetPriority(): Integer;

Begin

End;

Function CalculateTicks(TickTime, EnterTime: Integer): Integer;
Var
    I, J: Integer;
Begin
    While Not CheckEmptyQueues Do
    Begin


    End;


End;

Var
    TickTime: Integer;
    EnterTime: Integer;

BEGIN

    InputFunc(TickTime, EnterTime);


    Writeln('Ввод окончен');

    Readln;

END.
