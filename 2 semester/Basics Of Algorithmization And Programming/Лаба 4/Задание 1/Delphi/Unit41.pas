Unit Unit41;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls, Unit14,
    Unit155,
    Vcl.Buttons, Vcl.Menus, Vcl.ExtDlgs;

Type
    TScheduleInfo = Record
        ElemSubject: String;
        ElemTeacher: String;
        ElemDayOfWeek: String;
        ElemNumOfLesson: Byte;
    End;

    TScheduleInfoArr = Array Of TScheduleInfo;
    StringGridCracker = Class(TStringGrid);

    TForm13 = Class(TForm)

        Label1: TLabel;
        Button1: TButton;
        TeacherSch: TButton;
        Records: TStringGrid;
        SpeedButton1: TSpeedButton;
        MainMenu1: TMainMenu;
        N1: TMenuItem;
        BOpen: TMenuItem;
        BSave: TMenuItem;
        BClose: TMenuItem;
        Instructions: TMenuItem;
        BDev: TMenuItem;
        DeleteRec: TButton;
        OpenTextFileDialog1: TOpenTextFileDialog;
    ShiftBlocker: TMenuItem;
        Procedure FormCreate(Sender: TObject);
        Procedure Button1Click(Sender: TObject);
        Procedure TeacherSchClick(Sender: TObject);
        Procedure MyCellClick(Sender: TObject);
        Procedure RecordsSelectCell(Sender: TObject; ACol, ARow: Integer;
          Var CanSelect: Boolean);
        Procedure DeleteRecClick(Sender: TObject);
        Procedure BDevClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure BSaveClick(Sender: TObject);
        Procedure BOpenClick(Sender: TObject);
    procedure InstructionsClick(Sender: TObject);
    function FormHelp(Command: Word; Data: NativeInt;
      var CallHelp: Boolean): Boolean;
    procedure BCloseClick(Sender: TObject);
    Private
    Public
    End;
Var
    Form13: TForm13;

Implementation

{$R *.dfm}

procedure TForm13.BCloseClick(Sender: TObject);
begin
    Close
end;

Procedure TForm13.BDevClick(Sender: TObject);
Begin
    Application.MessageBox('Бражалович Александр Иванович,' + #13 + 'группа 351004',
      'О разработчике')
End;

Function IsFileReadOnly(Const FileName: String): Boolean;
Begin
    Result := False;
    If FileExists(FileName) Then
    Begin
        Result := (FileGetAttr(FileName) And FaReadOnly) = FaReadOnly;
    End;
End;

Procedure TForm13.BOpenClick(Sender: TObject);
Var
    TxtFile: TextFile;
    CanReadFile: Boolean;
    FileName: String;
    CurNum, NumOfIter, I, J, K: Integer;
    RecordsFromFile, MyRecords: TScheduleInfoArr;
    MyRecordFromFile, CurRecord: TScheduleInfo;
Begin
    CanReadFile := True;
    OpenTextFileDialog1.Filter := 'Текстовый файл (*.txt)|*.txt';
    If OpenTextFileDialog1.Execute Then
    Begin
        FileName := OpenTextFileDialog1.FileName;
        AssignFile(TxtFile, FileName);
        Try
            Reset(TxtFile);
        Except
            Application.MessageBox('Не удалось открыть файл', 'Error');
            CanReadFile := False;
        End;
        If Not SameText(ExtractFileExt(FileName), '.txt') And CanReadFile Then
        Begin
            CanReadFile := False;
            Application.MessageBox('Неверное расширение файла', 'Error');
        End;
        If CanReadFile Then
        Begin
            SetLength(MyRecords, Records.RowCount - 1);
            If Records.RowCount > 1 Then
                For I := 0 To Records.RowCount - 2 Do
                Begin
                    MyRecords[I].ElemSubject := Records.Cells[2, I + 1];
                    MyRecords[I].ElemTeacher := Records.Cells[3, I + 1];
                    MyRecords[I].ElemDayOfWeek := Records.Cells[0, I + 1];
                    MyRecords[I].ElemNumOfLesson :=
                      StrToInt(Records.Cells[1, I + 1]);
                End;
            Try
                If EOF(TxtFile) Then
                Begin
                    Application.MessageBox('Число записей не задано', 'Error');
                    CanReadFile := False;
                End
                Else If CanReadFile Then
                Begin
                    Readln(TxtFile, NumOfIter);
                    If (NumOfIter > 512) And (NumOfIter < 0) Then
                    Begin
                        Button1.Enabled := False;
                        Application.MessageBox
                          ('Число вне диапазона, F1 для помощи', 'Error');
                        CanReadFile := False
                    End
                    Else
                        SetLength(RecordsFromFile, NumOfIter)
                End;
                For I := 0 To NumOfIter - 1 Do
                Begin
                    For J := 1 To 4 Do
                    Begin
                        If EOF(TxtFile) And CanReadFile Then
                        Begin
                            Application.MessageBox
                              ('Не все элементы введены', 'Error');
                            CanReadFile := False
                        End
                        Else If CanReadFile Then
                        Begin
                            Case J Mod 4 Of
                                0:
                                    Begin
                                        Readln(TxtFile,
                                        MyRecordFromFile.ElemTeacher);
                                        If Length(MyRecordFromFile.
                                        ElemTeacher) > 14 Then
                                        Begin
                                            Application.MessageBox
                                              ('Не корректное заполнение файла, F1 для помощи', 'Error');
                                            CanReadFile := False;
                                        End;
                                    End;
                                1:
                                    Begin
                                        Readln(TxtFile,
                                        MyRecordFromFile.ElemDayOfWeek);
                                        If Not(MyRecordFromFile.ElemDayOfWeek =
                                        'Понедельник') And
                                        Not(MyRecordFromFile.ElemDayOfWeek =
                                        'Вторник') And
                                        Not(MyRecordFromFile.ElemDayOfWeek =
                                        'Среда') And
                                        Not(MyRecordFromFile.ElemDayOfWeek =
                                        'Четверг') And
                                        Not(MyRecordFromFile.ElemDayOfWeek =
                                        'Пятница') And
                                        Not(MyRecordFromFile.ElemDayOfWeek =
                                        'Суббота') Then
                                        Begin
                                            Application.MessageBox
                                              ('Не корректное заполнение файла, F1 для помощи', 'Error');
                                            CanReadFile := False;
                                        End;
                                    End;
                                2:
                                    Begin
                                        Readln(TxtFile,
                                        MyRecordFromFile.ElemNumOfLesson);
                                        If  Not(MyRecordFromFile.ElemNumOfLesson In  [1..6]) Then
                                        Begin
                                            Application.MessageBox
                                              ('Не корректное заполнение файла, F1 для помощи', 'Error');
                                            CanReadFile := False;
                                        End;
                                    End;
                                3:
                                    Begin
                                        Readln(TxtFile,
                                        MyRecordFromFile.ElemSubject);
                                        If Length(MyRecordFromFile.
                                        ElemTeacher) > 14 Then
                                        Begin
                                            Application.MessageBox
                                              ('Не корректное заполнение файла, F1 для помощи', 'Error');
                                            CanReadFile := False;
                                        End;
                                    End;
                            End;
                        End;
                    End;
                    If CanReadFile Then
                    Begin
                        For K := 0 To High(MyRecords) Do
                        Begin
                            CurRecord := MyRecords[K];
                            If (CurRecord.ElemTeacher = MyRecordFromFile.
                              ElemTeacher) And
                              (CurRecord.ElemDayOfWeek = MyRecordFromFile.
                              ElemDayOfWeek) And
                              (CurRecord.ElemNumOfLesson = MyRecordFromFile.
                              ElemNumOfLesson) Then
                            Begin
                                Application.MessageBox
                                  ('Один из элементов уже присутствует в записях',
                                  'Error');
                                CanReadFile := False
                            End
                        End;
                        For K := 0 To I - 1 Do
                        Begin
                            CurRecord := RecordsFromFile[K];
                            If (CurRecord.ElemTeacher = MyRecordFromFile.
                              ElemTeacher) And
                              (CurRecord.ElemDayOfWeek = MyRecordFromFile.
                              ElemDayOfWeek) And
                              (CurRecord.ElemNumOfLesson = MyRecordFromFile.
                              ElemNumOfLesson) Then
                            Begin
                                Application.MessageBox
                                  ('Запись в файле повторяется', 'Error');
                                CanReadFile := False
                            End
                        End;
                    End;
                    If CanReadFile Then
                        RecordsFromFile[I] := MyRecordFromFile;
                End;
                If CanReadFile Then
                Begin
                    For I := 0 To NumOfIter - 1 Do
                    Begin
                        Records.RowCount := Records.RowCount + 1;
                        Records.Cells[0, Records.RowCount - 1] :=
                          RecordsFromFile[I].ElemDayOfWeek;
                        Records.Cells[1, Records.RowCount - 1] :=
                          IntToStr(RecordsFromFile[I].ElemNumOfLesson);
                        Records.Cells[2, Records.RowCount - 1] :=
                          RecordsFromFile[I].ElemSubject;
                        Records.Cells[3, Records.RowCount - 1] :=
                          RecordsFromFile[I].ElemTeacher;
                    End;
                End;
            Except
                Application.MessageBox
                  ('Не корректное заполнение файла, F1 для помощи', 'Error');
                CanReadFile := False;
            End;
        End;
        CloseFile(TxtFile);
        If Records.RowCount > 1 Then
            BSave.Enabled := True
        Else
            BSave.Enabled := False
    End;
End;

Procedure TForm13.BSaveClick(Sender: TObject);
Var
    I, J: Integer;
    TxtFile: TextFile;
    CanReadFile, WantSave: Boolean;
    FileName: String;
    CurNum: Double;
Begin
    CanReadFile := True;
    OpenTextFileDialog1.Filter := 'Текстовый файл (*.txt)|*.txt';
    If OpenTextFileDialog1.Execute Then
    Begin
        FileName := OpenTextFileDialog1.FileName;
        If IsFileReadOnly(FileName) Then
        Begin
            Application.MessageBox('Файл не открыт для чтения', 'Error');
            CanReadFile := False;
        End;
        If Not SameText(ExtractFileExt(FileName), '.txt') And CanReadFile Then
        Begin
            CanReadFile := True;
            AssignFile(TxtFile, FileName + '.txt');
            Try
                Rewrite(TxtFile);
            Except
                Application.MessageBox('Не удалось открыть файл', 'Error');
                CanReadFile := False;
            End;
        End
        Else If CanReadFile Then
        Begin
            AssignFile(TxtFile, FileName);
            Try
                Rewrite(TxtFile);
            Except
                Application.MessageBox('Не удалось открыть файл', 'Error');
                CanReadFile := False;
            End;
        End;
        If CanReadFile Then
        Begin
            Writeln(TxtFile, IntToStr(Records.RowCount - 1));
            For J := 1 To Records.RowCount - 1 Do
            Begin
                Writeln(TxtFile, Records.Cells[0, J]);
                Writeln(TxtFile, Records.Cells[1, J]);
                Writeln(TxtFile, Records.Cells[2, J]);
                Writeln(TxtFile, Records.Cells[3, J]);
            End;
        End;
        CloseFile(TxtFile);
    End;
End;

Procedure TForm13.Button1Click(Sender: TObject);
Var
    NewForm: TForm14;
    I: Integer;
Begin
    DeleteRec.Enabled := False;
    I := 1;
    NewForm := TForm14.Create(Application);
    Try
        NewForm.WantEdit := False;
        NewForm.ShowModal;
        While (I < Records.RowCount) And
          (NewForm.CurRecord.ElemSubject <> '') Do
        Begin
            If (Records.Cells[0, I] = NewForm.CurRecord.ElemDayOfWeek) And
              (Records.Cells[1, I] = IntToStr(NewForm.CurRecord.ElemNumOfLesson)
              ) And (Records.Cells[3, I] = NewForm.CurRecord.ElemTeacher) Then
            Begin
                NewForm.CurRecord.ElemSubject := '';
                Application.MessageBox
                  ('Данная дата и занятие у выбранного пеподователя уже заняты',
                  'Предупреждение');
            End;
            Inc(I);
        End;
        If NewForm.CurRecord.ElemSubject <> '' Then
        Begin
            Records.RowCount := Records.RowCount + 1;
            Records.Cells[0, Records.RowCount - 1] :=
              NewForm.CurRecord.ElemDayOfWeek;
            Records.Cells[1, Records.RowCount - 1] :=
              IntToStr(NewForm.CurRecord.ElemNumOfLesson);
            Records.Cells[2, Records.RowCount - 1] :=
              NewForm.CurRecord.ElemSubject;
            Records.Cells[3, Records.RowCount - 1] :=
              NewForm.CurRecord.ElemTeacher;
        End;
    Finally
        NewForm.Free;
    End;
    If Records.RowCount = 1 Then
    Begin
        TeacherSch.Enabled := False;
        BSave.Enabled := False;
    End
    Else
    Begin
        TeacherSch.Enabled := True;
        BSave.Enabled := True;
    End;
End;

Procedure TForm13.TeacherSchClick(Sender: TObject);
Var
    NewForm: TForm15;
    I: Integer;
Begin
    DeleteRec.Enabled := False;
    NewForm := TForm15.Create(Application);
    Try
        SetLength(NewForm.AllRecords, Records.RowCount - 1);
        For I := 1 To Records.RowCount - 1 Do
        Begin
            NewForm.AllRecords[I - 1].ElemDayOfWeek := Records.Cells[0, I];
            NewForm.AllRecords[I - 1].ElemNumOfLesson :=
              StrToInt(Records.Cells[1, I]);
            NewForm.AllRecords[I - 1].ElemSubject := Records.Cells[2, I];
            NewForm.AllRecords[I - 1].ElemTeacher := Records.Cells[3, I];
        End;
        NewForm.ShowModal;
    Finally
        NewForm.Free;
    End;
End;

Procedure TForm13.DeleteRecClick(Sender: TObject);
Var
    I: Integer;
Begin
    With CreateMessageDialog('Вы действительно хотите удалить запись?',
      MtConfirmation, MbYesNo) Do
        Try
            Caption := 'Выход';
            TButton(FindComponent('Yes')).Caption := 'Да';
            TButton(FindComponent('No')).Caption := 'Нет';
            Case ShowModal Of
                MrYes:
                    Begin
                        For I := Records.Row To Records.RowCount - 2 Do
                        Begin
                            Records.Cells[0, I] := Records.Cells[0, I + 1];
                            Records.Cells[1, I] := Records.Cells[1, I + 1];
                            Records.Cells[2, I] := Records.Cells[2, I + 1];
                            Records.Cells[3, I] := Records.Cells[3, I + 1];
                        End;
                        Records.RowCount := Records.RowCount - 1;
                        If Records.RowCount = 1 Then
                        Begin
                            TeacherSch.Enabled := False;
                            BSave.Enabled := False;
                        End
                        Else
                        Begin
                            TeacherSch.Enabled := True;
                            BSave.Enabled := True;
                        End;
                    End;
            End;
        Finally
        End;

End;

Procedure TForm13.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Var
    CustomButtons: TMsgDlgButtons;
    Free: Boolean;
Begin
    CanClose := False;
    If Records.RowCount < 2 Then
    Begin
        With CreateMessageDialog('Вы действительно хотите закрыть программу?',
          MtConfirmation, MbYesNo) Do
            Try
                Caption := 'Выход';
                TButton(FindComponent('Yes')).Caption := 'Да';
                TButton(FindComponent('No')).Caption := 'Нет';
                Case ShowModal Of
                    MrYes:
                        CanClose := True;
                    MrNo:
                        CanClose := False;
                End;
            Finally
            End;
    End
    Else
    Begin
        With CreateMessageDialog('Cохранить перед выходом?', MtConfirmation,
          MbYesNoCancel) Do
            Try
                Caption := 'Выход';
                TButton(FindComponent('Yes')).Caption := 'Выход';
                TButton(FindComponent('No')).Caption := 'Сохранить';
                TButton(FindComponent('Cancel')).Caption := 'Отмена';
                Case ShowModal Of
                    MrYes:
                        CanClose := True;
                    MrCancel:
                        CanClose := False;
                    MrNo:
                        Begin
                            BSaveClick(BSave);
                            CanClose := False;
                        End;
                End;
            Finally
            End;
    End;
End;

Procedure TForm13.FormCreate(Sender: TObject);
Begin
    Records.Cells[0, 0] := 'День недели';
    Records.Cells[1, 0] := '№ занятия';
    Records.Cells[2, 0] := 'Предмет';
    Records.Cells[3, 0] := 'Преподователь';
End;

function TForm13.FormHelp(Command: Word; Data: NativeInt;
  var CallHelp: Boolean): Boolean;
begin
    CallHelp := False;
end;

procedure TForm13.InstructionsClick(Sender: TObject);
begin
    Application.MessageBox('Для добавления записей в таблицу вы можете воспользоваться кнопкой добавить или' + ' кнопкой файл->открыть. Для дополнения таблицы из файла' + ' необходимо в файле в первой'+' строке ввести количество вводимых записей,'+' затем в каждой новой строке нужно вводить новый элемент добавляемой записи'+'(День недели(c большой буквы) -> Номер ' + 'пары(1..6) -> Название предмета(< 15 символов) -> ' + 'Имя преподавателя(< 15 символов).', 'Помощь');
    Application.MessageBox('Для изменении'+' записи нажмите на нее в таблице.'+' Для получения расписания преподователя нажмите на кнопку Занятость. Для удаления записи ' + ' нажмите на нее в таблице и нажмите удалить. Для получения помощи нажмите F1', 'Помощь');
end;

Procedure TForm13.MyCellClick(Sender: TObject);
Var
    I: Integer;
    NewForm: TForm14;
Begin
    If Records.Row > 0 Then
    Begin
        NewForm := TForm14.Create(Application);
        Try
            NewForm.AddRec.Visible := False;
            NewForm.ChangeRecord.Visible := True;
            Case Records.Cells[0, Records.Row][1] Of
                'П':
                    Begin
                        If Records.Cells[0, Records.Row][2] = 'о' Then
                            NewForm.DayOfWeek.ItemIndex := 0
                        Else
                            NewForm.DayOfWeek.ItemIndex := 4
                    End;
                'В':
                    NewForm.DayOfWeek.ItemIndex := 1;
                'С':
                    Begin
                        If Records.Cells[0, Records.Row][2] = 'р' Then
                            NewForm.DayOfWeek.ItemIndex := 2
                        Else
                            NewForm.DayOfWeek.ItemIndex := 5
                    End;
                'Ч':
                    NewForm.DayOfWeek.ItemIndex := 3

            End;
            NewForm.LessonNum.ItemIndex :=
              StrToInt(Records.Cells[1, Records.Row]) - 1;
            NewForm.Subject.Text := Records.Cells[2, Records.Row];
            NewForm.Teacher.Text := Records.Cells[3, Records.Row];
            NewForm.ShowModal;
            If NewForm.CurRecord.ElemSubject <> '' Then
            Begin
                Records.Cells[0, Records.Row] :=
                  NewForm.CurRecord.ElemDayOfWeek;
                Records.Cells[1, Records.Row] :=
                  IntToStr(NewForm.CurRecord.ElemNumOfLesson);
                Records.Cells[2, Records.Row] := NewForm.CurRecord.ElemSubject;
                Records.Cells[3, Records.Row] := NewForm.CurRecord.ElemTeacher;
            End;
        Finally
            NewForm.Free;
        End;
    End;
End;

Procedure TForm13.RecordsSelectCell(Sender: TObject; ACol, ARow: Integer;
  Var CanSelect: Boolean);
Var
    MyCell: StringGridCracker;
Begin
    MyCell := StringGridCracker(Records);
    MyCell.OnDblClick := MyCellClick;
    If ARow > 0 Then
        DeleteRec.Enabled := True
    Else
        DeleteRec.Enabled := False;
End;

End.
