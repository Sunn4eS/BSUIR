object InstructionForm: TInstructionForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
  ClientHeight = 291
  ClientWidth = 510
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object InstructionLabel1: TLabel
    Left = 8
    Top = 18
    Width = 352
    Height = 60
    Caption = 
      '1. '#1042#1074#1077#1076#1080#1090#1077' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1090#1088#1086#1082' '#1080' '#1089#1090#1086#1083#1073#1094#1086#1074' '#1084#1072#1090#1088#1080#1094#1099'. '#1047#1085#1072#1095#1077#1085#1080#1103' '#1076#1086#1083#1078#1085#1099' ' +
      #1073#1099#1090#1100' '#1085#1072#1090#1091#1088#1072#1083#1100#1085#1099#1084' '#1095#1080#1089#1083#1086#1084' '#1074' '#1076#1080#1072#1087#1072#1079#1086#1085#1077' [2; 5]. '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object InstructionLabel4: TLabel
    Left = 8
    Top = 141
    Width = 374
    Height = 120
    Caption = 
      '3. '#1042' '#1092#1072#1081#1083#1077' '#1085#1072' '#1087#1077#1088#1074#1086#1081' '#1089#1090#1088#1086#1082#1077' '#1076#1086#1083#1078#1085#1085#1086' '#1089#1086#1076#1077#1088#1078#1072#1090#1100' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1090#1088#1086#1082' '#1084 +
      #1072#1090#1088#1080#1094#1099'. '#1042#1090#1086#1088#1072#1103' '#1089#1090#1088#1086#1082#1072' '#1076#1086#1083#1078#1085#1072' '#1089#1086#1076#1077#1088#1078#1072#1090#1100' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1090#1086#1083#1073#1094#1086#1074' '#1084#1072#1090#1088#1080 +
      #1094#1099'.  '#1044#1072#1083#1077#1077' '#1089#1083#1077#1076#1091#1077#1090' '#1084#1072#1090#1088#1080#1094#1072', '#1075#1076#1077' '#1082#1072#1078#1076#1072#1103' '#1089#1090#1088#1086#1082#1072' '#1079#1072#1087#1080#1089#1099#1074#1072#1077#1090#1089#1103' '#1085#1072' '#1085#1086 +
      #1074#1086#1081' '#1089#1090#1088#1086#1082#1077', '#1072' '#1101#1083#1077#1084#1077#1085#1090#1099' '#1089#1090#1088#1086#1082#1080' '#1088#1072#1079#1076#1077#1083#1103#1102#1090#1089#1103' '#1087#1088#1086#1073#1077#1083#1086#1084'. '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object InstructionLabel2: TLabel
    Left = 8
    Top = 95
    Width = 465
    Height = 60
    Caption = 
      '2.'#1042#1074#1077#1076#1080#1090#1077' '#1101#1083#1077#1084#1077#1085#1090#1099' '#1084#1072#1090#1088#1080#1094#1099' '#1076#1086#1083#1078#1085#1099' '#1073#1099#1090#1100' '#1094#1077#1083#1099#1084#1080' '#1095#1080#1089#1083#1072#1084#1080' '#1074' '#1076#1080#1072#1087#1086#1079#1086#1085 +
      #1077'   [-99; 100] '
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
