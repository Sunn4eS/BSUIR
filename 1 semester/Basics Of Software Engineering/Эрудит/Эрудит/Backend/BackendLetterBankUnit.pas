Unit BackendLetterBankUnit;

Interface

Uses System.Generics.Collections, BackendGamerUnit, System.SysUtils,
    BackendStartUnit;

Type
    TLetterBank = Class
    Private
        Alphabet: TLetters;
        SourceFileName: String;
        SourceFile: TextFile;
        Language: TLanguage;
        VowelLettersLeftInAlphabet: Integer;
        LettersLeftInAlphabet: Integer;
    Public
        Constructor Create(SourceFileName: String; Language: TLanguage);
        Procedure LoadDictionaryFromFile();
        Function GiveLetters(CountLetters: Integer; VowelCount: Integer)
            : TLetters;
        Function GetCountOfLetter() : Integer;
    End;

Implementation

{ TLetterBank }

Constructor TLetterBank.Create(SourceFileName: String; Language: TLanguage);
Begin
    Self.VowelLettersLeftInAlphabet := 0;
    Self.LettersLeftInAlphabet := 0;
    Self.SourceFileName := SourceFileName;
    Self.Language := Language;
    If Language = TLanguage.EN Then
        AssignFile(SourceFile, SourceFileName)
    Else
        AssignFile(SourceFile, SourceFileName, CP_UTF8);
End;

function TLetterBank.GetCountOfLetter: Integer;
begin
    GetCountOfLetter := Alphabet.Count;
end;

Function TLetterBank.GiveLetters(CountLetters: Integer; VowelCount: Integer)
    : TLetters;
Var
    // сами буквы
    Letters: TLetters;
    // для рандома
    RandomIndex: Integer;
    RandomLetter: Char;
    // для циклов
    Letter: Char; // для английских букв
    I, J: Integer;
    // для проверок
    Counter: Integer;
    LetterFound: Boolean;
    IsVowel: Boolean;
    // для русского языка
Begin
    Letters := Nil;
    Letters := TDictionary<Char, Integer>.Create();
    // рандом работает тогда и только тогда, когда количество
    // запрашиваемых букв больше, чем есть в банке букв
    If (CountLetters <= LettersLeftInAlphabet) And
        ((CountLetters * 1.2) < (LettersLeftInAlphabet - VowelLettersLeftInAlphabet))  Then
    Begin
        For I := 1 To CountLetters Do
        Begin
            RandomLetter := #0;
            LetterFound := False;
            Repeat
                Randomize;
                RandomIndex := Random(Alphabet.Count);
                Counter := 0;
                // тут происходит общая генерация буквы
                For Letter In Alphabet.Keys Do
                Begin
                    If (RandomIndex = Counter) Then
                    Begin
                        RandomLetter := Letter;
                        Break;
                    End;
                    Inc(Counter);
                End;
                // тут начинается псевдо рандом)
                //
                If Alphabet.ContainsKey(RandomLetter) Then
                Begin
                    // Тут мы смотрим чтобы буквы не повторялись больше 2 раз
                    If Not Letters.ContainsKey(RandomLetter) Then
                    Begin
                        // тут реализация того, чтобы при рандом брало 40%
                        IsVowel := False;
                        // реализация для англ языка (к сожаленю общую реализацию
                        // не сделаешь из-за проблем с кодировками)
                        If (Language = TLanguage.EN) Then
                        Begin
                            If (RandomLetter In VOWEL_LETTERS_EN) Then
                                IsVowel := True;
                        End
                        Else
                        Begin
                            // небольшой цикл, чтобы найти гласную букву
                            For J := 0 To 9 Do
                            Begin
                                If RandomLetter = VOWEL_LETTERS_RUS[J] Then
                                Begin
                                    IsVowel := True;
                                    Break;
                                End;
                            End;
                        End;
                        If IsVowel And (VowelCount < CountLetters * 0.4) Then
                        Begin
                            LetterFound := True;
                            Inc(VowelCount);
                            Dec(VowelLettersLeftInAlphabet);
                        End
                        Else If Not IsVowel And
                            (VowelCount >= CountLetters * 0.4) Then
                            LetterFound := True;
                    End;
                End;
            Until LetterFound;
            // мы нашли букву, а теперь заносим ее в ответный словарь
            // и убираем из Банка букв
            // а также уменьшаем счетчик букв
            Dec(LettersLeftInAlphabet);
            Alphabet[RandomLetter] := Alphabet[RandomLetter] - 1;
            If Alphabet[RandomLetter] = 0 Then
                Alphabet.Remove(RandomLetter);
            If Not Letters.ContainsKey(RandomLetter) Then
                Letters.Add(RandomLetter, 0);
            Letters[RandomLetter] := Letters[RandomLetter] + 1;
        End;
    End
    Else
    Begin
        Counter := 0;
        For Letter In Alphabet.Keys Do
        Begin
            If Counter < CountLetters Then
            Begin
                Alphabet[Letter] := Alphabet[Letter] - 1;
                If Alphabet[Letter] = 0 Then
                    Alphabet.Remove(Letter);
                If Not Letters.ContainsKey(Letter) Then
                    Letters.Add(Letter, 0);
                Letters[Letter] := Letters[Letter] + 1;
                Dec(LettersLeftInAlphabet);
                Inc(Counter);
            End
            Else
                Break;
        End;
    End;
    GiveLetters := Letters;
End;

Procedure TLetterBank.LoadDictionaryFromFile();
Var
    Letter: Char;
    Count: Integer;
    I, J: Integer;
    CountOfLetters: Integer;
Begin
    Try
        Reset(SourceFile);
        Readln(SourceFile, CountOfLetters);
        Alphabet := TDictionary<Char, Integer>.Create();
        For I := 1 To CountOfLetters Do
        Begin
            Read(SourceFile, Letter);
            Readln(SourceFile, Count);
            Alphabet.Add(Letter, Count);
            Inc(LettersLeftInAlphabet, Count);
            If (Language = TLanguage.EN) Then
            Begin
                If (Letter In VOWEL_LETTERS_EN) Then
                    Inc(VowelLettersLeftInAlphabet, Count);
            End
            Else
            Begin
                // небольшой цикл, чтобы найти гласную букву
                For J := 0 To 9 Do
                Begin
                    If Letter = VOWEL_LETTERS_RUS[J] Then
                    Begin
                        Inc(VowelLettersLeftInAlphabet, Count);
                        Break;
                    End;
                End;
            End;

        End;
    Finally
        CloseFile(SourceFile);
    End;
End;

End.
