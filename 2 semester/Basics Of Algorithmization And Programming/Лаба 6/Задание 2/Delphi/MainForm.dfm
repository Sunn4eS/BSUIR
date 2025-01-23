object MainTaskForm: TMainTaskForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351004 Lab6_2'
  ClientHeight = 518
  ClientWidth = 732
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
  OnHelp = FormHelp
  TextHeight = 25
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 203
    Height = 75
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1069#1090#1086' '#1087#1088#1086#1075#1088#1072#1084#1084#1072' '#1085#1072#1093#1086#1076#1080#1090' '#1076#1086#1088#1086#1075#1091' '#1084#1077#1078#1076#1091' '#1075#1086#1088#1086#1076#1072#1084#1080'.'
    WordWrap = True
  end
  object AddButton: TButton
    Left = 40
    Top = 128
    Width = 161
    Height = 57
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1075#1086#1088#1086#1076
    TabOrder = 0
    OnClick = AddButtonClick
  end
  object AddLineButton: TButton
    Left = 40
    Top = 224
    Width = 161
    Height = 57
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1091#1090#1100
    TabOrder = 1
    OnClick = AddLineButtonClick
  end
  object FindRouteButton: TButton
    Left = 40
    Top = 320
    Width = 161
    Height = 57
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1053#1072#1081#1090#1080' '#1087#1091#1090#1100
    TabOrder = 2
    WordWrap = True
    OnClick = FindRouteButtonClick
  end
  object ClearButton: TButton
    Left = 40
    Top = 416
    Width = 161
    Height = 57
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1057#1073#1088#1086#1089
    TabOrder = 3
    WordWrap = True
    OnClick = ClearButtonClick
  end
  object ScrollBox: TScrollBox
    Left = 243
    Top = 0
    Width = 489
    Height = 518
    HorzScrollBar.Tracking = True
    VertScrollBar.Visible = False
    Align = alRight
    TabOrder = 4
    ExplicitLeft = 233
    ExplicitHeight = 500
    object TownPaintBox: TPaintBox
      Left = -2
      Top = -2
      Width = 427
      Height = 642
    end
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
