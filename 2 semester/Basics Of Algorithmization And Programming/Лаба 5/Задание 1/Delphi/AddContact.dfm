object AddContactForm: TAddContactForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 448
  ClientWidth = 511
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnHelp = FormHelp
  OnKeyDown = FormKeyDown
  TextHeight = 15
  object StartLabel: TLabel
    Left = 88
    Top = 40
    Width = 340
    Height = 41
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1085#1086#1074#1099#1081' '#1082#1086#1085#1090#1072#1082#1090
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -30
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object NameLabel: TLabel
    Left = 131
    Top = 104
    Width = 247
    Height = 25
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1080#1084#1103' '#1085#1086#1074#1086#1075#1086' '#1082#1086#1085#1090#1072#1082#1090#1072':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object NemberLabel: TLabel
    Left = 131
    Top = 208
    Width = 209
    Height = 25
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1085#1086#1084#1077#1088' '#1090#1077#1083#1077#1092#1086#1085#1072':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object NumberEdit: TEdit
    Left = 131
    Top = 263
    Width = 233
    Height = 40
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Orientation = 6
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    TextHint = #1053#1086#1084#1077#1088' '#1090#1077#1083#1077#1092#1086#1085#1072
    OnChange = NumberEditChange
    OnContextPopup = NumberEditContextPopup
    OnKeyDown = NumberEditKeyDown
    OnKeyPress = NumberEditKeyPress
  end
  object NameEdit: TEdit
    Left = 131
    Top = 151
    Width = 233
    Height = 40
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Orientation = 6
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    TextHint = #1048#1084#1103
    OnChange = NameEditChange
    OnContextPopup = NameEditContextPopup
    OnKeyDown = NameEditKeyDown
    OnKeyPress = NameEditKeyPress
  end
  object AddButton: TButton
    Left = 56
    Top = 352
    Width = 129
    Height = 57
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = AddButtonClick
  end
  object CancelButton: TButton
    Left = 320
    Top = 352
    Width = 129
    Height = 57
    Caption = #1054#1090#1084#1077#1085#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = CancelButtonClick
  end
end
