object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351004 Lab3_2'
  ClientHeight = 335
  ClientWidth = 420
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
  object EnterNLabel: TLabel
    Left = 23
    Top = 136
    Width = 218
    Height = 21
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1085#1072#1090#1091#1088#1072#1083#1100#1085#1086#1077' '#1095#1080#1089#1083#1086' N:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object StringGridLabel: TLabel
    Left = 23
    Top = 202
    Width = 114
    Height = 21
    Caption = #1055#1088#1086#1089#1090#1099#1077' '#1095#1080#1089#1083#1072': '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object Task: TLabel
    Left = 23
    Top = 16
    Width = 308
    Height = 100
    Caption = 
      #1044#1072#1085#1085#1072#1103' '#1087#1088#1086#1075#1088#1072#1084#1084#1072' '#1085#1072#1093#1086#1076#1080#1090' '#1074#1089#1077' '#1087#1088#1086#1089#1090#1099#1077' '#1095#1080#1089#1083#1072', '#1085#1077' '#1087#1088#1077#1074#1086#1089#1093#1086#1076#1103#1097#1080#1077' '#1095#1080#1089 +
      #1083#1072' N. '#1057' '#1087#1086#1084#1086#1097#1100#1102' '#1072#1083#1075#1086#1088#1080#1090#1084#1072' "'#1056#1077#1096#1077#1090#1086' '#1069#1088#1072#1090#1086#1089#1092#1077#1085#1072'".'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object EnterNEdit: TEdit
    Left = 23
    Top = 164
    Width = 121
    Height = 23
    ParentShowHint = False
    ShowHint = False
    TabOrder = 0
    TextHint = 'N'
    OnChange = EnterNEditChange
    OnContextPopup = EnterNEditContextPopup
    OnKeyDown = EnterNEditKeyDown
    OnKeyPress = NOnKeyPress
  end
  object NumsStringGrid: TStringGrid
    Left = 23
    Top = 232
    Width = 341
    Height = 65
    Ctl3D = True
    FixedCols = 0
    RowCount = 3
    FixedRows = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor, goThumbTracking, goFixedRowDefAlign]
    ParentCtl3D = False
    ScrollBars = ssHorizontal
    TabOrder = 1
    Visible = False
    ColWidths = (
      64
      64
      64
      64
      64)
  end
  object ResultButton: TButton
    Left = 166
    Top = 163
    Width = 75
    Height = 25
    Caption = #1053#1072#1081#1090#1080
    Enabled = False
    TabOrder = 2
    OnClick = ResultButtonClick
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
