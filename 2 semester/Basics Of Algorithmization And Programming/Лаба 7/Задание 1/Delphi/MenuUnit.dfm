object MenuForm: TMenuForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Lab7_1 '#1041#1088#1072#1078#1072#1083#1086#1074#1080#1095' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' 351004'
  ClientHeight = 473
  ClientWidth = 973
  Color = clBtnFace
  Constraints.MinWidth = 340
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -27
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHelp = FormHelp
  TextHeight = 37
  object PaintBox: TPaintBox
    Left = 340
    Top = 8
    Width = 633
    Height = 486
    OnPaint = PaintBoxPaint
  end
  object EditVerticesButton: TButton
    Left = 48
    Top = 32
    Width = 185
    Height = 60
    Caption = #1042#1077#1088#1096#1080#1085#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = EditVerticesButtonClick
  end
  object EditEdgesButton: TButton
    Left = 48
    Top = 120
    Width = 185
    Height = 67
    Caption = #1056#1077#1073#1088#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = EditEdgesButtonClick
  end
  object AdjacencyMatrixButton: TButton
    Left = 48
    Top = 216
    Width = 185
    Height = 74
    Caption = #1052#1072#1090#1088#1080#1094#1072' '#1089#1084#1077#1078#1085#1086#1089#1090#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    WordWrap = True
    OnClick = AdjacencyMatrixButtonClick
  end
  object WayButton: TButton
    Left = 48
    Top = 328
    Width = 185
    Height = 73
    Caption = #1053#1072#1081#1090#1080' '#1093#1086#1076#1099
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = WayButtonClick
  end
  object MainMenu: TMainMenu
    Left = 227
    Top = 448
    object FileMenuItem: TMenuItem
      Caption = #1060#1072#1081#1083
      object OpenMenuItem: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ShortCut = 16463
        OnClick = OpenMenuItemClick
      end
      object SaveMenuItem: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        ShortCut = 16467
        OnClick = SaveMenuItemClick
      end
      object SeparatorMenuItem: TMenuItem
        Caption = '-'
      end
      object ExitMenuItem: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        ShortCut = 16465
        OnClick = ExitMenuItemClick
      end
    end
    object InstructionMenuItem: TMenuItem
      Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
      OnClick = InstructionMenuItemClick
    end
    object DeveloperMenuItem: TMenuItem
      Caption = #1054' '#1088#1072#1079#1088#1072#1073#1086#1090#1095#1080#1082#1077
      OnClick = DeveloperMenuItemClick
    end
  end
  object OpenTextFileDialog: TOpenTextFileDialog
    DefaultExt = 'txt'
    Filter = '(*.txt)|*.txt'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 267
    Top = 448
  end
  object SaveTextFileDialog: TSaveTextFileDialog
    DefaultExt = 'txt'
    Filter = '(*.txt)|*.txt'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 307
    Top = 448
  end
end
