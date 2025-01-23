object MainTaskForm: TMainTaskForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 652
  ClientWidth = 1124
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
  OnDestroy = FormDestroy
  OnHelp = FormHelp
  TextHeight = 25
  object AddButton: TButton
    Left = 24
    Top = 24
    Width = 161
    Height = 57
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 0
    OnClick = AddButtonClick
  end
  object DeleteButton: TButton
    Left = 24
    Top = 120
    Width = 161
    Height = 57
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 1
    OnClick = DeleteButtonClick
  end
  object TraversalButton: TButton
    Left = 24
    Top = 220
    Width = 161
    Height = 61
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = #1054#1073#1086#1081#1090#1080' '#1076#1077#1088#1077#1074#1086
    TabOrder = 2
    OnClick = TraversalButtonClick
  end
  object ScrollBox: TScrollBox
    Left = 264
    Top = 0
    Width = 860
    Height = 652
    HorzScrollBar.Tracking = True
    VertScrollBar.Visible = False
    Align = alRight
    TabOrder = 3
    ExplicitLeft = 258
    ExplicitHeight = 635
    object TreePaintBox: TPaintBox
      Left = 19
      Top = 3
      Width = 598
      Height = 642
      OnPaint = TreePaintBoxPaint
    end
  end
  object TreeGrid: TStringGrid
    Left = 24
    Top = 304
    Width = 225
    Height = 65
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    DefaultColWidth = 96
    DefaultRowHeight = 36
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goThumbTracking, goFixedRowDefAlign]
    TabOrder = 4
  end
  object MainFormMenu: TMainMenu
    Left = 200
    Top = 8
    object FileMenu: TMenuItem
      Caption = #1060#1072#1081#1083
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
end
