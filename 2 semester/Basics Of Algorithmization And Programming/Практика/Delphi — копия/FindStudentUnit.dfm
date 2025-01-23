object FindStudentForm: TFindStudentForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1055#1086#1080#1089#1082' '#1089#1090#1091#1076#1077#1085#1090#1072
  ClientHeight = 442
  ClientWidth = 976
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object TitleLabel: TLabel
    Left = 336
    Top = 8
    Width = 289
    Height = 41
    Caption = #1055#1086#1080#1089#1082' '#1089#1090#1091#1076#1077#1085#1090#1072' '#1087#1086' '#1060#1048#1054
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object NameLabel: TLabel
    Left = 40
    Top = 72
    Width = 39
    Height = 25
    Caption = #1048#1084#1103':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object SurnameLabel: TLabel
    Left = 40
    Top = 120
    Width = 77
    Height = 25
    Caption = #1060#1072#1084#1080#1083#1080#1103':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object PatronymicLabel: TLabel
    Left = 37
    Top = 176
    Width = 80
    Height = 25
    Caption = #1054#1090#1095#1077#1089#1090#1074#1086':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object NameEdit: TEdit
    Left = 166
    Top = 77
    Width = 121
    Height = 33
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    TextHint = #1048#1074#1072#1085
    OnChange = EditOnChange
    OnKeyDown = EditKeyDown
    OnKeyPress = EditKeyPress
  end
  object SurnameEdit: TEdit
    Left = 166
    Top = 125
    Width = 121
    Height = 33
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    TextHint = #1048#1074#1072#1085#1086#1074
    OnChange = EditOnChange
    OnKeyDown = EditKeyDown
    OnKeyPress = EditKeyPress
  end
  object PatronymicEdit: TEdit
    Left = 166
    Top = 181
    Width = 121
    Height = 33
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    TextHint = #1048#1074#1072#1085#1086#1074#1080#1095
    OnChange = EditOnChange
    OnKeyDown = EditKeyDown
    OnKeyPress = EditKeyPress
  end
  object FindStudentGrid: TStringGrid
    Left = 19
    Top = 248
    Width = 937
    Height = 120
    ColCount = 11
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
    TabOrder = 3
    ColWidths = (
      64
      64
      64
      64
      64
      64
      64
      64
      64
      64
      64)
  end
  object SearchButton: TButton
    Left = 320
    Top = 184
    Width = 81
    Height = 34
    Caption = #1053#1072#1081#1090#1080
    TabOrder = 4
    OnClick = SearchButtonClick
  end
end
