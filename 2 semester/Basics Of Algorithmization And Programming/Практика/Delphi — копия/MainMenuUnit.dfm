object MainMenuForm: TMainMenuForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1040#1088#1093#1080#1074' '#1075#1088#1091#1087#1087' '#1089#1090#1091#1076#1077#1085#1090#1086#1074
  ClientHeight = 641
  ClientWidth = 286
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = DevAndInstMainMenu
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnHelp = FormHelp
  OnShow = FormShow
  TextHeight = 25
  object GroupListButton: TButton
    Left = 34
    Top = 34
    Width = 215
    Height = 119
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1057#1087#1080#1089#1086#1082' '#1075#1088#1091#1087#1087
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = GroupListButtonClick
  end
  object FindStudentButton: TButton
    Left = 34
    Top = 168
    Width = 215
    Height = 129
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1055#1086#1080#1089#1082' '#1089#1090#1091#1076#1077#1085#1090#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = FindStudentButtonClick
  end
  object DebtStudentButton: TButton
    Left = 34
    Top = 320
    Width = 215
    Height = 129
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1057#1087#1080#1089#1086#1082' '#1089#1090#1091#1076#1077#1085#1090#1086#1074'-'#1071#1079#1072#1076#1086#1083#1078#1085#1080#1082#1086#1074
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    WordWrap = True
    OnClick = DebtStudentButtonClick
  end
  object ExpellStudentButton: TButton
    Left = 34
    Top = 471
    Width = 215
    Height = 138
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1057#1087#1080#1089#1086#1082' '#1089#1090#1091#1076#1077#1085#1090#1086#1074' '#1085#1072' '#1086#1090#1095#1080#1089#1083#1077#1085#1080#1077
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    WordWrap = True
    OnClick = ExpellStudentButtonClick
  end
  object DevAndInstMainMenu: TMainMenu
    Top = 608
    object InstructionMenu: TMenuItem
      Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
      OnClick = InstructionMenuClick
    end
    object DeveloperMenu: TMenuItem
      Caption = #1054' '#1056#1072#1079#1088#1072#1073#1086#1090#1095#1080#1082#1077
      OnClick = DeveloperMenuClick
    end
  end
end
