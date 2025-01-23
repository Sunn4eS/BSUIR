library DoubleLinkedList;
uses
  Vcl.Grids;

Type
    TNumString = String[10];
    TNameString = String[16];

    TDoubleLinkedList = ^TNode;

    TNode = Record
        Name: TNameString;
        Number: TNumString;
        Next: TDoubleLinkedList;
        Prev: TDoubleLinkedList;
    End;

Var
    Head: TDoubleLinkedList = nil;
    Tail: TDoubleLinkedList = nil;   

Procedure AddNewContact(Name, Number: String; Var StringGrid: TStringGrid);
Var
    NewItem: TDoubleLinkedList;
Begin
    New(NewItem);
    NewItem.Name := Name;
    NewItem.Number := Number;
    NewItem.Prev := Tail;
    NewItem.Next := nil;
    If Head = nil then
        Head := NewItem
    Else
        Tail^.Next := NewItem;
    Tail := NewItem;
End;

Procedure DeleteContact(Place: Integer);
Var
    CurrCont, PrevCont, NextCont: TDoubleLinkedList;
    Counter: Integer;
Begin
    CurrCont := Head;
    Counter := 1;
    while (Counter < Place) do
    Begin
        CurrCont := CurrCont^.Next;
        Inc(Counter);
    End;

    PrevCont := CurrCont^.Prev;
    NextCont := CurrCont^.Next;

    if PrevCont <> nil then
        PrevCont^.Next := NextCont
    Else
        Head := NextCont;

    if NextCont <> nil then
        NextCont^.Prev := PrevCont
    Else
        Tail := CurrCont^.Prev;

    Dispose(CurrCont);
End;

Procedure PrintUpDownList (Var ListGrid: TStringGrid);
Var
    CurrCont: TDoubleLinkedList;
    Count: Integer;
Begin
    CurrCont := Head;
    Count := 1;
    While (CurrCont <> nil) Do
    Begin
        ListGrid.Cells[0, Count] := CurrCont.Name;
        ListGrid.Cells[1, Count] := Concat('+375', CurrCont.Number);
        CurrCont := CurrCont^.Next;    
        Inc(Count);
    End;    
End;
    
Procedure PrintDownUpList(Var ListGrid: TStringGrid);
Var
    CurrCont: TDoubleLinkedList;
    Count: Integer;
Begin
    CurrCont := Tail;
    Count := 1;
    while CurrCont <> nil do
    Begin
        ListGrid.Cells[0, Count] := CurrCont.Name;
        ListGrid.Cells[1, Count] := Concat('+375', CurrCont.Number);
        CurrCont := CurrCont^.Prev;    
        Inc(Count);
    End;
End;

Procedure ClearList();
Var
    CurrCont, NextCont: TDoubleLinkedList;
Begin
    CurrCont := Head;
    while CurrCont <> nil do
    Begin
        NextCont := CurrCont.Next;
        Dispose(CurrCont);
        CurrCont := NextCont;
    End;
    Head := nil;
End; 
    
Exports AddNewContact, PrintUpDownList, PrintDownUpList, DeleteContact, ClearList;
Begin
End.

