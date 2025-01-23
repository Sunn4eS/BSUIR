object Form14: TForm14
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1079#1072#1087#1080#1089#1100
  ClientHeight = 295
  ClientWidth = 398
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  Position = poDesktopCenter
  TextHeight = 15
  object Label1: TLabel
    Left = 24
    Top = 16
    Width = 347
    Height = 41
    Caption = #1057#1074#1077#1076#1077#1085#1080#1103' '#1086' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -30
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 66
    Top = 84
    Width = 76
    Height = 25
    Caption = #1055#1088#1077#1076#1084#1077#1090
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 219
    Top = 84
    Width = 136
    Height = 25
    Caption = #1055#1088#1077#1087#1086#1076#1086#1074#1072#1090#1077#1083#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 50
    Top = 164
    Width = 111
    Height = 25
    Caption = #1044#1077#1085#1100' '#1085#1077#1076#1077#1083#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 241
    Top = 164
    Width = 94
    Height = 25
    Caption = #8470' '#1079#1072#1085#1103#1090#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object DayOfWeek: TComboBox
    Left = 38
    Top = 195
    Width = 131
    Height = 23
    Style = csDropDownList
    TabOrder = 0
    OnChange = SubjectChange
    Items.Strings = (
      #1055#1086#1085#1077#1076#1077#1083#1100#1085#1080#1082
      #1042#1090#1086#1088#1085#1080#1082
      #1057#1088#1077#1076#1072
      #1063#1077#1090#1074#1077#1088#1075
      #1055#1103#1090#1085#1080#1094#1072
      #1057#1091#1073#1073#1086#1090#1072)
  end
  object LessonNum: TComboBox
    Left = 219
    Top = 195
    Width = 131
    Height = 23
    Style = csDropDownList
    TabOrder = 1
    OnChange = SubjectChange
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6')
  end
  object Subject: TEdit
    Left = 38
    Top = 117
    Width = 131
    Height = 23
    ImeName = 'Subject'
    PopupMenu = PopupMenu1
    TabOrder = 2
    OnChange = SubjectChange
    OnKeyPress = SubjectKeyPress
  end
  object Teacher: TEdit
    Left = 219
    Top = 117
    Width = 131
    Height = 23
    ImeName = 'Teacher'
    PopupMenu = PopupMenu1
    TabOrder = 3
    OnChange = SubjectChange
    OnKeyPress = TeacherKeyPress
  end
  object CancelRec: TButton
    Left = 24
    Top = 240
    Width = 161
    Height = 45
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = CancelRecClick
  end
  object AddRec: TButton
    Left = 208
    Top = 240
    Width = 163
    Height = 45
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    DisabledImageName = 'AddRec'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = AddRecClick
  end
  object ChangeRecord: TButton
    Left = 208
    Top = 240
    Width = 163
    Height = 45
    Caption = #1048#1079#1084#1077#1085#1080#1090#1100
    DisabledImageName = 'AddRec'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    Visible = False
    OnClick = AddRecClick
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 64
    object Instructions: TMenuItem
      Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1080
      ShortCut = 112
      Visible = False
      OnClick = InstructionsClick
    end
    object gg: TMenuItem
      ShortCut = 16470
    end
    object ShiftBlocker: TMenuItem
      ShortCut = 8237
      Visible = False
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 8
    Top = 160
  end
end
