object StartForm: TStartForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1069#1088#1091#1076#1080#1090
  ClientHeight = 341
  ClientWidth = 577
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = TabsMainMenu
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  TextHeight = 23
  object TitleLabel: TLabel
    Left = 240
    Top = 24
    Width = 114
    Height = 45
    Caption = #1069#1088#1091#1076#1080#1090
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -33
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LanguageLabel: TLabel
    Left = 48
    Top = 88
    Width = 248
    Height = 23
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1103#1079#1099#1082' '#1074#1074#1086#1076#1080#1084#1099#1093' '#1089#1083#1086#1074':'
  end
  object PlayersLabel: TLabel
    Left = 56
    Top = 184
    Width = 240
    Height = 23
    AutoSize = False
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1095#1080#1089#1083#1086' '#1080#1075#1088#1086#1082#1086#1074':'
  end
  object LanguageComboBox: TComboBox
    Left = 48
    Top = 128
    Width = 248
    Height = 31
    Style = csDropDownList
    TabOrder = 0
    OnChange = LanguageComboBoxChange
    OnClick = PlayersComboBoxClick
    OnKeyDown = PlayersComboBoxKeyDown
    Items.Strings = (
      #1040#1085#1075#1083#1080#1081#1089#1082#1080#1081
      #1056#1091#1089#1089#1082#1080#1081)
  end
  object PlayersComboBox: TComboBox
    Left = 48
    Top = 213
    Width = 248
    Height = 31
    Style = csDropDownList
    TabOrder = 1
    OnChange = PlayersComboBoxChange
    OnClick = PlayersComboBoxClick
    OnKeyDown = PlayersComboBoxKeyDown
    Items.Strings = (
      '2'
      '3'
      '4'
      '5')
  end
  object PlayButton: TButton
    Left = 240
    Top = 272
    Width = 114
    Height = 41
    Caption = #1048#1043#1056#1040#1058#1068
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    TabOrder = 2
    OnClick = PlayButtonClick
  end
  object TabsMainMenu: TMainMenu
    Left = 584
    Top = 24
    object InstructionTab: TMenuItem
      Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
      OnClick = InstructionTabOnClick
    end
    object DeveloperTab: TMenuItem
      Caption = #1054' '#1088#1072#1079#1088#1072#1073#1086#1090#1095#1080#1082#1072#1093
      OnClick = DeveloperTabOnClick
    end
  end
end
