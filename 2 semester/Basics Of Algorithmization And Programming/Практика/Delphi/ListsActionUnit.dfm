object ListsActionForm: TListsActionForm
  Left = 0
  Top = 0
  Caption = 'ListsActionForm'
  ClientHeight = 442
  ClientWidth = 990
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object TitleLabel: TLabel
    Left = 376
    Top = 24
    Width = 264
    Height = 32
    Caption = #1057#1087#1080#1089#1086#1082' '#1085#1072' '#1086#1090#1095#1080#1089#1083#1077#1085#1080#1077
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ChooseLabel: TLabel
    Left = 35
    Top = 38
    Width = 185
    Height = 25
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1080#1089#1094#1080#1087#1083#1080#1085#1091':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object FindStudentGrid: TStringGrid
    Left = 35
    Top = 157
    Width = 937
    Height = 113
    ColCount = 11
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
    TabOrder = 0
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
  object DiciplineComboBox: TComboBox
    Left = 35
    Top = 69
    Width = 145
    Height = 33
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = #1051#1086#1075#1080#1082#1072
    OnChange = DiciplineComboBoxChange
  end
end
