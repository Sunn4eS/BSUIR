object Form15: TForm15
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077' '#1087#1088#1077#1087#1086#1076#1086#1074#1072#1090#1077#1083#1103
  ClientHeight = 447
  ClientWidth = 575
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  Position = poDesktopCenter
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 225
    Top = 40
    Width = 145
    Height = 41
    Caption = #1047#1072#1085#1103#1090#1086#1089#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -30
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 238
    Top = 315
    Width = 111
    Height = 25
    Caption = #1048#1084#1103' '#1091#1095#1080#1090#1077#1083#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Schedule: TStringGrid
    Left = 8
    Top = 111
    Width = 560
    Height = 202
    ColCount = 7
    DefaultColWidth = 110
    RowCount = 7
    ScrollBars = ssHorizontal
    TabOrder = 0
  end
  object TeachName: TEdit
    Left = 222
    Top = 346
    Width = 141
    Height = 23
    ImeName = 'TeachName'
    PopupMenu = PopupMenu1
    TabOrder = 1
    OnChange = TeachNameChange
    OnKeyPress = TeachNameKeyPress
  end
  object Fill: TButton
    Left = 222
    Top = 384
    Width = 141
    Height = 40
    Caption = #1047#1072#1087#1086#1083#1085#1080#1090#1100
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = FillClick
  end
  object MainMenu1: TMainMenu
    Left = 408
    Top = 40
    object N1: TMenuItem
      ShortCut = 112
      OnClick = N1Click
      object gg: TMenuItem
        ShortCut = 16470
      end
    end
    object ShiftBlocker: TMenuItem
      ShortCut = 8237
      Visible = False
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 120
    Top = 376
  end
end
