Unit StudentLinkedListUnit;

Interface

Uses
    Vcl.Grids, Vcl.StdCtrls, SysUtils;

Const
    NAME_LENGTH = 15;

Type
    Diciplines = (Logic, Algebra, History, DM, BAAP, BPE);
    TNameString = String[NAME_LENGTH];
    TDicipline = Array [Diciplines] Of Integer;
    TGroupNumber = Integer;

    TStudentData = Record
        GroupNumber: TGroupNumber;
        Surname: TNameString;
        Name: TNameString;
        Patronymic: TNameString;
        Marks: TDicipline;
        AvgMark: Real;
    End;

    PStudent = ^TStudent;

    TStudent = Record
        Data: TStudentData;
        Next: PStudent;
    End;

Procedure DeleteStudentsInGroup(GroupNumber: Integer;
  Var StudentList: PStudent);
Procedure DrawMarksGrid(Var MarkGrid: TStringGrid);
Procedure AddStudent(Var StudentList: PStudent;
  Const StudentData: TStudentData);
Function IsExistStudent(Const StudentList: PStudent;
  Const StudentData: TStudentData): Boolean;
Procedure DrawStudentsInGroupGrid(Var StudentsInGroupGrid: TStringGrid;
  StudentsList: PStudent; CurrentGroup: Integer);
Function IsStudentDataEqual(Const StudentData1, StudentData2
  : TStudentData): Boolean;
Procedure DeleteStudent(Var StudentList: PStudent;
  Const StudentData: TStudentData);
Function IsExistStudentNSP(Const StudentList: PStudent;
  Name, Surname, Patronymic: TNameString): Boolean;
Function SearchStudentNSP(StudentList: PStudent;
  Name, Surname, Patronymic: TNameString): PStudent;
Function FindExpellStudents(Const StudentsList: PStudent): PStudent;
Function FindDeptStudents(StudentsList: PStudent; CurrDicipline: Integer)
  : PStudent;
Procedure ClearStudentGrid(Var StudentsGrid: TStringGrid);
Procedure ClearStudents(Var StudentList: PStudent);

Implementation

Uses
    MainMenuUnit, GroupsLinkedListUnit;

Function FindExpellStudents(Const StudentsList: PStudent): PStudent;
Var
    CurrStudent: PStudent;
    ExpellStudents: PStudent;
    Count, I: Integer;
Begin
    ExpellStudents := Nil;
    CurrStudent := StudentsList;
    Count := 0;
    While CurrStudent <> Nil Do
    Begin

        With CurrStudent^.Data Do
        Begin
            If Marks[Logic] < 4 Then
                Inc(Count);
            If Marks[Algebra] < 4 Then
                Inc(Count);
            If Marks[History] < 4 Then
                Inc(Count);
            If Marks[BAAP] < 4 Then
                Inc(Count);
            If Marks[BPE] < 4 Then
                Inc(Count);
            If Marks[DM] < 4 Then
                Inc(Count);
            If Count > 2 Then
            Begin
                AddStudent(ExpellStudents, CurrStudent^.Data)
            End;

        End;
        CurrStudent := CurrStudent^.Next;
        Count := 0;
    End;

    FindExpellStudents := ExpellStudents;
End;
Procedure ClearStudents(Var StudentList: PStudent);//очистка студентов +
Var
    CurrStudent, TempStudent: Pstudent;
Begin
    CurrStudent := StudentList;
    While CurrStudent <> Nil Do
    Begin
        TempStudent := CurrStudent;
        CurrStudent := CurrStudent^.Next;
        Dispose(TempStudent);
    End;
    StudentList := Nil;
End;


Procedure DeleteStudent(Var StudentList: PStudent;
  Const StudentData: TStudentData);
Var
    CurrStudent, TempStudent: PStudent;
Begin
    CurrStudent := StudentList;
    If IsStudentDataEqual(CurrStudent^.Data, StudentData) Then
    Begin
        StudentList := CurrStudent^.Next;
        Dispose(CurrStudent);
    End
    Else
    Begin
        While Not IsStudentDataEqual(CurrStudent^.Next^.Data, StudentData) Do
            CurrStudent := CurrStudent^.Next;
        TempStudent := CurrStudent^.Next;
        CurrStudent^.Next := CurrStudent^.Next^.Next;
        Dispose(TempStudent);
    End;
End;

Procedure DeleteStudentsInGroup(GroupNumber: Integer;
  Var StudentList: PStudent);
Var
    CurrStudent, TempStudent: PStudent;
Begin
    CurrStudent := StudentList;
    If CurrStudent <> Nil Then
    Begin
        If (CurrStudent^.Data.GroupNumber = GroupNumber) Then
        Begin
            StudentList := CurrStudent^.Next;
            Dispose(CurrStudent);
        End
        Else
        Begin
            While CurrStudent <> Nil Do
            Begin
                If CurrStudent^.Next^.Data.GroupNumber = GroupNumber Then
                Begin
                    CurrStudent := CurrStudent^.Next;
                    TempStudent := CurrStudent^.Next;
                    CurrStudent^.Next := CurrStudent^.Next^.Next;
                    Dispose(TempStudent);
                End;
            End;
        End;
    End;

End;

Function CreateStudent(Const StudentData: TStudentData): PStudent;
Var
    NewStudent: PStudent;
Begin
    New(NewStudent);
    NewStudent^.Data := StudentData;
    NewStudent^.Next := Nil;
    CreateStudent := NewStudent;
End;

Procedure AddStudent(Var StudentList: PStudent;
  Const StudentData: TStudentData);
Var
    NewStudent, CurrStudent: PStudent;
Begin
    NewStudent := CreateStudent(StudentData);
    If StudentList = Nil Then
        StudentList := NewStudent
    Else
    Begin
        CurrStudent := StudentList;
        While CurrStudent^.Next <> Nil Do
            CurrStudent := CurrStudent^.Next;
        CurrStudent^.Next := NewStudent;
    End;
End;

Function IsStudentDataEqual(Const StudentData1, StudentData2
  : TStudentData): Boolean;
Var
    IsEqual: Boolean;
Begin
    IsEqual := (StudentData1.GroupNumber = StudentData2.GroupNumber) And
      (StudentData1.Name = StudentData2.Name) And
      (StudentData1.Surname = StudentData2.Surname) And
      (StudentData1.Patronymic = StudentData2.Patronymic) And
      (StudentData1.Marks[Logic] = StudentData2.Marks[Logic]) And
      (StudentData1.Marks[Algebra] = StudentData2.Marks[Algebra]) And
      (StudentData1.Marks[DM] = StudentData2.Marks[DM]) And
      (StudentData1.Marks[History] = StudentData2.Marks[History]) And
      (StudentData1.Marks[BAAP] = StudentData2.Marks[BAAP]) And
      (StudentData1.Marks[BPE] = StudentData2.Marks[BPE]);
    IsStudentDataEqual := IsEqual;
End;

Function IsExistStudent(Const StudentList: PStudent;
  Const StudentData: TStudentData): Boolean;
Var
    CurrStudent: PStudent;
    IsExist: Boolean;
Begin

    CurrStudent := StudentList;
    IsExist := False;
    If CurrStudent <> Nil Then
        Repeat
            IsExist := IsStudentDataEqual(CurrStudent^.Data, StudentData);
            CurrStudent := CurrStudent^.Next
        Until (IsExist) Or (CurrStudent = Nil);
    IsExistStudent := IsExist;

End;

Procedure DrawMarksGrid(Var MarkGrid: TStringGrid);
Begin
    With MarkGrid Do
    Begin
        Height := (DefaultRowHeight * 2) + 6;
        Cells[0, 0] := 'Логика';
        Cells[1, 0] := 'ЛАиАГ';
        Cells[2, 0] := 'История';
        ColWidths[2] := 130;
        Cells[3, 0] := 'ДМ';
        ColWidths[3] := 70;
        Cells[4, 0] := 'ОАиП';
        Cells[5, 0] := 'ОПИ';
        ScrollBars := TScrollStyle.SsNone;
    End;
End;

Function IsStudentDataEqualNSP(Const StudentData1: TStudentData;
  Name, Surname, Patronymic: TNameString): Boolean;
Var
    IsEqual: Boolean;
Begin
    IsEqual := (StudentData1.Name = Name) And (StudentData1.Surname = Surname)
      And (StudentData1.Patronymic = Patronymic);
    IsStudentDataEqualNSP := IsEqual;
End;

Function IsExistStudentNSP(Const StudentList: PStudent;
  Name, Surname, Patronymic: TNameString): Boolean;
Var
    CurrStudent: PStudent;
    IsExist: Boolean;
Begin

    CurrStudent := StudentList;
    IsExist := False;
    If CurrStudent <> Nil Then
        Repeat
            IsExist := IsStudentDataEqualNSP(CurrStudent^.Data, Name, Surname,
              Patronymic);
            CurrStudent := CurrStudent^.Next
        Until (IsExist) Or (CurrStudent = Nil);
    IsExistStudentNSP := IsExist;

End;

Function SearchStudentNSP(StudentList: PStudent;
  Name, Surname, Patronymic: TNameString): PStudent;
Var
    NewStudent: PStudent;
Begin
    NewStudent := StudentList;
    If IsExistStudentNSP(StudentList, Name, Surname, Patronymic) Then
    Begin
        While Not IsStudentDataEqualNSP(NewStudent^.Data, Name, Surname,
          Patronymic) Do
            NewStudent := NewStudent^.Next;

        SearchStudentNSP := NewStudent;

    End;
End;

Procedure ClearStudentGrid(Var StudentsGrid: TStringGrid);
Begin
    With StudentsGrid Do
    Begin
        RowCount := 1;
        ColCount := 11;
        Cells[0, 0] := 'Номер Группы';
        Cells[1, 0] := 'Фамилия';
        Cells[2, 0] := 'Имя';
        Cells[3, 0] := 'Отчество';
        Cells[4, 0] := 'Логика';
        Cells[5, 0] := 'ЛАиАГ';
        Cells[6, 0] := 'История';
        Cells[7, 0] := 'ДМ';
        Cells[8, 0] := 'ОАиП';
        Cells[9, 0] := 'ОПИ';
        Cells[10, 0] := 'Средний балл';
        ColWidths[0] := 150;
        ColWidths[1] := 160;
        ColWidths[2] := 180;
        ColWidths[3] := 170;
        ColWidths[10] := 170;
        RowCount := 1;
    End;
End;

Function FindDeptStudents(StudentsList: PStudent; CurrDicipline: Integer)
  : PStudent;
Var
    CurrStudent: PStudent;
    CurrDic: Diciplines;
    NewStudent: PStudent;
Begin
    CurrStudent := StudentsList;
    NewStudent := Nil;
    Case CurrDicipline Of
        1:
            CurrDic := Logic;
        2:
            CurrDic := Algebra;
        3:
            CurrDic := History;
        4:
            CurrDic := DM;
        5:
            CurrDic := BAAP;
        6:
            CurrDic := BPE;
    End;
    While CurrStudent <> Nil Do
    Begin
        If CurrStudent^.Data.Marks[CurrDic] < 4 Then
            AddStudent(NewStudent, CurrStudent^.Data);
        CurrStudent := CurrStudent^.Next;
    End;
    FindDeptStudents := NewStudent;
End;

Procedure DrawStudentsInGroupGrid(Var StudentsInGroupGrid: TStringGrid;
  StudentsList: PStudent; CurrentGroup: Integer);
Var
    CurrStudent: PStudent;
    CurrRow: Integer;
Begin

    With StudentsInGroupGrid Do
    Begin
        ColCount := 11;
        Cells[0, 0] := 'Номер Группы';
        Cells[1, 0] := 'Фамилия';
        Cells[2, 0] := 'Имя';
        Cells[3, 0] := 'Отчество';
        Cells[4, 0] := 'Логика';
        Cells[5, 0] := 'ЛАиАГ';
        Cells[6, 0] := 'История';
        Cells[7, 0] := 'ДМ';
        Cells[8, 0] := 'ОАиП';
        Cells[9, 0] := 'ОПИ';
        Cells[10, 0] := 'Средний балл';
        ColWidths[0] := 150;
        ColWidths[1] := 160;
        ColWidths[2] := 180;
        ColWidths[3] := 170;
        ColWidths[10] := 170;
    End;

    CurrStudent := StudentsList;
    CurrRow := 1;
    If (CurrentGroup = 0) Or (CurrentGroup = 1) Then
    Begin
        If CurrentGroup = 1 Then
        Begin
            While CurrStudent <> Nil Do
            Begin
                With StudentsInGroupGrid, CurrStudent^.Data Do
                Begin
                    Cells[0, CurrRow] := IntToStr(GroupNumber);
                    Cells[1, CurrRow] := String(Surname);
                    Cells[2, CurrRow] := String(Name);
                    Cells[3, CurrRow] := String(Patronymic);
                    Cells[4, CurrRow] := IntToStr(Marks[Logic]);
                    Cells[5, CurrRow] := IntToStr(Marks[Algebra]);
                    Cells[6, CurrRow] := IntToStr(Marks[History]);
                    Cells[7, CurrRow] := IntToStr(Marks[DM]);
                    Cells[8, CurrRow] := IntToStr(Marks[BAAP]);
                    Cells[9, CurrRow] := IntToStr(Marks[BPE]);
                    Cells[10, CurrRow] := FloatToStr(AvgMark);
                    Inc(CurrRow);

                End;
                CurrStudent := CurrStudent^.Next;
            End;
            StudentsInGroupGrid.RowCount := CurrRow;
            If StudentsInGroupGrid.RowCount > 10 Then
            Begin
                StudentsInGroupGrid.ScrollBars := TScrollStyle.SsVertical;
                StudentsInGroupGrid.Height := 400
            End
            Else
            Begin
                StudentsInGroupGrid.ScrollBars := TScrollStyle.SsNone;
                StudentsInGroupGrid.Height :=
                  (StudentsInGroupGrid.DefaultRowHeight +
                  StudentsInGroupGrid.GridLineWidth) *
                  StudentsInGroupGrid.RowCount + 5;
            End;
        End
        Else
        Begin
            If CurrStudent <> Nil Then
            Begin
                With StudentsInGroupGrid, CurrStudent^.Data Do
                Begin
                    Cells[0, CurrRow] := IntToStr(GroupNumber);
                    Cells[1, CurrRow] := String(Surname);
                    Cells[2, CurrRow] := String(Name);
                    Cells[3, CurrRow] := String(Patronymic);
                    Cells[4, CurrRow] := IntToStr(Marks[Logic]);
                    Cells[5, CurrRow] := IntToStr(Marks[Algebra]);
                    Cells[6, CurrRow] := IntToStr(Marks[History]);
                    Cells[7, CurrRow] := IntToStr(Marks[DM]);
                    Cells[8, CurrRow] := IntToStr(Marks[BAAP]);
                    Cells[9, CurrRow] := IntToStr(Marks[BPE]);
                    Cells[10, CurrRow] := FloatToStr(AvgMark);
                    RowCount := 2;
                End;
            End;
        End;

    End
    Else
    Begin
        While CurrStudent <> Nil Do
        Begin
            With StudentsInGroupGrid, CurrStudent^.Data Do
            Begin
                If GroupNumber = CurrentGroup Then
                Begin
                    Cells[0, CurrRow] := IntToStr(GroupNumber);
                    Cells[1, CurrRow] := String(Surname);
                    Cells[2, CurrRow] := String(Name);
                    Cells[3, CurrRow] := String(Patronymic);
                    Cells[4, CurrRow] := IntToStr(Marks[Logic]);
                    Cells[5, CurrRow] := IntToStr(Marks[Algebra]);
                    Cells[6, CurrRow] := IntToStr(Marks[History]);
                    Cells[7, CurrRow] := IntToStr(Marks[DM]);
                    Cells[8, CurrRow] := IntToStr(Marks[BAAP]);
                    Cells[9, CurrRow] := IntToStr(Marks[BPE]);
                    Cells[10, CurrRow] := FloatToStr(AvgMark);
                    Inc(CurrRow);
                End;
            End;
            CurrStudent := CurrStudent^.Next;
        End;
        If StudentsInGroupGrid.RowCount > 10 Then
        Begin
            StudentsInGroupGrid.ScrollBars := TScrollStyle.SsVertical;
            StudentsInGroupGrid.Height := 400
        End
        Else
        Begin
            StudentsInGroupGrid.ScrollBars := TScrollStyle.SsNone;
            StudentsInGroupGrid.Height :=
              (StudentsInGroupGrid.DefaultRowHeight +
              StudentsInGroupGrid.GridLineWidth) *
              StudentsInGroupGrid.RowCount + 5;
        End;
    End;

End;

End.
