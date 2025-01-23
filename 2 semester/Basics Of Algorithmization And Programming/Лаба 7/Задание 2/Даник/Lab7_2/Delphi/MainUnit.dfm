object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1043#1072#1089#1102#1082' '#1044#1072#1085#1080#1080#1083' 351004 Lab7_2'
  ClientHeight = 518
  ClientWidth = 454
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnHelp = FormHelp
  TextHeight = 15
  object OrderLabel: TLabel
    Left = 15
    Top = 77
    Width = 195
    Height = 21
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1087#1086#1088#1103#1076#1086#1082' '#1084#1072#1090#1088#1080#1094#1099':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object MatrixGridLabel: TLabel
    Left = 15
    Top = 142
    Width = 210
    Height = 21
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1084#1072#1090#1088#1080#1094#1091' '#1089#1084#1077#1078#1085#1086#1089#1090#1080':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object Task: TLabel
    Left = 15
    Top = 11
    Width = 394
    Height = 50
    Caption = 
      #1044#1072#1085#1085#1072#1103' '#1087#1088#1086#1075#1088#1072#1084#1084#1072' '#1087#1088#1077#1086#1073#1088#1072#1079#1091#1077#1090' '#1084#1072#1090#1088#1080#1094#1091' '#1089#1084#1077#1078#1085#1086#1089#1090#1080' '#1074' '#1089#1087#1080#1089#1082#1080' '#1080#1085#1094#1080#1076#1077#1085#1090 +
      #1085#1086#1089#1090#1080'.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object ResultLabel: TLabel
    Left = 14
    Top = 373
    Width = 170
    Height = 21
    Caption = #1057#1087#1080#1089#1082#1080' '#1080#1085#1094#1080#1076#1077#1085#1090#1085#1086#1089#1090#1080':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object OrderEdit: TEdit
    Left = 15
    Top = 104
    Width = 92
    Height = 23
    TabOrder = 0
    OnChange = OrderEditChange
    OnContextPopup = OrderEditContextPopup
    OnKeyDown = OrderEditKeyDown
    OnKeyPress = OrderEditKeyPress
  end
  object MatrixGrid: TStringGrid
    Left = 15
    Top = 169
    Width = 169
    Height = 136
    ColCount = 6
    Ctl3D = True
    DefaultColWidth = 35
    DefaultRowHeight = 25
    RowCount = 6
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor, goThumbTracking, goFixedRowDefAlign]
    ParentCtl3D = False
    TabOrder = 1
    Visible = False
    OnKeyDown = MatrixGridKeyDown
    OnKeyPress = MatrixGridKeyPress
    OnSetEditText = MatrixGridSetEditText
    RowHeights = (
      25
      25
      25
      25
      25
      25)
  end
  object ResultButton: TButton
    Left = 15
    Top = 336
    Width = 75
    Height = 25
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090
    Enabled = False
    TabOrder = 2
    OnClick = ResultButtonClick
  end
  object ResultGrid: TStringGrid
    Left = 15
    Top = 406
    Width = 169
    Height = 83
    ColCount = 6
    Ctl3D = True
    DefaultColWidth = 35
    DefaultRowHeight = 25
    FixedCols = 0
    RowCount = 6
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goAlwaysShowEditor, goThumbTracking, goFixedRowDefAlign]
    ParentCtl3D = False
    ScrollBars = ssVertical
    TabOrder = 3
    Visible = False
    OnDrawCell = ResultGridDrawCell
    RowHeights = (
      25
      25
      25
      25
      25
      25)
  end
  object MainMenu1: TMainMenu
    Left = 264
    Top = 352
    object FileButton: TMenuItem
      Caption = #1060#1072#1081#1083
      object OpenFileButton: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ShortCut = 16463
        OnClick = OpenOnClick
      end
      object SaveFileButton: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        Enabled = False
        ShortCut = 16467
        OnClick = SaveOnClick
      end
      object LineSeparator: TMenuItem
        Caption = '-'
      end
      object ExitButton: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        ShortCut = 16465
        OnClick = ExitOnClick
      end
    end
    object InstructionButton: TMenuItem
      Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
      OnClick = InstructionButtonClick
    end
    object DeveloperButton: TMenuItem
      Caption = #1054' '#1088#1072#1079#1088#1072#1073#1086#1090#1095#1080#1082#1077
      OnClick = DeveloperOnClick
    end
  end
  object OpenFile: TOpenDialog
    Filter = 'Text files (*.txt)|*.txt'
    Left = 168
    Top = 352
  end
  object SaveFile: TSaveDialog
    FileName = 'D:\Dokuments\Desctop\dfbdfg'
    Filter = 'Text files (*.txt)|*.txt'
    Left = 216
    Top = 352
  end
end
