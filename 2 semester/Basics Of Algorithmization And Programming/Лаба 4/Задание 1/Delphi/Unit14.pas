Unit Unit14;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus;

Type
    ScheduleInfo = Record
        ElemSubject: String;
        ElemTeacher: String;
        ElemDayOfWeek: String;
        ElemNumOfLesson: Byte;
    End;

    ScheduleInfoArr = Array Of ScheduleInfo;

    TForm14 = Class(TForm)
        Label1: TLabel;
        DayOfWeek: TComboBox;
        LessonNum: TComboBox;
        Subject: TEdit;
        Teacher: TEdit;
        Label2: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        CancelRec: TButton;
        AddRec: TButton;
        ChangeRecord: TButton;
    MainMenu1: TMainMenu;
    Instructions: TMenuItem;
    PopupMenu1: TPopupMenu;
    gg: TMenuItem;
    ShiftBlocker: TMenuItem;
        Procedure CancelRecClick(Sender: TObject);
        Procedure SubjectKeyPress(Sender: TObject; Var Key: Char);
        Procedure TeacherKeyPress(Sender: TObject; Var Key: Char);
        Procedure SubjectChange(Sender: TObject);
        Procedure AddRecClick(Sender: TObject);
    procedure InstructionsClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        RecordInfo: ScheduleInfo;
        CurRecord: ScheduleInfo;
        WantEdit: Boolean;
    End;

Var
    Form14: TForm14;

Implementation

{$R *.dfm}

Procedure TForm14.AddRecClick(Sender: TObject);
Begin
    CurRecord.ElemSubject := Subject.Text;
    CurRecord.ElemTeacher := Teacher.Text;
    CurRecord.ElemDayOfWeek := DayOfWeek.Text;
    CurRecord.ElemNumOfLesson := StrToInt(LessonNum.Text);
    Close
End;

Procedure TForm14.CancelRecClick(Sender: TObject);
Begin
    CurRecord.ElemSubject := '';
    Close
End;

procedure TForm14.InstructionsClick(Sender: TObject);
begin
    Application.MessageBox('В верхние ячейки введите соответствующие строки длинной не больше 15, затем в нижних меню выберите соответствующие значения. Чтобы отменить действие нажмите на кнопку отменить ', 'Помощь');
end;

Procedure TForm14.SubjectChange(Sender: TObject);
Begin
    If (Teacher.Text <> '') And (Subject.Text <> '') And (DayOfWeek.Text <> '')
      And (LessonNum.Text <> '') Then
        AddRec.Enabled := True
    Else
        AddRec.Enabled := False
End;

Procedure TForm14.SubjectKeyPress(Sender: TObject; Var Key: Char);
Begin
    If ((Length(Subject.Text) > 14) And (Key <> #8)) Or
      (Key In ['0' .. '9']) Then
        Key := #0;
End;

Procedure TForm14.TeacherKeyPress(Sender: TObject; Var Key: Char);
Begin
    If ((Length(Teacher.Text) > 14) And (Key <> #8)) Or
      (Key In ['0' .. '9']) Then
        Key := #0;
End;

End.
