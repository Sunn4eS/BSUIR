object DeleteLeafForm: TDeleteLeafForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1059#1076#1072#1083#1077#1085#1080#1077' '#1091#1079#1083#1072
  ClientHeight = 171
  ClientWidth = 259
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  Scaled = False
  TextHeight = 15
  object NameEdit: TLabel
    Left = 8
    Top = 16
    Width = 189
    Height = 25
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1079#1085#1072#1095#1077#1085#1080#1077' '#1091#1079#1083#1072':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object DelButton: TButton
    Left = 8
    Top = 112
    Width = 107
    Height = 41
    Caption = #1059#1076#1072#1083#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = DelButtonClick
  end
  object CancelButton: TButton
    Left = 144
    Top = 112
    Width = 105
    Height = 41
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
  object EnterEdit: TEdit
    Left = 8
    Top = 47
    Width = 241
    Height = 42
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    TextHint = #1047#1085#1072#1095#1077#1085#1080#1077' '#1091#1079#1083#1072
    OnChange = EnterEditChange
    OnContextPopup = EnterEditContextPopup
    OnKeyDown = EnterEditKeyDown
    OnKeyPress = EnterEditKeyPress
  end
end
