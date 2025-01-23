object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351004 Lab2_5'
  ClientHeight = 458
  ClientWidth = 526
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHelp = FormHelp
  TextHeight = 15
  object EnterNLabel: TLabel
    Left = 15
    Top = 85
    Width = 260
    Height = 21
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1090#1088#1086#1082' '#1084#1072#1090#1088#1080#1094#1099':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object StringGridLabel: TLabel
    Left = 15
    Top = 213
    Width = 68
    Height = 21
    Caption = #1052#1072#1090#1088#1080#1094#1072':'
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
    Width = 390
    Height = 50
    Caption = #1044#1072#1085#1085#1072#1103' '#1087#1088#1086#1075#1088#1072#1084#1084#1072' '#1085#1072#1093#1086#1076#1080#1090' '#1089#1077#1076#1083#1086#1074#1099#1077' '#1090#1086#1095#1082#1080' '#1074' '#1084#1072#1090#1088#1080#1094#1077'.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object EnterMLabel: TLabel
    Left = 15
    Top = 148
    Width = 287
    Height = 21
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1090#1086#1083#1073#1094#1086#1074' '#1084#1072#1090#1088#1080#1094#1099':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 25
    Top = 379
    Width = 56
    Height = 15
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090':'
  end
  object EnterNEdit: TEdit
    Left = 15
    Top = 112
    Width = 121
    Height = 23
    TabOrder = 0
    TextHint = #1050#1086#1083'-'#1074#1086' '#1089#1090#1088#1086#1082
    OnChange = EnterNEditChange
    OnContextPopup = EnterNEditContextPopup
    OnKeyDown = EnterNEditKeyDown
    OnKeyPress = NOnKeyPress
  end
  object NumsStringGrid: TStringGrid
    Left = 15
    Top = 240
    Width = 341
    Height = 123
    Ctl3D = True
    DefaultColWidth = 30
    DefaultRowHeight = 23
    FixedCols = 0
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor, goThumbTracking, goFixedRowDefAlign]
    ParentCtl3D = False
    ScrollBars = ssNone
    TabOrder = 1
    Visible = False
    OnKeyDown = NumsStringGridKeyDown
    OnKeyPress = NumsStringGridKeyPress
    OnSetEditText = NumsStringGridSetEditText
  end
  object ResultButton: TButton
    Left = 322
    Top = 408
    Width = 75
    Height = 25
    Caption = #1053#1072#1081#1090#1080
    Enabled = False
    TabOrder = 2
    OnClick = ResultButtonClick
  end
  object ResultEdit: TEdit
    Left = 25
    Top = 409
    Width = 274
    Height = 23
    Enabled = False
    ReadOnly = True
    TabOrder = 3
    OnChange = ResultEditChange
  end
  object EnterMEdit: TEdit
    Left = 15
    Top = 175
    Width = 121
    Height = 23
    TabOrder = 4
    TextHint = #1050#1086#1083'-'#1074#1086' '#1089#1090#1086#1083#1073#1094#1086#1074
    OnChange = EnterMEditChange
    OnContextPopup = EnterMEditContextPopup
    OnKeyDown = EnterMEditKeyDown
    OnKeyPress = EnterMEditKeyPress
  end
  object MainMenu1: TMainMenu
    Left = 528
    Top = 328
    object FileTab: TMenuItem
      Caption = #1060#1072#1081#1083
      object OpenOption: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ShortCut = 16463
        OnClick = OpenOnClick
      end
      object SaveOption: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        Enabled = False
        ShortCut = 16467
        OnClick = SaveOnClick
      end
      object LineSeparator: TMenuItem
        Caption = '-'
      end
      object ExitOption: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = ExitOnClick
      end
    end
    object InstructionTab: TMenuItem
      Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
      OnClick = InstructionTabClick
    end
    object DeveloperTab: TMenuItem
      Caption = #1054' '#1088#1072#1079#1088#1072#1073#1086#1090#1095#1080#1082#1077
      OnClick = DeveloperOnClick
    end
  end
  object OpenFile: TOpenDialog
    Filter = 'Text files (*.txt)|*.txt'
    Left = 432
    Top = 328
  end
  object SaveFile: TSaveDialog
    FileName = 'D:\Dokuments\Desctop\dfbdfg'
    Filter = 'Text files (*.txt)|*.txt'
    Left = 480
    Top = 328
  end
end
