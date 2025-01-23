unit CanvasUnit;

interface
Uses
    Vcl.Graphics, System.Types;

procedure ClearCanvas(const Canvas: TCanvas; const Rect: TRect);
implementation

procedure ClearCanvas(const Canvas: TCanvas; const Rect: TRect);
begin
  Canvas.Brush.Color := clBlack; // ������� ���� �������, ��������, ������
  Canvas.FillRect(Rect);
end;

Function ClearAlienRect(Const Canvas: TCanvas): Boolean;
Begin

End;
end.
