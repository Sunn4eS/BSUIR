Unit FileUnit;

Interface

Uses
    PlayersListUnit, SysUtils;

Const
    MIN_SCORE = 0;
    MAX_SCORE = Maxint;
    MAX_NAME_LENGTH = 20;
    MAX_PLAYER_COUNT = 100;

Type

    TPlayerFile = File Of TPlayer;

Function IsCorrectFileData(Const TempPlayerData: TPlayer): Boolean;
Procedure WriteFileData(Var OutputFile: TPlayerFile; Const PlayerList: Player);

Function ReadFileData(Var InputFile: TPlayerFile; Var TempPlayerList: Player;
  Const FileName: String): Boolean;

Implementation

Function IsCorrectFileData(Const TempPlayerData: TPlayer): Boolean;
Begin
    With TempPlayerData Do
        IsCorrectFileData := (HighScore >= MIN_SCORE) And
          (HighScore <= MAX_SCORE) And (Length(TempPlayerData.Name) >= 1) And
          (Length(TempPlayerData.Name) <= MAX_NAME_LENGTH);
End;

Function ReadFileData(Var InputFile: TPlayerFile; Var TempPlayerList: Player;
  Const FileName: String): Boolean;
Var
    IsCorrect: Boolean;
    PlayerCount: Integer;
    TempPlayerData: TPlayer;
Begin
    If Not FileExists(FileName) Then
    Begin
        AssignFile(InputFile, FileName);
        Rewrite(InputFile);
        IsCorrect := True;

    End
    Else
    Begin
        AssignFile(InputFile, FileName);
        Reset(InputFile);
        IsCorrect := True;
        PlayerCount := 0;
        While IsCorrect And (PlayerCount < MAX_PLAYER_COUNT) And
          Not EOF(InputFile) Do
        Begin
            Read(InputFile, TempPlayerData);
            IsCorrect := IsCorrectFileData(TempPlayerData) And
              Not IsExistPlayer(TempPlayerList, TempPlayerData.Name);
            If IsCorrect Then
            Begin
                AddPlayer(TempPlayerList, TempPlayerData.Name,
                  TempPlayerData.HighScore);
                Inc(PlayerCount);
            End;
        End;
        If IsCorrect Then
            IsCorrect := PlayerCount <= MAX_PLAYER_COUNT;
    End;

    CloseFile(InputFile);
    ReadFileData := IsCorrect;
End;

Procedure WriteFileData(Var OutputFile: TPlayerFile; Const PlayerList: Player);
Var
    CurrPlayer: Player;
    CurrPlayerData: TPlayer;
Begin
    Rewrite(OutputFile);
    CurrPlayer := PlayerList;
    While CurrPlayer <> Nil Do
    Begin
        CurrPlayerData.Name := CurrPlayer.Name;
        CurrPlayerData.Score := CurrPlayer.Score;
        CurrPlayerData.HighScore := CurrPlayer.HighScore;
        CurrPlayerData.Next := CurrPlayer.Next;

        Write(OutputFile, CurrPlayerData);
        CurrPlayer := CurrPlayer^.Next;
    End;
    CloseFile(OutputFile);
End;

End.
