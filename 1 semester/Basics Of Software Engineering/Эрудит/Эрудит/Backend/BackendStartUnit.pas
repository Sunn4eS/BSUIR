Unit BackendStartUnit;

Interface

Type
    TLanguage = (EN, RUS);

    TStart = Class
    Private
        Players: Integer;
        Language: TLanguage;
    Public
        Procedure SetPlayers(Players: Integer);
        Procedure SetLanguage(Language: TLanguage);
        Function GetPlayers(): Integer;
        Function GetLanguage(): TLanguage;
    End;

Var
    Start : TStart;

Implementation

{ TStart }

Function TStart.GetLanguage: TLanguage;
Begin
    GetLanguage := Self.Language;
End;

Function TStart.GetPlayers: Integer;
Begin
    GetPlayers := Players;
End;

Procedure TStart.SetLanguage(Language: TLanguage);
Begin
    Self.Language := Language;
End;

Procedure TStart.SetPlayers(Players: Integer);
Begin
    Self.Players := Players;
End;

End.
