using Lab6.models;
using OxyPlot;
using OxyPlot.Axes;
using OxyPlot.Legends;
using OxyPlot.Series;

namespace Lab6;

public class OxyPlotDrawer
{
    private readonly List<OxyColor> _colors = new()
    {
        OxyColors.Red, OxyColors.Blue, OxyColors.Green, OxyColors.Orange, OxyColors.Purple,
        OxyColors.Brown, OxyColors.Cyan, OxyColors.Magenta, OxyColors.Yellow, OxyColors.Gray,
        OxyColors.Pink, OxyColors.Teal, OxyColors.Lime, OxyColors.Violet, OxyColors.Gold,
        OxyColors.Turquoise, OxyColors.DarkRed, OxyColors.DarkBlue, OxyColors.DarkGreen,
        OxyColors.DarkOrange, OxyColors.DarkViolet, OxyColors.LightBlue, OxyColors.LightCoral,
        OxyColors.LightGreen, OxyColors.LightPink, OxyColors.LightGoldenrodYellow,
        OxyColors.LightSlateGray, OxyColors.LightSeaGreen, OxyColors.Salmon, OxyColors.Sienna,
        OxyColors.Olive, OxyColors.Navy, OxyColors.Chocolate, OxyColors.Crimson,
        OxyColors.Indigo, OxyColors.Plum, OxyColors.Peru, OxyColors.Tomato
    };

    private int _nextColor;

    public PlotModel Draw(OxyGroup rootGroup)
    {
        var plotModel = new PlotModel { Title = "Дендограмма кластеризации" };
        plotModel.Axes.Add(new LinearAxis { Position = AxisPosition.Bottom, MinimumPadding = 0.1, MaximumPadding = 0.1 });
        plotModel.Axes.Add(new LinearAxis { Position = AxisPosition.Left, MinimumPadding = 0.1, MaximumPadding = 0.1 });
            
        DrawSubGroups(plotModel, rootGroup);
            
        return plotModel;
    }

    private void DrawSubGroups(PlotModel plotModel, OxyGroup group)
    {
        var color = _colors[_nextColor % _colors.Count];
        _nextColor++;

        // Добавляем точку группы
        var pointSeries = new ScatterSeries
        {
            MarkerType = MarkerType.Circle, 
            MarkerSize = 5, 
            MarkerFill = color,
            Title = group.Name,
        };
        pointSeries.Points.Add(new ScatterPoint(group.X, group.Y));
        plotModel.Series.Add(pointSeries);

        // Добавляем легенду
        plotModel.Legends.Add(new Legend
        {
            LegendPlacement = LegendPlacement.Outside,
            LegendPosition = LegendPosition.RightTop,
            LegendBackground = OxyColors.White,
            LegendBorder = OxyColors.Black
        });

        // Отрисовка линий
        if (group.ParentGroup1 != null && group.ParentGroup2 != null)
        {
            var lineSeries = new LineSeries { Color = color, StrokeThickness = 2 };
            lineSeries.Points.Add(new DataPoint(group.ParentGroup1.X, group.ParentGroup1.Y));
            lineSeries.Points.Add(new DataPoint(group.ParentGroup1.X, group.Y));
            lineSeries.Points.Add(new DataPoint(group.ParentGroup2.X, group.Y));
            lineSeries.Points.Add(new DataPoint(group.ParentGroup2.X, group.ParentGroup2.Y));
            
            plotModel.Series.Add(lineSeries);
            
            DrawSubGroups(plotModel, group.ParentGroup1);
            DrawSubGroups(plotModel, group.ParentGroup2);
        }
    }
}
