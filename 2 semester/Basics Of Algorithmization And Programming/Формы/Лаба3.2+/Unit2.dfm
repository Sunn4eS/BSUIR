object InstructionForm: TInstructionForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
  ClientHeight = 189
  ClientWidth = 329
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object InstructionLabel1: TLabel
    Left = 16
    Top = 13
    Width = 211
    Height = 52
    Caption = '1. '#1042#1074#1077#1076#1080#1090#1077' '#1085#1072#1090#1091#1088#1072#1083#1100#1085#1086#1077' '#1095#1080#1089#1083#1086' N '#1074' '#1076#1080#1072#1087#1072#1079#1086#1085#1077' [2; 10000]. '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object InstructionLabel4: TLabel
    Left = 16
    Top = 71
    Width = 211
    Height = 60
    Caption = 
      '2. '#1042' '#1092#1072#1081#1083#1077' '#1076#1086#1083#1078#1085#1099' '#1073#1099#1090#1100' '#1086#1076#1085#1072' '#1089#1090#1088#1086#1082#1072', '#1089#1086#1076#1077#1088#1078#1072#1097#1072#1103' '#1085#1072#1090#1091#1088#1072#1083#1100#1085#1086#1077' '#1095#1080#1089#1083#1086 +
      ' N.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object CloseButton: TButton
    Left = 280
    Top = 360
    Width = 75
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = CloseButtonClick
  end
end
