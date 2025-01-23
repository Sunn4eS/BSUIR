object StudentsInGroupActionForm: TStudentsInGroupActionForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1057#1090#1091#1076#1077#1085#1090
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 25
  object TitleLabel: TLabel
    Left = 32
    Top = 24
    Width = 255
    Height = 32
    Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1080#1077' '#1089#1090#1091#1076#1077#1085#1090#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object NameLabel: TLabel
    Left = 40
    Top = 96
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
    Top = 144
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
    Top = 200
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
  object MarksLabel: TLabel
    Left = 40
    Top = 264
    Width = 67
    Height = 25
    Caption = #1054#1094#1077#1085#1082#1080':'
  end
  object GroupNumberLabel: TLabel
    Left = 320
    Top = 96
    Width = 126
    Height = 25
    Caption = #1053#1086#1084#1077#1088' '#1075#1088#1091#1087#1087#1099':'
  end
  object NameEdit: TEdit
    Left = 166
    Top = 101
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
    OnChange = EditChange
    OnContextPopup = EditContextPopup
    OnKeyDown = EditKeyDown
    OnKeyPress = EditKeyPress
  end
  object SurnameEdit: TEdit
    Left = 166
    Top = 149
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
    OnChange = EditChange
    OnContextPopup = EditContextPopup
    OnKeyDown = EditKeyDown
    OnKeyPress = EditKeyPress
  end
  object PatronymicEdit: TEdit
    Left = 166
    Top = 205
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
    OnChange = EditChange
    OnContextPopup = EditContextPopup
    OnKeyDown = EditKeyDown
    OnKeyPress = EditKeyPress
  end
  object MarkGrid: TStringGrid
    Left = 166
    Top = 264
    Width = 395
    Height = 57
    ColCount = 6
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goFixedRowDefAlign]
    TabOrder = 3
    OnKeyPress = MarkGridKeyPress
    OnSetEditText = MarkGridSetEditText
  end
  object ActionButton: TButton
    Left = 32
    Top = 376
    Width = 105
    Height = 41
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    Enabled = False
    TabOrder = 4
    OnClick = ActionButtonClick
  end
  object CancelButton: TButton
    Left = 464
    Top = 376
    Width = 115
    Height = 41
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 5
    OnClick = CancelButtonClick
  end
  object GroupNumberEdit: TEdit
    Left = 464
    Top = 101
    Width = 121
    Height = 33
    TabOrder = 6
    OnChange = EditChange
    OnContextPopup = EditContextPopup
    OnKeyDown = EditKeyDown
    OnKeyPress = GroupNumberEditKeyPress
  end
end
