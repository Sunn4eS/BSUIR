object MainTaskForm: TMainTaskForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351005 Lab1_1'
  ClientHeight = 470
  ClientWidth = 705
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainFormMenu
  Position = poMainFormCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHelp = FormHelp
  TextHeight = 25
  object TaskLabel: TLabel
    Left = 24
    Top = 37
    Width = 7
    Height = 32
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object EnterLabel: TLabel
    Left = 72
    Top = 136
    Width = 192
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1085#1086#1084#1077#1088' '#1084#1077#1089#1103#1094#1072':'
  end
  object OutLabel: TLabel
    Left = 72
    Top = 244
    Width = 51
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1054#1090#1074#1077#1090':'
  end
  object EnterEdit: TEdit
    Left = 72
    Top = 184
    Width = 182
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 0
    TextHint = #1053#1086#1084#1077#1088' '#1084#1077#1089#1103#1094#1072
    OnChange = EnterEditChange
    OnClick = EnterEditClick
    OnContextPopup = EnterEditContextPopup
    OnExit = ResultButtonClick
    OnKeyDown = EnterEditKeyDown
    OnKeyPress = EnterEditKeyPress
  end
  object OutEdit: TEdit
    Left = 72
    Top = 279
    Width = 182
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
    Left = 292
    Top = 182
    Width = 113
    Height = 35
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1059#1079#1085#1072#1090#1100
    TabOrder = 2
    OnClick = ResultButtonClick
  end
  object MainFormMenu: TMainMenu
    Left = 648
    Top = 8
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
    DefaultExt = 'txt'
    Filter = 'Text files (*.txt)|*.txt'
    Left = 648
    Top = 48
  end
  object SaveTextFile: TSaveTextFileDialog
    Filter = #1058#1077#1082#1089#1090#1086#1074#1099#1077' '#1092#1072#1081#1083#1099' (*.txt)|*.txt'
    Left = 656
    Top = 128
  end
end
