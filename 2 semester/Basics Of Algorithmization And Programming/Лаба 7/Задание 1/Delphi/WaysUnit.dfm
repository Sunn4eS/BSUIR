object WayForm: TWayForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1055#1091#1090#1080
  ClientHeight = 512
  ClientWidth = 957
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object PaintBox: TPaintBox
    Left = 319
    Top = 24
    Width = 633
    Height = 486
    OnPaint = PaintBoxPaint
  end
  object WaysGrid: TStringGrid
    Left = 24
    Top = 24
    Width = 289
    Height = 161
    ColCount = 4
    FixedCols = 0
    RowCount = 6
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Segoe UI'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goFixedRowDefAlign]
    ParentFont = False
    TabOrder = 0
    OnSelectCell = WaysGridSelectCell
  end
end
