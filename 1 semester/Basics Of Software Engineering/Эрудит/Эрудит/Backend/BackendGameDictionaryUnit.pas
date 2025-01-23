Unit BackendGameDictionaryUnit;

Interface

Uses System.Generics.Collections, BackendStartUnit;

Type
    TPoints = Integer;
    TWordDic = TDictionary<String, TPoints>;

    TGameDictionary = Class
    Private
        GameDic: TWordDic;
        SourceFileName: String;
        SourceFile: TextFile;
    Public
        Constructor Create(SourceFileName: String; Language: TLanguage);
        Procedure LoadDictionaryFromFile();
        Procedure AddNewWord(NewWord: String);
        Function IsExist(UserWord: String): Boolean;
        // use Destroy() by default
    End;

Implementation

{ TGameDictionary }

Procedure TGameDictionary.AddNewWord(NewWord: String);
Begin
    Append(SourceFile);
    GameDic.Add(NewWord, Length(NewWord));
    Try
        Writeln(SourceFile, NewWord);
    Finally
        CloseFile(SourceFile);
    End;
End;

Constructor TGameDictionary.Create(SourceFileName: String; Language: TLanguage);
Begin
    Self.SourceFileName := SourceFileName;
    If Language = TLanguage.EN Then
        AssignFile(SourceFile, SourceFileName)
    Else
        AssignFile(SourceFile, SourceFileName, CP_UTF8);
End;

Function TGameDictionary.IsExist(UserWord: String): Boolean;
Begin
    If GameDic.ContainsKey(UserWord) Then
        IsExist := True
    Else
        IsExist := False;
End;

Procedure TGameDictionary.LoadDictionaryFromFile();
Var
    Word: String;
    Count: Integer;
Begin
    Try
        ReSet(SourceFile);
        GameDic := TDictionary<String, Integer>.Create();
        While Not EOF(SourceFile) Do
        Begin
            Readln(SourceFile, Word);
            If Not GameDic.ContainsKey(Word) Then
                GameDic.Add(Word, Length(Word));
        End;
    Finally
        CloseFile(SourceFile);
        // in future
    End;
End;

End.
