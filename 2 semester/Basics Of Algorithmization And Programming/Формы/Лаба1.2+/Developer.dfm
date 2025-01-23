object DeveloperForm: TDeveloperForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1054' '#1088#1072#1079#1088#1072#1073#1086#1090#1095#1080#1082#1077
  ClientHeight = 246
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object DeveloperLabel: TLabel
    Left = 18
    Top = 32
    Width = 63
    Height = 25
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object CloseButton: TButton
    Left = 184
    Top = 192
    Width = 97
    Height = 33
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = CloseButtonClick
  end
end
