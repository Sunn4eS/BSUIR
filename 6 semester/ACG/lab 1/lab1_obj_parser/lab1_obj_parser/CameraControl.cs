
using System;
using System.Drawing;
using System.Windows.Forms;

namespace lab1_obj_parser
{
    public class CameraControl
    {
        private LinkerForRender _linker;
        private Point _lastMousePosition;
        private bool _isLeftMouseDown = false;
        private bool _isRightMouseDown = false;
        private Action _onUpdate; 

       
        private const double ROTATION_SPEED = 0.01;
        private const double MOVE_SPEED = 0.05;
        private const double ZOOM_SPEED = 0.3;

        public CameraControl(LinkerForRender linker, Action onUpdateCallback)
        {
            _linker = linker;
            _onUpdate = onUpdateCallback;
        }

        // Обработка нажатия кнопки
        public void OnMouseDown(MouseEventArgs e)
        {
            _lastMousePosition = e.Location;

            if (e.Button == MouseButtons.Left)
                _isLeftMouseDown = true;
            else if (e.Button == MouseButtons.Right)
                _isRightMouseDown = true;
        }

        // Обработка отпускания кнопки
        public void OnMouseUp(MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
                _isLeftMouseDown = false;
            else if (e.Button == MouseButtons.Right)
                _isRightMouseDown = false;
        }

        // Обработка движения мыши
        public void OnMouseMove(MouseEventArgs e)
        {
            int deltaX = e.X - _lastMousePosition.X;
            int deltaY = e.Y - _lastMousePosition.Y;

            bool changed = false;

            if (_isLeftMouseDown)
            {
                var currentRot = _linker.ModelRotation;
                _linker.ModelRotation = new Vec4(
                    currentRot.X + deltaY * ROTATION_SPEED,
                    currentRot.Y + deltaX * ROTATION_SPEED,
                    currentRot.Z
                );
                changed = true;
            }

            // Перемещение (ПКМ)
            if (_isRightMouseDown)
            {
                var currentPos = _linker.ModelPosition;
                _linker.ModelPosition = new Vec4(
                    currentPos.X + deltaX * MOVE_SPEED,
                    currentPos.Y - deltaY * MOVE_SPEED,
                    currentPos.Z
                );
                changed = true;
            }

            if (changed)
            {
                _lastMousePosition = e.Location;
                _onUpdate?.Invoke();
            }
            else
            {
                _lastMousePosition = e.Location;
            }
        }

        // Обработка колесика (Масштабирование)
        public void OnMouseWheel(MouseEventArgs e)
        {
            double scaleFactor = (e.Delta > 0) ? (1 + ZOOM_SPEED) : (1 - ZOOM_SPEED);

            var currentScale = _linker.ModelScale;

            double newScaleX = Math.Max(0.1, currentScale.X * scaleFactor);
            double newScaleY = Math.Max(0.1, currentScale.Y * scaleFactor);
            double newScaleZ = Math.Max(0.1, currentScale.Z * scaleFactor);

            _linker.ModelScale = new Vec4(newScaleX, newScaleY, newScaleZ);

            _onUpdate?.Invoke();
        }
    }
}