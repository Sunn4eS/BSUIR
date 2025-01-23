Unit Unit155;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls, Vcl.Menus;

Type
    ScheduleInfo = Record
        ElemSubject: String;
        ElemTeacher: String;
        ElemDayOfWeek: String;
        ElemNumOfLesson: Byte;
    End;

    ScheduleInfoArr = Array Of ScheduleInfo;

    TForm15 = Class(TForm)
        Label1: TLabel;
        Schedule: TStringGrid;
        TeachName: TEdit;
        Label2: TLabel;
        Fill: TButton;
    MainMenu1: TMainMenu;
    gg: TMenuItem;
    N1: TMenuItem;
    PopupMenu1: TPopupMenu;
    ShiftBlocker: TMenuItem;
        Procedure FormCreate(Sender: TObject);
        Procedure TeachNameKeyPress(Sender: TObject; Var Key: Char);
        Procedure TeachNameChange(Sender: TObject);
        Procedure FillClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    Private
    Public
        AllRecords: ScheduleInfoArr;
    End;

Var
    Form15: TForm15;

Implementation

{$R *.dfm}

Procedure TForm15.TeachNameChange(Sender: TObject);
Begin
    If (TeachName.Text <> '') Then
        Fill.Enabled := True
    Else
        Fill.Enabled := False
End;

Procedure TForm15.TeachNameKeyPress(Sender: TObject; Var Key: Char);
Begin
    If ((Length(TeachName.Text) > 19) And (Key <> #8)) Or
      (Key In ['0' .. '9']) Then
        Key := #0;
End;

Procedure TForm15.FillClick(Sender: TObject);
Var
    I: Integer;
    HaveTeacher: Boolean;
    J: Integer;
Begin
    HaveTeacher := False;
    For I := 1 To 6 Do
        For J := 1 To 6 Do
            Schedule.Cells[I, J] := '';
    For I := Low(AllRecords) To High(AllRecords) Do
    Begin
        Case AllRecords[I].ElemDayOfWeek[1] Of
            'П':
                Begin
                    If AllRecords[I].ElemDayOfWeek[2] = 'о' Then
                        AllRecords[I].ElemDayOfWeek := '1'
                    Else
                        AllRecords[I].ElemDayOfWeek := '5'
                End;
            'В':
                AllRecords[I].ElemDayOfWeek := '2';
            'С':
                Begin
                    If AllRecords[I].ElemDayOfWeek[2] = 'р' Then
                        AllRecords[I].ElemDayOfWeek := '3'
                    Else
                        AllRecords[I].ElemDayOfWeek := '6'
                End;
            'Ч':
                AllRecords[I].ElemDayOfWeek := '4';

        End;
        If AllRecords[I].ElemTeacher = TeachName.Text Then
        Begin
            HaveTeacher := True;
            Schedule.Cells[StrToInt(AllRecords[I].ElemDayOfWeek),
              AllRecords[I].ElemNumOfLesson] := AllRecords[I].ElemSubject;
        End;
    End;
    If HaveTeacher = False Then
        Application.MessageBox('Данный учитель не найден', 'Предупреждение');

End;

Procedure TForm15.FormCreate(Sender: TObject);
Begin
    Schedule.Cells[1, 0] := 'Понедельник';
    Schedule.Cells[2, 0] := 'Вторник';
    Schedule.Cells[3, 0] := 'Среда';
    Schedule.Cells[4, 0] := 'Четверг';
    Schedule.Cells[5, 0] := 'Пятница';
    Schedule.Cells[6, 0] := 'Суббота';
    Schedule.Cells[0, 0] := 'Пара';
    Schedule.Cells[0, 1] := '1';
    Schedule.Cells[0, 2] := '2';
    Schedule.Cells[0, 3] := '3';
    Schedule.Cells[0, 4] := '4';
    Schedule.Cells[0, 5] := '5';
    Schedule.Cells[0, 6] := '6';
End;

procedure TForm15.N1Click(Sender: TObject);
begin
    Application.MessageBox('Для получения расписания в доступное поле введите имя преподавателя, затем нажмите кнопку заполнить', 'Инструкции');
end;

End.
