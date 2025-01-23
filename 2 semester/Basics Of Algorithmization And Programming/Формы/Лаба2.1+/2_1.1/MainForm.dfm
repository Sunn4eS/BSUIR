object MainTaskForm: TMainTaskForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351004 Lab2_1'
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
  object EnterNLabel: TLabel
    Left = 76
    Top = 120
    Width = 377
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1074#1077#1088#1096#1080#1085' '#1084#1085#1086#1075#1086#1091#1075#1086#1083#1100#1080#1085#1082#1072':'
  end
  object ArrLabel: TLabel
    Left = 76
    Top = 219
    Width = 175
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1050#1086#1086#1088#1076#1080#1085#1072#1090#1099' '#1074#1077#1088#1096#1080#1085':'
    Visible = False
  end
  object OutLabel: TLabel
    Left = 82
    Top = 400
    Width = 80
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1055#1083#1086#1097#1072#1076#1100':'
  end
  object ResultButton: TButton
    Left = 456
    Top = 435
    Width = 113
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100
    Enabled = False
    TabOrder = 1
    OnClick = ResultButtonClick
  end
  object EnterNEdit: TEdit
    Left = 76
    Top = 155
    Width = 182
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 2
    TextHint = #1050#1086#1083'-'#1074#1086' '#1074#1077#1088#1096#1080#1085
    OnChange = EnterNEditChange
    OnClick = EnterNEditClick
    OnContextPopup = EnterNEditContextPopup
    OnExit = EnterNEditExit
    OnKeyDown = EnterNEditKeyDown
    OnKeyPress = EnterNEditKeyPress
  end
  object OutEdit: TEdit
    Left = 76
    Top = 435
    Width = 357
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
  object StringGrid: TStringGrid
    Left = 76
    Top = 254
    Width = 493
    Height = 120
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    DefaultColWidth = 96
    DefaultRowHeight = 36
    RowCount = 3
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor, goThumbTracking]
    ScrollBars = ssHorizontal
    TabOrder = 0
    Visible = False
    OnKeyDown = StringGridKeyDown
    OnKeyPress = StringGridKeyPress
    OnMouseActivate = StringGridMouseActivate
    OnSetEditText = StringGridSetEditText
    ColWidths = (
      96
      96
      96
      96
      96)
    RowHeights = (
      36
      36
      36)
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
