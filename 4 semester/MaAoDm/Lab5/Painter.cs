using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace Lab5;

public class Painter
{
    public const int Step = 20;
    private readonly int _width;
    private readonly int _height;
    private readonly Bitmap _bitmap;
    private readonly Graphics _graphics;
    private readonly PictureBox _canvas;

    public Painter(PictureBox canvas)
    {
        _canvas = canvas;
        _width = canvas.Width;
        _height = canvas.Height;
        _bitmap = new Bitmap(_width, _height);
        _graphics = Graphics.FromImage(_bitmap);
        
        _graphics.Clear(Color.White);
        _canvas.Image = _bitmap;
    }

    public int CanvasWidth => _width;
    public int CanvasHeight => _height;

    public void Clear()
    {
        _graphics.Clear(Color.White);
        _canvas.Image = _bitmap;
    }

    public void DrawAxes()
    {
        using var axisPen = new Pen(Color.Black, 2);
        _graphics.DrawLine(axisPen, 0, _height / 2, _width, _height / 2);
        _graphics.DrawLine(axisPen, _width / 2, 0, _width / 2, _height);
        _canvas.Invalidate();
    }

    public void DrawPoints(IEnumerable<Point> points, Function function)
    {
        foreach (var point in points)
        {
            Brush brush = function.GetValue(point) >= 0 ? Brushes.Orchid : Brushes.LimeGreen;
            
            int screenX = point.X * Step + _width / 2;
            int screenY = _height / 2 - point.Y * Step;
            _graphics.FillEllipse(brush, screenX - 3, screenY - 3, 6, 6);
        }

        _canvas.Invalidate();
    }
    
    public void DrawPoint(Point point, Function function)
    {
        Brush brush = function.GetValue(point) >= 0 ? Brushes.Orchid : Brushes.LimeGreen;
        
        int screenX = point.X * Step + _width / 2;
        int screenY = _height / 2 - point.Y * Step;
        _graphics.FillEllipse(brush, screenX - 3, screenY - 3, 6, 6);
        
        _canvas.Invalidate();
    }
    
    public void DrawFunction(Function function)
    {
        Pen functionPen = new Pen(Color.Tomato, 2);
        double startX = -_width / (2.0 * Step);
        double prevX = startX;
        double prevY = _height / 2.0 - function.GetY(prevX) * Step;

        for (double x = startX; x < _width / (2.0 * Step); x += 0.0002)
        {
            double screenX = _width / 2.0 + x * Step;
            double screenY = _height / 2.0 - function.GetY(x) * Step;

            try
            {
                if (Math.Abs(screenY - prevY) < _height && IsLineInGraph(prevY, screenY))
                {
                    _graphics.DrawLine(functionPen, (float)prevX, (float)prevY, (float)screenX, (float)screenY);
                }
            }
            catch (OverflowException)
            {
            }

            prevX = screenX;
            prevY = screenY;
        }

        _canvas.Invalidate();
    }

    private bool IsLineInGraph(double prevY, double nextY)
    {
        return prevY > 0 && prevY < _height && nextY > 0 && nextY < _height;
    }
}