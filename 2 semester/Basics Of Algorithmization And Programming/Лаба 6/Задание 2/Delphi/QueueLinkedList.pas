Unit QueueLinkedList;


Interface
Uses

    Vcl.Dialogs;

Type
    TQueueNode = ^TNode;

    TNode = Record
        Data: Integer;
        Next: TQueueNode;
    End;

    TQueue = Record
        Head: TQueueNode;
        Tail: TQueueNode;
    End;

Procedure CreateQueue;
Function OutQueue(): Integer;
Procedure AddQueue(Data: Integer);

    
Implementation
Var
    Queue:TQueue;

Procedure CreateQueue();
Begin
    Queue.Head := Nil;
    Queue.Tail := Nil;
End;

Procedure AddQueue(Data: Integer);
Var
    NewNode: TQueueNode;
Begin
    New(NewNode);
    NewNode.Data := Data;
    NewNode.Next := Nil;
    If Queue.Head = Nil Then
        Queue.Head := NewNode
    Else
        Queue.Tail.Next := NewNode;
    Queue.Tail := NewNode;
End;

Function OutQueue(): Integer;
Var
    Data: Integer;
Begin
    If Queue.Head = Nil Then
        ShowMessage('Очередь пуста')    
    Else
    Begin
        Data := Queue.Head.Data;
        Queue.Head := Queue.Head.Next;
        If Queue.Head = Nil Then
            Queue.Tail := Nil;
        OutQueue := Data;
    End;
End;

Exports CreateQueue, OutQueue, AddQueue;
  

End.
