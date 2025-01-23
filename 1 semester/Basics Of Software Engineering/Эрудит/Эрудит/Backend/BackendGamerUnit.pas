Unit BackendGamerUnit;

Interface

Uses System.Generics.Collections, BackendStartUnit;

Const
    VOWEL_LETTERS_EN: Set Of Char = ['a', 'e', 'i', 'o', 'u'];
    VOWEL_LETTERS_RUS: Array Of Char = ['а', 'о', 'у', 'ы', 'э', 'я', 'ю', 'ё',
        'и', 'е'];

Type
    TLetters = TDictionary<Char, Integer>;
    TGamer = Class
    Private
        Status50For50Button: Boolean;
        StatusFriendsHelpButton: Boolean;
        ExitStatus: Boolean;
        UserLetters: TLetters;
        LastWord: String;
        GamerPoints: Integer;
        Language : TLanguage;
    Public
        Constructor Create();
        Procedure SetLastGamersWord(LastGamersWord: String);
        Procedure SetLetters(Letters: TLetters);
        Procedure SetLanguage(Language : TLanguage);
        Procedure ChangeLetter(ChosenLetter, NewLetter: Char);
        Procedure DeleteLetters();
        Procedure AddPoints();
        Procedure SubPoints();
        Procedure SetExitStatus(ExitStatus: Boolean);
        Procedure UseFrindsHelpButton();
        Procedure Use50For50Button();
        // 0 - не было использована
        // 1 - была использована
        Function GetFrindsHelpButtonStatus(): Boolean;
        Function Get50For50ButtonStatus(): Boolean;
        Function GetExitStatus(): Boolean;
        Function GetCountLetters(): Integer;
        Function GetLastWord(): String;
        Function GetPoints(): Integer;
        Function GetUserLetters(): TLetters;
         // для того, чтобы рандом был лучше
        // можно считать сколько гласных или согласных в данный момент
        // так как гласных меньше я решил сделать гласные
        Function GetCountVowel() : Integer;
        // проверяет можно ли составить последнее переданное слов из букв,
        // которые были в БАНКЕ БУКВ пользователя
        Function IsWordCreatable(): Boolean;
        // нужна для 50 на 50 бонуса
        Function IsContainsLetters(Letters: String): Boolean;
    End;
    TGamers = Array Of TGamer;

Implementation

{ TGamer }

Procedure TGamer.AddPoints();
Begin
    Inc(GamerPoints, Length(LastWord));
End;

Procedure TGamer.ChangeLetter(ChosenLetter, NewLetter: Char);
Begin
    // удаление буквы которую пользователь убрал
    If UserLetters[ChosenLetter] = 1 Then
        UserLetters.Remove(ChosenLetter)
    Else
        UserLetters[ChosenLetter] := UserLetters[ChosenLetter] - 1;
    // добавление новой
    If UserLetters.ContainsKey(NewLetter) Then
        UserLetters[NewLetter] := UserLetters[NewLetter] + 1
    Else
        UserLetters.Add(NewLetter, 1);
End;

Constructor TGamer.Create;
Begin
    UserLetters := TDictionary<Char, Integer>.Create();
    LastWord := '';
    GamerPoints := 0;
    ExitStatus := False;
    Status50For50Button := False;
    StatusFriendsHelpButton := False;
End;

Procedure TGamer.DeleteLetters;
Var
    I: Integer;
    Size: Integer;
    TempLetter: Char;
Begin
    Size := Length(LastWord);
    For I := 1 To Size Do
    Begin
        TempLetter := LastWord[I];
        If UserLetters.ContainsKey(TempLetter) Then
        Begin
            UserLetters[TempLetter] := UserLetters[TempLetter] - 1;
            If UserLetters[TempLetter] = 0 Then
                UserLetters.Remove(TempLetter);
        End;
    End;
End;

Function TGamer.GetCountLetters: Integer;
Var
    Count: Integer;
    I: Integer;
Begin
    Count := 0;
    For I In UserLetters.Values Do
        Inc(Count, I);
    GetCountLetters := Count;
End;

function TGamer.GetCountVowel: Integer;
Var
    isVowel : Boolean;
    Letter : Char;
    I, VowelLettersCount : Integer;
begin
    VowelLettersCount := 0;
    for Letter in UserLetters.Keys do
    Begin
        if Language = TLanguage.EN then
        Begin
            if Letter in VOWEL_LETTERS_EN then
                Inc(VowelLettersCount,UserLetters[Letter]);
        End
        else
        Begin
            for I := 0 to 9 do
                if Letter = VOWEL_LETTERS_RUS[I] then
                    Inc(VowelLettersCount,UserLetters[Letter]);
        End;
    End;
    GetCountVowel := VowelLettersCount;
end;

Function TGamer.GetExitStatus: Boolean;
Begin
    GetExitStatus := ExitStatus;
End;

Function TGamer.GetLastWord(): String;
Begin
    GetLastWord := LastWord;
End;

Function TGamer.GetPoints: Integer;
Begin
    GetPoints := GamerPoints;
End;

Function TGamer.GetUserLetters: TLetters;
Begin
    GetUserLetters := UserLetters;
End;

Function TGamer.IsContainsLetters(Letters: String): Boolean;
Var
    Counter, Size, I, J: Integer;
    TempLetter: Char;
    Answer, WrongLetter: Boolean;
Begin
    Answer := True;
    Size := Length(Letters);
    For TempLetter In UserLetters.Keys Do
    Begin
        Counter := 0;
        // если буква есть в словаре, но ее больше чем дано
        For I := 1 To Size Do
        Begin
            // если буквы нет в словаре
            If Not UserLetters.ContainsKey(Letters[I]) Then
            Begin
                Answer := False;
                Break;
            End;
            If Letters[I] = TempLetter Then
                Inc(Counter);
        End;
        If UserLetters[TempLetter] < Counter Then
        Begin
            Answer := False;
            Break;
        End;
    End;
    IsContainsLetters := Answer;
End;

Function TGamer.IsWordCreatable(): Boolean;
Var
    Counter, Size, I, J: Integer;
    TempLetter: Char;
    Answer, WrongLetter: Boolean;
Begin
    Answer := True;
    Size := Length(LastWord);
    For TempLetter In UserLetters.Keys Do
    Begin
        Counter := 0;
        // если буква есть в словаре, но ее больше чем дано
        For I := 1 To Size Do
        Begin
            // если буквы нет в словаре
            If Not UserLetters.ContainsKey(LastWord[I]) Then
            Begin
                Answer := False;
                Break;
            End;
            If LastWord[I] = TempLetter Then
                Inc(Counter);
        End;
        If UserLetters[TempLetter] < Counter Then
        Begin
            Answer := False;
            Break;
        End;
    End;
    IsWordCreatable := Answer;
End;

procedure TGamer.SetLanguage(Language: TLanguage);
begin
    Self.Language := Language;
end;

Procedure TGamer.SetLastGamersWord(LastGamersWord: String);
Begin
    LastWord := LastGamersWord;
End;

Procedure TGamer.SetLetters(Letters: TLetters);
Var
    Letter: Char;
Begin
    For Letter In Letters.Keys Do
    Begin
        If Not UserLetters.ContainsKey(Letter) Then
            UserLetters.Add(Letter, 0);
        UserLetters[Letter] := UserLetters[Letter] + Letters[Letter];
    End;
End;

Procedure TGamer.SubPoints;
Begin
    Dec(GamerPoints, Length(LastWord));
    LastWord := '';
End;

Function TGamer.Get50For50ButtonStatus(): Boolean;
Begin
    Get50For50ButtonStatus := Self.Status50For50Button;
End;

Procedure TGamer.Use50For50Button();
Begin
    Status50For50Button := True;
End;

Procedure TGamer.SetExitStatus(ExitStatus: Boolean);
Begin
    Self.ExitStatus := ExitStatus;
End;

Procedure TGamer.UseFrindsHelpButton;
Begin
    StatusFriendsHelpButton := True;
End;

Function TGamer.GetFrindsHelpButtonStatus(): Boolean;
Begin
    GetFrindsHelpButtonStatus := Self.StatusFriendsHelpButton;
End;

End.
