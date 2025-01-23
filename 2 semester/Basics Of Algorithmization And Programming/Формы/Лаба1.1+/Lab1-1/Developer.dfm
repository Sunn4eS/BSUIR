object DeveloperForm: TDeveloperForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1054' '#1088#1072#1079#1088#1072#1073#1086#1090#1095#1080#1082#1077
  ClientHeight = 205
  ClientWidth = 444
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object DeveloperLabel: TLabel
    Left = 21
    Top = 32
    Width = 5
    Height = 25
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object CloseButton: TButton
    Left = 168
    Top = 144
    Width = 105
    Height = 31
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = CloseButtonClick
  end
end
