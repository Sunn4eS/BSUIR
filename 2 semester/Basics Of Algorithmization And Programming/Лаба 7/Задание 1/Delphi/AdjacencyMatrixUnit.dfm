object AdjacencyMatrixForm: TAdjacencyMatrixForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1052#1072#1090#1088#1080#1094#1072' '#1089#1084#1077#1078#1085#1086#1089#1090#1080
  ClientHeight = 512
  ClientWidth = 538
  Color = clBtnFace
  Constraints.MaxHeight = 550
  Constraints.MaxWidth = 550
  Constraints.MinHeight = 550
  Constraints.MinWidth = 550
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -20
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnHelp = FormHelp
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 28
  object AdjacencyMatrixStringGrid: TStringGrid
    Left = 0
    Top = 0
    Width = 538
    Height = 512
    Align = alClient
    DefaultRowHeight = 30
    TabOrder = 0
    ExplicitWidth = 622
    ExplicitHeight = 433
  end
end
