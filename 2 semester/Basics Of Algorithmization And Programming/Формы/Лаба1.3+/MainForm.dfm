object MainTaskForm: TMainTaskForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351004 Lab1_3'
  ClientHeight = 488
  ClientWidth = 687
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
    Left = 20
    Top = 48
    Width = 5
    Height = 28
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object EnterXLabel: TLabel
    Left = 76
    Top = 168
    Width = 85
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1042#1074#1077#1076#1080#1090#1077' X:'
  end
  object EnterEPSLabel: TLabel
    Left = 76
    Top = 275
    Width = 103
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1042#1074#1077#1076#1080#1090#1077' EPS:'
  end
  object OutLabel: TLabel
    Left = 76
    Top = 368
    Width = 81
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090':'
  end
  object ResultButton: TButton
    Left = 268
    Top = 308
    Width = 113
    Height = 38
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100
    TabOrder = 0
    OnClick = ResultButtonClick
  end
  object EnterXEdit: TEdit
    Left = 76
    Top = 208
    Width = 182
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 1
    TextHint = 'X'
    OnChange = EnterXEditChange
    OnClick = EnterXEditClick
    OnContextPopup = EnterXEditContextPopup
    OnExit = EnterXEditExit
    OnKeyDown = EnterXEditKeyDown
    OnKeyPress = EnterXEditKeyPress
  end
  object EnterEPSEdit: TEdit
    Left = 76
    Top = 310
    Width = 182
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 2
    TextHint = 'EPS'
    OnChange = EnterEPSEditChange
    OnClick = EnterEPSEditClick
    OnContextPopup = EnterEPSEditContextPopup
    OnExit = EnterEPSEditExit
    OnKeyDown = EnterEPSEditKeyDown
    OnKeyPress = EnterEPSEditKeyPress
  end
  object OutEdit: TEdit
    Left = 76
    Top = 403
    Width = 573
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Enabled = False
    ReadOnly = True
    TabOrder = 3
    OnChange = OutEditChange
  end
  object MainFormMenu: TMainMenu
    Left = 616
    Top = 112
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
    Left = 616
    Top = 168
  end
  object SaveTextFile: TSaveTextFileDialog
    Filter = 'Text files (*.txt)|*.txt'
    Left = 616
    Top = 256
  end
end
