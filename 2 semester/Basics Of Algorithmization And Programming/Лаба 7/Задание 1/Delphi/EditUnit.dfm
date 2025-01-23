object EditForm: TEditForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077
  ClientHeight = 262
  ClientWidth = 328
  Color = clBtnFace
  Constraints.MaxHeight = 300
  Constraints.MaxWidth = 340
  Constraints.MinHeight = 300
  Constraints.MinWidth = 340
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnHelp = FormHelp
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object AddButton: TButton
    Left = 70
    Top = 16
    Width = 163
    Height = 57
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = AddButtonClick
  end
  object DeleteButton: TButton
    Left = 70
    Top = 96
    Width = 163
    Height = 58
    Caption = #1059#1076#1072#1083#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = DeleteButtonClick
  end
  object BackButton: TButton
    Left = 70
    Top = 176
    Width = 163
    Height = 58
    Caption = #1053#1072#1079#1072#1076
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = BackButtonClick
  end
end
