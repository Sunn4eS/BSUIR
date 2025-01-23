object MainTaskForm: TMainTaskForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351004 Lab4_2'
  ClientHeight = 676
  ClientWidth = 647
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
    Left = 32
    Top = 48
    Width = 577
    Height = 56
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 
      #1044#1072#1085#1085#1072#1103' '#1087#1088#1086#1075#1088#1072#1084#1084#1072' '#1085#1072#1093#1086#1076#1080#1090' '#1074' '#1084#1072#1090#1088#1080#1094#1077' '#1087#1091#1090#1100' '#1086#1090' '#1101#1083#1077#1084#1077#1085#1090#1072' a[i1,j1] '#1076#1086' ' +
      #1101#1083#1077#1084#1077#1085#1090#1072' a[i2,j2] '#1089' '#1084#1072#1082#1089#1080#1084#1072#1083#1100#1085#1086#1081' '#1089#1091#1084#1084#1086#1081':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object EnterNLabel: TLabel
    Left = 76
    Top = 146
    Width = 224
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1087#1086#1088#1103#1076#1086#1082' '#1084#1072#1090#1088#1080#1094#1099':'
  end
  object ArrLabel: TLabel
    Left = 76
    Top = 267
    Width = 77
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1052#1072#1090#1088#1080#1094#1072':'
    Visible = False
  end
  object OutLabel: TLabel
    Left = 76
    Top = 539
    Width = 81
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090':'
  end
  object StartLabel: TLabel
    Left = 384
    Top = 136
    Width = 97
    Height = 50
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1053#1072#1095#1072#1083#1100#1085#1099#1081' '#1101#1083#1077#1084#1077#1085#1090
    WordWrap = True
  end
  object EndLabel: TLabel
    Left = 520
    Top = 136
    Width = 83
    Height = 50
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1050#1086#1085#1077#1095#1085#1099#1081' '#1101#1083#1077#1084#1077#1085#1090
    WordWrap = True
  end
  object ResultButton: TButton
    Left = 187
    Top = 536
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
  object EnterMEdit: TEdit
    Left = 76
    Top = 181
    Width = 81
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 2
    TextHint = 'm'
    OnChange = EnterMEditChange
    OnClick = EnterMEditClick
    OnContextPopup = EnterMEditContextPopup
    OnKeyDown = EnterMEditKeyDown
    OnKeyPress = EnterMEditKeyPress
  end
  object StringGrid: TStringGrid
    Left = 76
    Top = 302
    Width = 224
    Height = 120
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    DefaultColWidth = 96
    DefaultRowHeight = 36
    FixedCols = 0
    RowCount = 3
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor, goThumbTracking]
    ScrollBars = ssNone
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
  object EnterNEdit: TEdit
    Left = 76
    Top = 224
    Width = 81
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 3
    TextHint = 'n'
    OnChange = EnterNEditChange
    OnClick = EnterNEditClick
    OnContextPopup = EnterNEditContextPopup
    OnKeyDown = EnterNEditKeyDown
    OnKeyPress = EnterNEditKeyPress
  end
  object I1Edit: TEdit
    Left = 384
    Top = 200
    Width = 65
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 4
    TextHint = 'I1'
    OnChange = I1EditChange
    OnClick = I1EditClick
    OnContextPopup = I1EditContextPopup
    OnKeyDown = I1EditKeyDown
    OnKeyPress = I1EditKeyPress
  end
  object J1Edit: TEdit
    Left = 384
    Top = 243
    Width = 65
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 5
    TextHint = 'J1'
    OnChange = J1EditChange
    OnClick = J1EditClick
    OnContextPopup = J1EditContextPopup
    OnKeyDown = J1EditKeyDown
    OnKeyPress = J1EditKeyPress
  end
  object I2Edit: TEdit
    Left = 520
    Top = 200
    Width = 65
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 6
    TextHint = 'I2'
    OnChange = I2EditChange
    OnClick = I2EditClick
    OnContextPopup = I2EditContextPopup
    OnKeyDown = I2EditKeyDown
    OnKeyPress = I2EditKeyPress
  end
  object J2Edit: TEdit
    Left = 520
    Top = 243
    Width = 62
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 7
    TextHint = 'J2'
    OnChange = J2EditChange
    OnClick = J2EditClick
    OnContextPopup = J2EditContextPopup
    OnKeyDown = J2EditKeyDown
    OnKeyPress = J2EditKeyPress
  end
  object OutEdit: TEdit
    Left = 32
    Top = 584
    Width = 571
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    ReadOnly = True
    TabOrder = 8
  end
  object MainFormMenu: TMainMenu
    Left = 440
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
    Filter = 'Text files (*.txt)|*.txt'
    Left = 504
    Top = 8
  end
  object SaveTextFile: TSaveTextFileDialog
    Filter = 'Text files (*.txt)|*.txt'
    Left = 560
    Top = 8
  end
end
