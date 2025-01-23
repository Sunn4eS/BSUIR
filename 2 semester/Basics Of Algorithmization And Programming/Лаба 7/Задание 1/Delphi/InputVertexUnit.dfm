object InputVertexForm: TInputVertexForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1042#1074#1086#1076' '#1074#1077#1088#1096#1080#1085#1099
  ClientHeight = 122
  ClientWidth = 328
  Color = clBtnFace
  Constraints.MaxHeight = 160
  Constraints.MaxWidth = 340
  Constraints.MinHeight = 160
  Constraints.MinWidth = 340
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -27
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnHide = FormHide
  OnHelp = FormHelp
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 37
  object Edit: TEdit
    Left = 20
    Top = 8
    Width = 300
    Height = 45
    Constraints.MaxHeight = 225
    TabOrder = 0
    TextHint = #1042#1074#1077#1076#1080#1090#1077' '#1074#1077#1088#1096#1080#1085#1091
    OnChange = EditChange
    OnContextPopup = EditContextPopup
    OnKeyDown = EditKeyDown
    OnKeyPress = EditKeyPress
    OnKeyUp = EditKeyUp
  end
  object BackButton: TButton
    Left = 180
    Top = 70
    Width = 140
    Height = 46
    Caption = #1053#1072#1079#1072#1076
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = BackButtonClick
  end
  object OkButton: TButton
    Left = 20
    Top = 70
    Width = 140
    Height = 46
    Caption = #1054#1050
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = OkButtonClick
  end
end
