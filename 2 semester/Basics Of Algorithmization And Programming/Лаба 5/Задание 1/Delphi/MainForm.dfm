object MainTaskForm: TMainTaskForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351004 Lab5_1'
  ClientHeight = 496
  ClientWidth = 685
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainFormMenu
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHelp = FormHelp
  TextHeight = 25
  object TaskLabel: TLabel
    Left = 10
    Top = 10
    Width = 167
    Height = 28
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1057#1087#1080#1089#1086#1082' '#1050#1086#1085#1090#1072#1082#1090#1086#1074
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object StringGrid: TStringGrid
    Left = 10
    Top = 48
    Width = 252
    Height = 49
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    DefaultColWidth = 96
    DefaultRowHeight = 36
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goAlwaysShowEditor, goThumbTracking]
    ScrollBars = ssNone
    TabOrder = 0
    ColWidths = (
      96
      96
      96
      96
      96)
    RowHeights = (
      36)
  end
  object AddButton: TButton
    Left = 488
    Top = 80
    Width = 161
    Height = 57
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1082#1086#1085#1090#1072#1082#1090
    TabOrder = 1
    OnClick = AddButtonClick
  end
  object DeleteButton: TButton
    Left = 488
    Top = 176
    Width = 161
    Height = 57
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 2
    OnClick = DeleteButtonClick
  end
  object ReverseButton: TButton
    Left = 488
    Top = 272
    Width = 161
    Height = 57
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1054#1073#1088#1072#1090#1085#1099#1081' '#1087#1086#1088#1103#1076#1086#1082
    TabOrder = 3
    WordWrap = True
    OnClick = ReverseButtonClick
  end
  object StarightButton: TButton
    Left = 488
    Top = 368
    Width = 161
    Height = 57
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1055#1088#1103#1084#1086#1081' '#1087#1086#1088#1103#1076#1086#1082
    TabOrder = 4
    WordWrap = True
    OnClick = StarightButtonClick
  end
  object MainFormMenu: TMainMenu
    Left = 448
    object FileMenu: TMenuItem
      Caption = #1060#1072#1081#1083
      object OpenMenu: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ShortCut = 16463
        OnClick = OpenMenuClick
      end
      object SaveMenu: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        Enabled = False
        ShortCut = 16467
        OnClick = SaveMenuClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object QuitMenu: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = QuitMenuClick
      end
    end
    object InstructionMenu: TMenuItem
      Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
      OnClick = InstructionMenuClick
    end
    object DeveloperMenu: TMenuItem
      Caption = #1054' '#1088#1072#1079#1088#1072#1073#1086#1090#1095#1080#1082#1077
      OnClick = DeveloperMenuClick
    end
  end
  object OpenFile: TOpenDialog
    Filter = 'Text files (*.txt)|*.txt'
    Left = 496
  end
  object SaveTextFile: TSaveTextFileDialog
    Filter = 'Text files (*.txt)|*.txt'
    Left = 536
  end
end
