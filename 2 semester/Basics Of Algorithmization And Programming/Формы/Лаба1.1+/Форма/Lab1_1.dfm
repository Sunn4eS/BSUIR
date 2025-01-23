object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = '351005 '#1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' Lab1_1'
  ClientHeight = 499
  ClientWidth = 721
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  Position = poMainFormCenter
  TextHeight = 25
  object TaskLabel: TLabel
    Left = 80
    Top = 56
    Width = 539
    Height = 25
    Caption = #1069#1090#1072' '#1087#1088#1086#1075#1088#1072#1084#1084#1072' '#1086#1087#1088#1077#1076#1077#1083#1103#1077#1090#1084#1077#1089#1103#1094' '#1087#1086' '#1074#1074#1077#1076#1105#1085#1085#1086#1084#1091' '#1085#1086#1084#1077#1088#1091' '#1084#1077#1089#1103#1094#1072
  end
  object InputLabel: TLabel
    Left = 97
    Top = 145
    Width = 192
    Height = 25
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1085#1086#1084#1077#1088' '#1084#1077#1089#1103#1094#1072':'
  end
  object ОutLabel: TLabel
    Left = 96
    Top = 232
    Width = 57
    Height = 25
    Caption = #1052#1077#1089#1103#1094':'
  end
  object InputEdit: TEdit
    Left = 96
    Top = 176
    Width = 129
    Height = 33
    TabOrder = 0
    TextHint = #1053#1086#1084#1077#1088' '#1084#1077#1089#1103#1094#1072
    OnKeyDown = InputEditKeyDown
    OnKeyPress = InputEditKeyPress
  end
  object OutEdit: TEdit
    Left = 97
    Top = 263
    Width = 128
    Height = 33
    ReadOnly = True
    TabOrder = 1
  end
  object InputButton: TButton
    Left = 231
    Top = 176
    Width = 82
    Height = 33
    Caption = #1042#1074#1077#1089#1090#1080
    TabOrder = 2
    OnClick = InputButtonClick
  end
  object MainMenu: TMainMenu
    object FileMenu: TMenuItem
      Caption = #1060#1072#1081#1083
      object OpenTab: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ShortCut = 16463
      end
      object SaveTab: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        ShortCut = 16467
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object ExitTab: TMenuItem
        Caption = #1042#1099#1093#1086#1076
      end
    end
    object Instruction: TMenuItem
      Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
      OnClick = InstructionClick
    end
    object AboutDeveloper: TMenuItem
      Caption = #1054' '#1088#1072#1079#1088#1072#1073#1086#1090#1095#1080#1082#1077
    end
  end
end
