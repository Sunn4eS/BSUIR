object GroupListForm: TGroupListForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1057#1087#1080#1089#1086#1082' '#1075#1088#1091#1087#1087
  ClientHeight = 490
  ClientWidth = 607
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = GroupMainMenu
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object AddGroup: TButton
    Left = 8
    Top = 8
    Width = 121
    Height = 57
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    WordWrap = True
    OnClick = AddGroupClick
  end
  object DeleteGroup: TButton
    Left = 152
    Top = 8
    Width = 121
    Height = 57
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    WordWrap = True
    OnClick = DeleteGroupClick
  end
  object EditGroup: TButton
    Left = 296
    Top = 8
    Width = 129
    Height = 58
    Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1075#1088#1091#1087#1087#1091
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    WordWrap = True
    OnClick = EditGroupClick
  end
  object GroupGrid: TStringGrid
    Left = 64
    Top = 96
    Width = 473
    Height = 65
    BiDiMode = bdLeftToRight
    ColCount = 4
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    ParentBiDiMode = False
    ScrollBars = ssVertical
    TabOrder = 3
    OnSelectCell = GroupGridSelectCell
  end
  object ViewStudentsInGroupButton: TButton
    Left = 448
    Top = 8
    Width = 145
    Height = 60
    Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1089#1086#1089#1090#1072#1074#1072' '#1075#1088#1091#1087#1087#1099
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    WordWrap = True
    OnClick = ViewStudentsInGroupButtonClick
  end
  object GroupMainMenu: TMainMenu
    Left = 552
    Top = 104
    object FileDialog: TMenuItem
      Caption = #1060#1072#1081#1083
      object OpenFile: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ShortCut = 16463
        OnClick = OpenFileClick
      end
      object SaveFile: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        ShortCut = 16467
        OnClick = SaveFileClick
      end
    end
  end
  object OpenTextFileDialog: TOpenTextFileDialog
    DefaultExt = 'grplst'
    Filter = '(*.grplst)|*.grplst|(*.stdlst)|*.stdlst'
    Left = 552
    Top = 216
  end
  object SaveTextFileDialog: TSaveTextFileDialog
    DefaultExt = 'grplst'
    Filter = '(*.grplst)|*.grplst|(*.stdlst)|*.stdlst'
    Left = 552
    Top = 168
  end
end
