Unit PlayersListUnit;

Interface

Uses
    Vcl.Grids, Vcl.Forms, SysUtils, VCL.StdCtrls;

Type
    Player = ^TPlayer;

    TPlayer = Record
        Name: String[20];
        Score: Integer;
        HighScore: Integer;
        Next: Player;
    End;

Function IsExistPlayer(Const PlayerList: Player; Name: String): Boolean;
Function CreatePlayer(Name: String; Score: Integer): Player;
Procedure AddPlayer(Var PlayerList: Player; Const Name: String; Score: Integer);
Function IsPlayerDataEqual(Const Name1, Name2: String): Boolean;
Procedure DeletePlayer(Var PlayerList: Player; Const Name: String);
Function FindCountOfPlayers(Const PlayerList: Player): Integer;
Function SearchPlayer(Const PlayerList: Player; Name: String): Player;
Procedure CheckHighScore(Var PlayerList: Player);
Procedure FillScoreGrid(Var ScoreGrid: TStringGrid; Const PlayerList: Player);
Function SelectionSort(Const PlayerList: Player): Player;
Procedure ClearPlayer(Var PlayerList: Player);

Implementation

Procedure ClearPlayer(Var PlayerList: Player);
Var
    CurrPlayer, TempPlayer: Player;
Begin
    // Получаем указатель на первый элемент списка
    CurrPlayer := PlayerList;
    While CurrPlayer <> Nil Do
    Begin
        // Поочередно удаляем элементы из списка
        TempPlayer := CurrPlayer;
        CurrPlayer := CurrPlayer^.Next;
        Dispose(TempPLayer);
    End;
    // Разрываем указатель и обнуляем значения количества
    PlayerList := Nil;
End;

Procedure CheckHighScore(Var PlayerList: Player);
Begin
    If PlayerList.Score > PlayerList.HighScore Then
        PlayerList.HighScore := PlayerList.Score;

End;

Function CreatePlayer(Name: String; Score: Integer): Player;
Var
    NewPlayer: Player;
Begin
    // Выделение памяти для нового элемента
    New(NewPlayer);
    // Заполнение полей записи
    NewPlayer.Name := Name;
    NewPlayer.Score := Score;
    NewPlayer.HighScore := Score;
    // Указатель на следющий элемент равен Nil
    NewPlayer^.Next := Nil;
    CreatePlayer := NewPlayer;
End;

Procedure AddPlayer(Var PlayerList: Player; Const Name: String; Score: Integer);
Var
    NewPlayer, CurrPlayer: Player;
Begin
    // Создание нового узла
    NewPlayer := CreatePlayer(Name, Score);
    // Список пуст
    If PlayerList = Nil Then
        PlayerList := NewPlayer
    Else
    Begin
        // Получаем указатель на конец списка
        CurrPlayer := PlayerList;
        While CurrPlayer^.Next <> Nil Do
            CurrPlayer := CurrPlayer^.Next;
        // Добавляем новый элемент в конец
        CurrPlayer^.Next := NewPlayer;
    End;
End;

Function IsPlayerDataEqual(Const Name1, Name2: String): Boolean;
Var
    IsEqual: Boolean;
Begin
    IsEqual := (Name1 = Name2);
    IsPlayerDataEqual := IsEqual;
End;

Function IsExistPlayer(Const PlayerList: Player; Name: String): Boolean;
Var
    CurrPlayer: Player;
    IsExist: Boolean;
Begin

    CurrPlayer := PlayerList;
    IsExist := False;
    If CurrPlayer <> Nil Then
        Repeat
            IsExist := IsPlayerDataEqual(CurrPlayer.Name, Name);
            CurrPlayer := CurrPlayer^.Next
        Until (IsExist) Or (CurrPlayer = Nil);
    IsExistPlayer := IsExist;

End;

Procedure DeletePlayer(Var PlayerList: Player; Const Name: String);
Var
    CurrPlayer, TempPlayer: Player;
Begin
    // Равна ли удаляемая шашка с головой списка
    If IsPlayerDataEqual(PlayerList.Name, Name) Then
    Begin
        TempPlayer := PlayerList;
        PlayerList := PlayerList^.Next;
    End
    Else
    Begin
        // Проходимся по списку и сравниваем шашки
        CurrPlayer := PlayerList;
        While Not IsPlayerDataEqual(CurrPlayer^.Next^.Name, Name) Do
            CurrPlayer := CurrPlayer^.Next;
        TempPlayer := CurrPlayer^.Next;
        CurrPlayer^.Next := CurrPlayer^.Next^.Next;
    End;
    // Удаляем шашку
    Dispose(TempPlayer);
End;

Function FindCountOfPlayers(Const PlayerList: Player): Integer;
Var
    CurrPlayer: Player;
    Count: Integer;
Begin
    Count := 0;
    CurrPlayer := PlayerList;
    If CurrPlayer <> Nil Then
    Begin
        While CurrPlayer <> Nil Do
        Begin
            CurrPlayer := CurrPlayer^.Next;
            Inc(Count);
        End;
    End;
    FindCountOfPlayers := Count;
End;

Function SearchPlayer(Const PlayerList: Player; Name: String): Player;
Var
    CurrPlayer: Player;
Begin
    CurrPlayer := PlayerList;
    If IsExistPlayer(PlayerList, Name) Then
    Begin
        While Not IsPlayerDataEqual(CurrPlayer.Name, Name) Do
            CurrPlayer := CurrPlayer^.Next;

        SearchPlayer := CurrPlayer;

    End;
End;

Procedure InitializeGrid(Var ScoreGrid: TStringGrid);
Begin
    With ScoreGrid Do
    Begin
        ColCount := 2;
        RowCount := 1;
        Cells[0, 0] := 'Player';
        Cells[1, 0] := 'High Score';
        ColWidths[0] := ScoreGrid.Width Div 2;
        ColWidths[1] := ScoreGrid.Width Div 2;

    End;
End;

Procedure FillScoreGrid(Var ScoreGrid: TStringGrid; Const PlayerList: Player);
Var
    I, CurrRow: Integer;
    CurrPlayer: Player;
Begin
    InitializeGrid(ScoreGrid);
    CurrPlayer := SelectionSort(PlayerList);
    ScoreGrid.RowCount := FindCountOfPlayers(PlayerList) + 1;
    CurrRow := 1;
    While CurrPlayer <> Nil Do
    Begin
        With ScoreGrid Do
        Begin
            Cells[0, CurrRow] := CurrPlayer.Name;
            Cells[1, CurrRow] := IntToStr(CurrPlayer.HighScore);
        End;
        Inc(CurrRow);

        CurrPlayer := CurrPlayer^.Next;
    End;

    If ScoreGrid.RowCount > 10 Then
    Begin
        ScoreGrid.ScrollBars := TScrollStyle.SsVertical;
        ScoreGrid.Height := 400
    End
    Else
    Begin
        ScoreGrid.ScrollBars := TScrollStyle.SsNone;
        ScoreGrid.Height :=
          (ScoreGrid.DefaultRowHeight + ScoreGrid.GridLineWidth) *
          ScoreGrid.RowCount + 5;
    End;
End;

Function SelectionSort(Const PlayerList: Player): Player;
Var
    I, J, MinIndex: Integer;
    Temp: Integer;
    TempStr: String;
    CurrPlayer: Player;
    Arr: Array Of Integer;
    NameArr: Array Of String;

    NewList: Player;
Begin
    NewList := Nil;
    SetLength(Arr, FindCountOfPlayers(PlayerList));
    SetLength(NameArr, FindCountOfPlayers(PlayerList));

    CurrPlayer := PlayerList;
    I := 0;
    While CurrPlayer <> Nil Do
    Begin
        NameArr[I] := CurrPlayer.Name;
        Arr[I] := CurrPlayer.HighScore;
        CurrPlayer := CurrPlayer^.Next;
        Inc(I);
    End;

    For I := 0 To High(Arr) - 1 Do
    Begin
        MinIndex := I;
        For J := I + 1 To High(Arr) Do
            If Arr[J] > Arr[MinIndex] Then
                MinIndex := J;

        Temp := Arr[I];
        TempStr := NameArr[I];

        Arr[I] := Arr[MinIndex];
        NameArr[I] := NameArr[MinIndex];

        Arr[MinIndex] := Temp;
        NameArr[MinIndex] := TempStr;
    End;

    For I := 0 To FindCountOfPlayers(PlayerList) - 1 Do
        AddPlayer(NewList, NameArr[I], Arr[I]);

    SelectionSort := NewList;

End;

End.
