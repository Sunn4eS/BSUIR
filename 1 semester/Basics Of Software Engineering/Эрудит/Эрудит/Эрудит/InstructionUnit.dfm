object InstructionForm: TInstructionForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1048#1085#1089#1090#1088#1091#1082#1094#1080#1103
  ClientHeight = 327
  ClientWidth = 583
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = InstructionFormOnCreate
  TextHeight = 23
  object InstructionScrollBox: TScrollBox
    Left = 1
    Top = -7
    Width = 584
    Height = 337
    VertScrollBar.Tracking = True
    TabOrder = 0
    OnMouseWheelDown = InstructionScrollBoxMouseWheelDown
    OnMouseWheelUp = InstructionScrollBoxMouseWheelUp
    object InstructionLabel: TLabel
      Left = 3
      Top = 3
      Width = 562
      Height = 46
      Caption = 
        'InstructionLabel                                                ' +
        '                                                                '
      WordWrap = True
    end
  end
end
