Unit FileUnit;

Interface

Uses
    GroupsLinkedListUnit, StudentLinkedListUnit, SysUtils, Vcl.Grids;

Type
    TGroupDataFile = File Of TGroupData;
    TStudentDataFile = File Of TStudentData;

Function IsCorrectFileData(Const TempGroupData: TGroupData;
  Const TempStudentData: TStudentData; Const IsGroup: Boolean): Boolean;
Function ReadFileData(Var InputGroupFile: TGroupDataFile;
  Var InputStudentsFile: TStudentDataFile; Var TempGroupList: PGroup; Var  TempStudentList: PStudent; IsGroup: Boolean): Boolean;
Procedure WriteFileData(Var OutputGroupFile: TGroupDataFile;
  Var OutputStudentFile: TStudentDataFile; Const GroupList: PGroup;
  Const StudentList: PStudent; IsGroup: Boolean);

Procedure RecordFileData(Var GroupList: PGroup; Const TempGroupList: PGroup; Var StudentsList: PStudent; Const TempStudentsList: PStudent;  GroupListStringGrid: TStringGrid);


Implementation

Uses
    InputEditUnit;

Function IsCorrectFileData(Const TempGroupData: TGroupData;
  Const TempStudentData: TStudentData; Const IsGroup: Boolean): Boolean;
Var
    BuffNumber: Integer;
    BuffString: String;
    IsCorrect: Boolean;
Begin
    If IsGroup Then
    Begin
        With TempGroupData Do
        Begin
            IsCorrect := (Length(IntToStr(GroupNumber)) = GROUP_LENGTH) And
              (Year < 2100) And (Year > 1000) And (Length(Code) = CODE_LENGTH)
              And (CountOfStudents < MAX_COUNT_OF_STUDENTS) And
              (CountOfStudents > -1);
        End;
    End
    Else
    Begin
        With TempStudentData Do
        Begin
            IsCorrect := (Length(IntToStr(GroupNumber)) = GROUP_LENGTH) And
              (Length(Name) < NAME_LENGTH) And (Length(Surname) < NAME_LENGTH)
              And (Length(Patronymic) < NAME_LENGTH) And (Marks[Logic] > 0) And
              (Marks[Logic] < 11) And (Marks[Algebra] > 0) And
              (Marks[Algebra] < 11) And (Marks[History] > 0) And
              (Marks[History] < 11) And (Marks[DM] > 0) And (Marks[DM] < 11) And
              (Marks[BAAP] > 0) And (Marks[BAAP] < 11) And (Marks[BPE] > 0) And
              (Marks[BPE] < 11) And (AvgMark > 0) And (AvgMark < 11);
        End;
    End;
    IsCorrectFileData := IsCorrect;
End;

Function ReadFileData(Var InputGroupFile: TGroupDataFile;
  Var InputStudentsFile: TStudentDataFile; Var TempGroupList: PGroup;
Var  TempStudentList: PStudent; IsGroup: Boolean): Boolean;
Var
    IsCorrect: Boolean;
    GroupCount: Integer;
    TempGroupData: TGroupData;
    TempStudentData: TStudentData;
Begin
    If IsGroup Then
    Begin

        Reset(InputGroupFile);
        IsCorrect := True;
        GroupCount := 0;
        While IsCorrect And (GroupCount < MAX_COUNT_OF_GROUPS) And
          Not EOF(InputGroupFile) Do
        Begin
            Read(InputGroupFile, TempGroupData);
            IsCorrect := IsCorrectFileData(TempGroupData, TempStudentData, True)
              And Not IsExistGroup(TempGroupList, TempGroupData);
            If IsCorrect Then
            Begin
                AddGroup(TempGroupList, TempGroupData);
                Inc(GroupCount);
            End;
        End;
        If IsCorrect Then
            IsCorrect := GroupCount <= MAX_COUNT_OF_GROUPS;
        CloseFile(InputGroupFile);
    End
    Else
    Begin
        
        Reset(InputStudentsFile);
        IsCorrect := True;
        While IsCorrect And Not EOF(InputStudentsFile) Do
        Begin
            Read(InputStudentsFile, TempStudentData);
            IsCorrect := IsCorrectFileData(TempGroupData, TempStudentData,
              False) And Not IsExistStudent(TempStudentList, TempStudentData);
            If IsCorrect Then
            Begin
                AddStudent(TempStudentList, TempStudentData);
               // AddStudentToGroup(TempGroupList, TempStudentData.GroupNumber);
            End;
        End;
        CloseFile(InputStudentsFile);
    End;
    ReadFileData := IsCorrect;
End;

Procedure RecordFileData(Var GroupList: PGroup; Const TempGroupList: PGroup; Var StudentsList: PStudent; Const TempStudentsList: PStudent;  GroupListStringGrid: TStringGrid);
Begin
    StudentsList := TempStudentsList;
    GroupList := TempGroupList;
    GroupListStringGrid.RowCount := CountGroups(GroupList) + 1;
    DrawGroupGrid(GroupListStringGrid, GroupList);
End;

Procedure WriteFileData(Var OutputGroupFile: TGroupDataFile;
  Var OutputStudentFile: TStudentDataFile; Const GroupList: PGroup;
  Const StudentList: PStudent; IsGroup: Boolean);
Var
    CurrGroup: PGroup;
    CurrStudent: PStudent;
Begin
    If IsGroup Then
    Begin
        Rewrite(OutputGroupFile);
        CurrGroup := GroupList;
        While CurrGroup <> Nil Do
        Begin
            Write(OutputGroupFile, CurrGroup^.Data);
            CurrGroup := CurrGroup^.Next;
        End;
        CloseFile(OutputGroupFile);
    End
    Else
    Begin
        Rewrite(OutputStudentFile);
        CurrStudent := StudentList;
        While CurrStudent <> Nil Do
        Begin
            Write(OutputStudentFile, CurrStudent^.Data);
            CurrStudent := CurrStudent^.Next;
        End;
        CloseFile(OutputStudentFile);
    End;
End;

End.
