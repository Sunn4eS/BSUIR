object InstructionForm: TInstructionForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
  ClientHeight = 218
  ClientWidth = 518
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  Scaled = False
  OnCreate = FormCreate
  TextHeight = 15
  object InstructionLabel: TLabel
    Left = 24
    Top = 32
    Width = 5
    Height = 25
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
  end
  object CloseButton: TButton
    Left = 200
    Top = 160
    Width = 97
    Height = 35
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = CloseButtonClick
  end
end
