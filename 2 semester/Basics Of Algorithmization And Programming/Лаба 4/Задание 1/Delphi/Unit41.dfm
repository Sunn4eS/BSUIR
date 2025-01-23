object Form13: TForm13
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Lab4_1  '#1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351004'
  ClientHeight = 428
  ClientWidth = 471
  Color = clBtnFace
  Constraints.MaxHeight = 496
  Constraints.MaxWidth = 495
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHelp = FormHelp
  TextHeight = 15
  object Label1: TLabel
    Left = 160
    Top = 40
    Width = 167
    Height = 41
    Caption = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -30
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object SpeedButton1: TSpeedButton
    Left = 376
    Top = 376
    Width = 23
    Height = 22
  end
  object Records: TStringGrid
    Left = 15
    Top = 104
    Width = 448
    Height = 233
    ColCount = 4
    DefaultColWidth = 110
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
    ScrollBars = ssVertical
    TabOrder = 0
    OnSelectCell = RecordsSelectCell
  end
  object Button1: TButton
    Left = 27
    Top = 363
    Width = 121
    Height = 57
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button1Click
  end
  object TeacherSch: TButton
    Left = 326
    Top = 363
    Width = 121
    Height = 57
    Caption = #1047#1072#1085#1103#1090#1086#1089#1090#1100
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = TeacherSchClick
  end
  object DeleteRec: TButton
    Left = 177
    Top = 363
    Width = 121
    Height = 57
    Caption = #1059#1076#1072#1083#1080#1090#1100
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = DeleteRecClick
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 24
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object BOpen: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ShortCut = 16463
        OnClick = BOpenClick
      end
      object BSave: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        Enabled = False
        ShortCut = 16467
        OnClick = BSaveClick
      end
      object BClose: TMenuItem
        Caption = #1047#1072#1082#1088#1099#1090#1100
        ShortCut = 32883
        OnClick = BCloseClick
      end
    end
    object Instructions: TMenuItem
      Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1080
      ShortCut = 112
      OnClick = InstructionsClick
    end
    object BDev: TMenuItem
      Caption = #1054' '#1088#1072#1079#1088#1072#1073#1086#1090#1095#1080#1082#1077
      ShortCut = 16464
      OnClick = BDevClick
    end
    object ShiftBlocker: TMenuItem
      ShortCut = 8237
      Visible = False
    end
  end
  object OpenTextFileDialog1: TOpenTextFileDialog
    Left = 352
    Top = 32
  end
end
