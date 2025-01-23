object FindPathForm: TFindPathForm
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
    Left = 155
    Top = 24
    Width = 186
    Height = 41
    Caption = #1053#1072#1081#1090#1080' '#1076#1086#1088#1086#1075#1091
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -30
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object StartTLabel: TLabel
    Left = 43
    Top = 104
    Width = 430
    Height = 25
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1075#1086#1088#1086#1076' '#1086#1090' '#1082#1086#1090#1086#1088#1086#1075#1086' '#1074#1099' '#1093#1086#1090#1080#1090#1077' '#1085#1072#1081#1090#1080' '#1076#1086#1088#1086#1075#1091':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object EndLabel: TLabel
    Left = 56
    Top = 208
    Width = 373
    Height = 25
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1075#1086#1088#1086#1076' '#1082' '#1082#1086#1090#1086#1088#1086#1084#1091' '#1093#1086#1090#1080#1090#1077' '#1085#1072#1081#1090#1080' '#1087#1091#1090#1100':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object EndEdit: TEdit
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
    TabOrder = 1
    TextHint = #1050#1091#1076#1072
    OnChange = EndEditChange
    OnContextPopup = EndEditContextPopup
    OnKeyDown = EndEditKeyDown
    OnKeyPress = EndEditKeyPress
  end
  object StartEdit: TEdit
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
    TabOrder = 0
    TextHint = #1054#1090
    OnChange = StartEditChange
    OnContextPopup = StartEditContextPopup
    OnKeyDown = StartEditKeyDown
    OnKeyPress = StartEditKeyPress
  end
  object AddButton: TButton
    Left = 56
    Top = 352
    Width = 129
    Height = 57
    Caption = #1053#1072#1081#1090#1080
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
