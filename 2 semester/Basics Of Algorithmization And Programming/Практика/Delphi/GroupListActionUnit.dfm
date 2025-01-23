object GroupListActionForm: TGroupListActionForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'GroupListActionForm'
  ClientHeight = 352
  ClientWidth = 448
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 25
  object TitleLabel: TLabel
    Left = 24
    Top = 24
    Width = 203
    Height = 32
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object NumberLabel: TLabel
    Left = 24
    Top = 89
    Width = 139
    Height = 28
    Caption = #1053#1086#1084#1077#1088' '#1075#1088#1091#1087#1087#1099':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object YearLabel: TLabel
    Left = 24
    Top = 152
    Width = 163
    Height = 28
    Caption = #1043#1086#1076' '#1086#1073#1088#1072#1079#1086#1074#1072#1085#1080#1103':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object CodeLabel: TLabel
    Left = 24
    Top = 216
    Width = 183
    Height = 28
    Caption = #1050#1086#1076' '#1089#1087#1077#1094#1080#1072#1083#1100#1085#1086#1089#1090#1080':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object ActionButton: TButton
    Left = 32
    Top = 288
    Width = 113
    Height = 43
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = ActionButtonClick
  end
  object CancelButton: TButton
    Left = 280
    Top = 288
    Width = 113
    Height = 43
    Caption = #1054#1090#1084#1077#1085#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = CancelButtonClick
  end
  object NumberEdit: TEdit
    Left = 256
    Top = 86
    Width = 153
    Height = 33
    TabOrder = 2
    TextHint = '351001'
    OnChange = EditChange
    OnContextPopup = EditContextPopup
    OnKeyDown = EditKeyDown
    OnKeyPress = NumberEditKeyPress
  end
  object YearEdit: TEdit
    Left = 256
    Top = 149
    Width = 153
    Height = 33
    TabOrder = 3
    TextHint = '2023'
    OnChange = EditChange
    OnContextPopup = EditContextPopup
    OnKeyDown = EditKeyDown
    OnKeyPress = YearEditKeyPress
  end
  object CodeEdit: TEdit
    Left = 256
    Top = 213
    Width = 153
    Height = 33
    TabOrder = 4
    TextHint = '1-08 01 01'
    OnChange = EditChange
    OnContextPopup = EditContextPopup
    OnKeyDown = EditKeyDown
    OnKeyPress = CodeEditKeyPress
  end
end
