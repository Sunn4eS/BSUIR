Unit GroupsLinkedListUnit;

Interface

Uses
    GroupListActionUnit, InputEditUnit, StudentLinkedListUnit, VCL.Grids,
    SysUtils, VCL.StdCtrls;

Type
    TGroupNumber = Integer;
    TYear = Integer;
    TCodeString = String[CODE_LENGTH];

    TGroupData = Record
        GroupNumber: TGroupNumber;
        Year: TYear;
        Code: TCodeString;
        CountOfStudents: Integer;
    End;

    PGroup = ^TGroup;

    TGroup = Record
        Data: TGroupData;
        Next: PGroup;
    End;

Const
    MAX_COUNT_OF_STUDENTS = 40;
    MAX_COUNT_OF_GROUPS = 50;
Function IsExistGroup(Const GroupList: PGroup;
  Const GroupData: TGroupData): Boolean;
Procedure AddGroup(Var GroupList: PGroup; Const GroupData: TGroupData);
Function CreateGroup(Const GroupData: TGroupData): PGroup;
Function IsGroupDataEqual(Const GroupData1, GroupData2: TGroupData): Boolean;
Procedure DrawGroupGrid(Var GroupGrid: TStringGrid; GroupList: PGroup);
Function CountGroups(Const GroupList: PGroup): Integer;
Function FindCountInGroup(Const GroupList: PGroup;     CurrGroupNumber: Integer): Integer;
Procedure AddStudentToGroup(Var GroupList: PGroup; CurrGroupNumber: Integer);
Procedure DeleteGroupF(Var GroupList: PGroup; Const GroupData: TGroupData;  Var StudentList: PStudent);
Procedure DeleteOneStudent(Var GroupList: PGroup; CurrGroupNumber: Integer);
Procedure EditGroup(Const GroupList: PGroup; Const OldGroupData, NewGroupData: TGroupData; Var StudentList: PStudent);
Function IsExistGroupByNumber(Const GroupList: PGroup; CurrGroupNumber: Integer): Boolean;
Procedure EditStudent(Var GroupList: PGroup; Const OldStudentData, NewStudentData: TStudentData;
  Var StudentsList: PStudent);
Procedure ClearGroups(Var GroupList: PGroup);

Implementation

Function SearchGroup(Const GroupList: PGroup;
  Const GroupData: TgroupData): PGroup;
Var
    CurrGroup: PGroup;
Begin
    CurrGroup := GroupList;
    While Not IsGroupDataEqual(CurrGroup^.Data, GroupData) Do
        CurrGroup := CurrGroup^.Next;
    SearchGroup := CurrGroup;
End;

Procedure EditGroup(Const GroupList: PGroup;
  Const OldGroupData, NewGroupData: TGroupData; Var StudentList: PStudent);
Var
    CurrGroup: PGroup;
    CurrStudent: PStudent;
    PrevGroupNumber: Integer;
    PrevCountOfStudents: Integer;
    NewGroupNumber: Integer;
Begin
    PrevGroupNumber := OldGroupData.GroupNumber;
    PrevCountOfStudents := OldGroupData.CountOfStudents;
    CurrGroup := SearchGroup(GroupList, OldGroupData);

    CurrGroup^.Data := NewGroupData;
    CurrGroup^.Data.CountOfStudents := PrevCountOfStudents;
    NewGroupNumber := NewGroupData.GroupNumber;

    CurrStudent := StudentList;
    While CurrStudent <> Nil Do
    Begin
        If (CurrStudent^.Data.GroupNumber = PrevGroupNumber) Then
        Begin
            CurrStudent^.Data.GroupNumber := NewGroupNumber;
        End;
        CurrStudent := CurrStudent^.Next;
    End;
End;

Function IsExistGroupByNumber(Const GroupList: PGroup;
  CurrGroupNumber: Integer): Boolean;
Var
    CurrGroup: PGroup;
    IsExist: Boolean;
Begin
    CurrGroup := GroupList;

    IsExist := False;
    If CurrGroup <> Nil Then
        Repeat
            IsExist := CurrGroup^.Data.GroupNumber = CurrGroupNumber;
            CurrGroup := CurrGroup^.Next
        Until (IsExist) Or (CurrGroup = Nil);

    IsExistGroupByNumber := IsExist;
End;

Function SearchStudent(Const StudentList: PStudent;
  Const StudentData: TStudentData): PStudent;
Var
    CurrStudent: PStudent;
Begin
    CurrStudent := StudentList;
    While Not IsStudentDataEqual(CurrStudent^.Data, StudentData) And
      (CurrStudent <> Nil) Do
        CurrStudent := CurrStudent^.Next;
    SearchStudent := CurrStudent;
End;

Function SearchGroupByNumber(Const GroupList: PGroup; CurrGroupNumber: Integer)
  : TGroupData;
Var
    CurrGroup: PGroup;
    IsExist: Boolean;
Begin
    CurrGroup := GroupList;

    IsExist := False;
    If CurrGroup <> Nil Then
        Repeat
            IsExist := CurrGroup^.Data.GroupNumber = CurrGroupNumber;
            CurrGroup := CurrGroup^.Next
        Until (IsExist) Or (CurrGroup = Nil);

    SearchGroupByNumber := CurrGroup^.Data;
End;

Procedure EditStudent(Var GroupList: PGroup;
  Const OldStudentData, NewStudentData: TStudentData;
  Var StudentsList: PStudent);
Var
    PrevGroupNumber: Integer;
    PrevCountOfStudents: Integer;
    NewGroupNumber: Integer;
    CurrGroup: PGroup;
    CurrStudent: PStudent;
    NewGroupData: TGroupdata;
Begin
    PrevGroupNumber := OldStudentData.GroupNumber;
    NewGroupNumber := NewStudentData.GroupNumber;
    CurrStudent := SearchStudent(StudentsList, OldStudentData);
    // if PrevGroupNumber <> NewGroupNumber then
    Begin
        // NewGroupData := SearchGroupByNumber(GroupList, NewGroupNumber);
        AddStudent(StudentsList, NewStudentData);
        AddStudentToGroup(GroupList, NewGroupNumber);

        DeleteOneStudent(GroupList, PrevGroupNumber);
        DeleteStudent(StudentsList, OldStudentData);

    End

End;

Procedure DeleteOneStudent(Var GroupList: PGroup; CurrGroupNumber: Integer);
Var
    CurrGroup: PGroup;
    NewCount: Integer;
Begin
    CurrGroup := GroupList;
    While (CurrGroup <> Nil) And
      (CurrGroup^.Data.GroupNumber <> CurrGroupNumber) Do
    Begin
        CurrGroup := CurrGroup^.Next;
    End;
    Dec(CurrGroup^.Data.CountOfStudents);
End;

Procedure ClearGroups(Var GroupList: PGroup);//очистка студентов +
Var
    CurrGroup, TempGroup: PGroup;
Begin
    CurrGroup := GroupList;
    While CurrGroup <> Nil Do
    Begin
        TempGroup := CurrGroup;
        CurrGroup := CurrGroup^.Next;
        Dispose(TempGroup);
    End;
    GroupList := Nil;
End;

Procedure DeleteGroupF(Var GroupList: PGroup; Const GroupData: TGroupData;
  Var StudentList: PStudent);
Var
    CurrGroup, TempGroup: PGroup;
Begin
    CurrGroup := GroupList;
    If IsGroupDataEqual(CurrGroup^.Data, GroupData) Then
    Begin
        DeleteStudentsInGroup(GroupList^.Data.GroupNumber, StudentList);
        GroupList := CurrGroup^.Next;
        Dispose(CurrGroup);
    End
    Else
    Begin
        While Not IsGroupDataEqual(CurrGroup^.Next^.Data, GroupData) Do
            CurrGroup := CurrGroup^.Next;
        TempGroup := CurrGroup^.Next;

        DeleteStudentsInGroup(TempGroup^.Data.GroupNumber, StudentList);
        CurrGroup^.Next := CurrGroup^.Next^.Next;
        Dispose(TempGroup);
    End;
End;

Procedure AddStudentToGroup(Var GroupList: PGroup; CurrGroupNumber: Integer);
Var
    CurrGroup: PGroup;
    NewCount: Integer;
Begin
    CurrGroup := GroupList;
    While (CurrGroup <> Nil) And
      (CurrGroup^.Data.GroupNumber <> CurrGroupNumber) Do
    Begin
        CurrGroup := CurrGroup^.Next;
    End;
    Inc(CurrGroup^.Data.CountOfStudents);

End;

Function FindCountInGroup(Const GroupList: PGroup;
  CurrGroupNumber: Integer): Integer;
Var
    CurrGroup: PGroup;
    Count: Integer;
Begin
    CurrGroup := GroupList;
    Count := -1;
    While (CurrGroup <> Nil) And (Count = -1) Do
    Begin
        If (CurrGroup^.Data.GroupNumber = CurrGroupNumber) Then
            Count := CurrGroup^.Data.CountOfStudents;
        CurrGroup := CurrGroup^.Next;
    End;
    FindCountInGroup := Count;
End;

Function CreateGroup(Const GroupData: TGroupData): PGroup;
Var
    NewGroup: PGroup;
Begin
    New(NewGroup);
    NewGroup^.Data := GroupData;
    NewGroup^.Next := Nil;
    CreateGroup := NewGroup;
End;

Procedure AddGroup(Var GroupList: PGroup; Const GroupData: TGroupData);
Var
    NewGroup, CurrGroup: PGroup;
Begin
    NewGroup := CreateGroup(GroupData);
    If GroupList = Nil Then
        GroupList := NewGroup
    Else
    Begin
        CurrGroup := GroupList;
        While CurrGroup^.Next <> Nil Do
            CurrGroup := CurrGroup^.Next;
        CurrGroup^.Next := NewGroup;
    End;
End;

Function IsGroupDataEqual(Const GroupData1, GroupData2: TGroupData): Boolean;
Begin
    IsGroupDataEqual := (GroupData1.GroupNumber = GroupData2.GroupNumber)
End;

Function IsExistGroup(Const GroupList: PGroup;
  Const GroupData: TGroupData): Boolean;
Var
    CurrGroup: PGroup;
    IsExist: Boolean;
Begin
    CurrGroup := GroupList;
    IsExist := False;
    If CurrGroup <> Nil Then
        Repeat
            IsExist := IsGroupDataEqual(CurrGroup^.Data, GroupData);
            CurrGroup := CurrGroup^.Next
        Until (IsExist) Or (CurrGroup = Nil);
    IsExistGroup := IsExist;

End;

Function CountGroups(Const GroupList: PGroup): Integer;
Var
    CurrGroup: PGroup;
    GroupCount: Integer;
Begin
    CurrGroup := GroupList;
    GroupCount := 0;
    While CurrGroup <> Nil Do
    Begin
        Inc(GroupCount);
        CurrGroup := CurrGroup^.Next;
    End;
    CountGroups := GroupCount;
End;

Procedure DrawGroupGrid(Var GroupGrid: TStringGrid; GroupList: PGroup);
Var
    CurrGroup: PGroup;
    CurrRow: Integer;
Begin
    With GroupGrid Do
    Begin
        Width := 660;
        Cells[0, 0] := 'Номер Группы';
        Cells[1, 0] := 'Год образования';
        Cells[2, 0] := 'Код специальности';
        Cells[3, 0] := 'Число стдудентов';
        ColWidths[0] := 150;
        ColWidths[1] := 160;
        ColWidths[2] := 180;
        ColWidths[3] := 170;
    End;

    CurrGroup := GroupList;
    CurrRow := 1;
    While CurrGroup <> Nil Do
    Begin
        With GroupGrid, CurrGroup^.Data Do
        Begin
            Cells[0, CurrRow] := IntToStr(GroupNumber);
            Cells[1, CurrRow] := IntToStr(Year);
            Cells[2, CurrRow] := String(Code);
            Cells[3, CurrRow] := IntToStr(CountOfStudents);
        End;
        Inc(CurrRow);
        CurrGroup := CurrGroup^.Next;
    End;

    If GroupGrid.RowCount > 10 Then
    Begin
        GroupGrid.ScrollBars := TScrollStyle.SsVertical;
        GroupGrid.Height := 400
    End
    Else
    Begin
        GroupGrid.ScrollBars := TScrollStyle.SsNone;
        GroupGrid.Height :=
          (GroupGrid.DefaultRowHeight + GroupGrid.GridLineWidth) *
          GroupGrid.RowCount + 5;

    End;

End;

End.
