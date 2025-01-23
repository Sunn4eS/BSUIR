object ViewGraphForm: TViewGraphForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1075#1088#1072#1092#1072
  ClientHeight = 512
  ClientWidth = 538
  Color = clBtnFace
  Constraints.MaxHeight = 550
  Constraints.MaxWidth = 550
  Constraints.MinHeight = 550
  Constraints.MinWidth = 550
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnHelp = FormHelp
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object PaintBox: TPaintBox
    Left = 0
    Top = 0
    Width = 538
    Height = 512
    Align = alClient
    OnPaint = PaintBoxPaint
    ExplicitLeft = 25
    ExplicitTop = 8
    ExplicitWidth = 555
    ExplicitHeight = 557
  end
end
