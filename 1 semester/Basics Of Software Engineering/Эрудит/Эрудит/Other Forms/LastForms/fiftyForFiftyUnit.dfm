object FiftyForFiftyForm: TFiftyForFiftyForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '50 '#1085#1072' 50'
  ClientHeight = 103
  ClientWidth = 317
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 20
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 142
    Height = 20
    Caption = #1042#1072#1096' '#1090#1077#1082#1091#1097#1080#1081' '#1085#1072#1073#1086#1088':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 175
    Top = 8
    Width = 98
    Height = 20
    Caption = #1049#1042#1053#1056#1052#1050#1067#1047#1047#1059
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 34
    Width = 90
    Height = 20
    Caption = #1047#1072#1084#1077#1085#1072' '#1073#1091#1082#1074':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 181
    Top = 31
    Width = 117
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    MaxLength = 5
    ParentFont = False
    TabOrder = 0
    TextHint = '5 '#1073#1091#1082#1074
    OnChange = Edit1Change
    OnKeyPress = Edit1KeyPress
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 65
    Width = 290
    Height = 25
    Caption = #1055#1086#1076#1090#1074#1077#1088#1076#1080#1090#1100' '#1079#1072#1084#1077#1085#1091
    Default = True
    Enabled = False
    ModalResult = 2
    NumGlyphs = 2
    TabOrder = 1
    OnClick = BitBtn1Click
  end
end
