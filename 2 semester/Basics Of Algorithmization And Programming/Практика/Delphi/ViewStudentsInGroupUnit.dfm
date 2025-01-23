object ViewStudentsInGroupForm: TViewStudentsInGroupForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1057#1090#1091#1076#1077#1085#1090#1099' '#1074' '#1075#1088#1091#1087#1087#1077
  ClientHeight = 442
  ClientWidth = 982
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object StudentInGroupGrid: TStringGrid
    Left = 24
    Top = 104
    Width = 937
    Height = 120
    ColCount = 11
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
    TabOrder = 0
  end
  object AddStudentButton: TButton
    Left = 24
    Top = 24
    Width = 105
    Height = 57
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1089#1090#1091#1076#1077#1085#1090#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    WordWrap = True
    OnClick = AddStudentButtonClick
  end
  object DeleteStudentButton: TButton
    Left = 152
    Top = 24
    Width = 105
    Height = 57
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1089#1090#1091#1076#1077#1085#1090#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    WordWrap = True
    OnClick = DeleteStudentButtonClick
  end
  object EditStudentButton: TButton
    Left = 280
    Top = 24
    Width = 121
    Height = 57
    Caption = #1048#1079#1084#1077#1085#1080#1090#1100' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1102
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    WordWrap = True
    OnClick = EditStudentButtonClick
  end
end
