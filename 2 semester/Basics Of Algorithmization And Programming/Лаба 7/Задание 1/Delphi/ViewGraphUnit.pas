Unit ViewGraphUnit;

Interface

Uses
    Winapi.Windows,
    System.SysUtils, System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
    VertexListUnit, EdgeListUnit;

Type
    TViewGraphForm = Class(TForm)
        PaintBox: TPaintBox;

        Procedure CreateParams(Var Params: TCreateParams); Override;
        Function FormHelp(Command: Word; Data: NativeInt; Var CallHelp: Boolean): Boolean;
        Procedure FormShow(Sender: TObject);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);

        Procedure PaintBoxPaint(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    ViewGraphForm: TViewGraphForm;

Implementation

{$R *.dfm}

Uses
    Math,
    MenuUnit;

Const
    VertexSize = 30;

Procedure TViewGraphForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Function TViewGraphForm.FormHelp(Command: Word; Data: NativeInt; Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
    Result := False;
End;

Procedure TViewGraphForm.FormShow(Sender: TObject);
Begin
    PaintBoxPaint(PaintBox);
End;

Procedure TViewGraphForm.FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
Begin
    If Key = VK_ESCAPE Then
        Close;
End;


Procedure DrawEdge(PaintBox: TPaintBox; Const X1, Y1, X2, Y2: Integer);
Begin
    With PaintBox.Canvas Do
    Begin
        MoveTo(X1 + VertexSize Div 2,
               Y1 + VertexSize Div 2);
        LineTo(X2 + VertexSize Div 2,
               Y2 + VertexSize Div 2);
    End;
End;

Procedure DrawEdges(PaintBox: TPaintBox; Const CenterX, CenterY, Distance: Integer; Const RotateAngle: Real; Vertex1: PVertex; IndexNode1: Integer);
Var
    CurrNode: PEdge;
    Vertex2: PVertex;
    IndexNode2: Integer;
Begin
    CurrNode := Vertex1^.Edges.Head;
    While CurrNode <> Nil Do
    Begin
        Vertex2 := Vertex1^.Next;
        IndexNode2 := IndexNode1 + 1;
        While (Vertex2 <> Nil) And (Vertex2^.Value <> CurrNode^.Value) Do
        Begin
            Inc(IndexNode2);
            Vertex2 := Vertex2^.Next;
        End;

        If Vertex2 <> Nil Then
            DrawEdge(PaintBox,
                     Round(CenterX + Distance * Sin(IndexNode1 * RotateAngle)),
                     Round(CenterY - Distance * Cos(IndexNode1 * RotateAngle)),
                     Round(CenterX + Distance * Sin(IndexNode2 * RotateAngle)),
                     Round(CenterY - Distance * Cos(IndexNode2 * RotateAngle)));
        CurrNode := CurrNode^.Next;
    End;
End;

Procedure DrawVertex(PaintBox: TPaintBox; Const X, Y: Integer; Const Text: String);
Begin
    With PaintBox.Canvas Do
    Begin
        Ellipse(X,
                Y,
                X + VertexSize,
                Y + VertexSize);
        TextOut(X + (VertexSize - TextWidth(Text)) Div 2,
                Y + (VertexSize - TextHeight(Text)) Div 2,
                Text);
    End;
End;

Procedure DrawVerteces(PaintBox: TPaintBox; Const CenterX, CenterY, Distance: Integer; Const RotateAngle: Real);
Var
    Angle: Real;
    CurrNode: PVertex;
    IndexNode: Integer;
Begin
    Angle := 0;
    CurrNode := Graph.Head;
    IndexNode := 0;
    While CurrNode <> Nil Do
    Begin
        DrawEdges(PaintBox, CenterX, CenterY, Distance, RotateAngle, CurrNode, IndexNode);
        DrawVertex(PaintBox,
                   Round(CenterX + Distance * Sin(Angle)),
                   Round(CenterY - Distance * Cos(Angle)),
                   IntToStr(CurrNode^.Value));
        Angle := Angle + RotateAngle;
        CurrNode := CurrNode^.Next;
        Inc(IndexNode);
    End;
End;

Procedure TViewGraphForm.PaintBoxPaint(Sender: TObject);
Var
    CenterX, CenterY, Distance: Integer;
    RotateAngle: Real;
Begin
    If Graph.Count <> 0 Then
    Begin
        PaintBox.Canvas.Pen.Width := 1;
        PaintBox.Canvas.Brush.Color := clWhite;
    
        CenterX := PaintBox.Width Div 2;
        CenterY := PaintBox.Height Div 2;
        Distance := Round(LogN(2, Graph.Count) * VertexSize);
        RotateAngle := 2 * Pi / Graph.Count;

        DrawVerteces(PaintBox, CenterX, CenterY, Distance, RotateAngle);
    End;
End;

End.
