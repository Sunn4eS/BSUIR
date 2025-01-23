object MainTaskForm: TMainTaskForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351004 Lab3_1'
  ClientHeight = 437
  ClientWidth = 704
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainFormMenu
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHelp = FormHelp
  TextHeight = 25
  object TaskLabel: TLabel
    Left = 48
    Top = 32
    Width = 76
    Height = 28
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1047#1072#1076#1072#1085#1080#1077
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object EnterLabel: TLabel
    Left = 48
    Top = 140
    Width = 219
    Height = 28
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1087#1077#1088#1074#1091#1102' '#1089#1090#1088#1086#1082#1091':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object OutLabel: TLabel
    Left = 48
    Top = 332
    Width = 56
    Height = 28
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1054#1090#1074#1077#1090':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Enter2Label: TLabel
    Left = 48
    Top = 240
    Width = 197
    Height = 25
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1074#1090#1086#1088#1091#1102' '#1089#1090#1088#1086#1082#1091':'
  end
  object EnterEdit: TEdit
    Left = 48
    Top = 188
    Width = 182
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 0
    TextHint = #1057#1090#1088#1086#1082#1072' 1'
    OnChange = EnterEditChange
  end
  object OutEdit: TEdit
    Left = 48
    Top = 380
    Width = 321
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Enabled = False
    ReadOnly = True
    TabOrder = 1
    OnChange = OutEditChange
  end
  object ResultButton: TButton
    Left = 256
    Top = 186
    Width = 113
    Height = 38
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100
    TabOrder = 2
    OnClick = ResultButtonClick
  end
  object EnterStr2Edit: TEdit
    Left = 48
    Top = 280
    Width = 182
    Height = 33
    TabOrder = 3
    TextHint = #1057#1090#1088#1086#1082#1072' 2'
    OnChange = EnterStr2EditChange
  end
  object MainFormMenu: TMainMenu
    Left = 648
    Top = 104
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
    Left = 648
    Top = 176
  end
  object SaveTextFile: TSaveTextFileDialog
    Left = 632
    Top = 256
  end
end
