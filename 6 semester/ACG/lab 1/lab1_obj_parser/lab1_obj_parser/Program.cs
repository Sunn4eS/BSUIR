using lab1_obj_parser;
using System;
using System.Drawing;
using System.Globalization;
using System.Windows.Forms;

namespace Lab1_3D
{
    
    public partial class MainForm : Form
    {
        private Model _model;
        private LinkerForRender _linker;
        private CameraControl _controller;

        // Элементы интерфейса
        private Button _btnLoad;
        
        public MainForm()
        {
            
            this.DoubleBuffered = true;
            this.Width = 1024;
            this.Height = 768;
            this.Text = "3D Viewer | Нет файла";

            _btnLoad = new Button();
            _btnLoad.Text = "Загрузить .obj";
            _btnLoad.Location = new Point(10, 10);
            _btnLoad.Size = new Size(120, 30);
            _btnLoad.BackColor = Color.LightGray;
            _btnLoad.Click += (s, e) => LoadModel(); 
            this.Controls.Add(_btnLoad); 

            _linker = new LinkerForRender(this.ClientSize.Width, this.ClientSize.Height);

            _linker.CameraPosition = new Vec4(0, 0, -50);

            // 4. Инициализация контроллера мыши
            _controller = new CameraControl(_linker, () => this.Invalidate());

            // Подписываемся на события мыши (чтобы вращать модель)
            this.MouseDown += (s, e) => _controller.OnMouseDown(e);
            this.MouseUp += (s, e) => _controller.OnMouseUp(e);
            this.MouseMove += (s, e) => _controller.OnMouseMove(e);
            this.MouseWheel += (s, e) => _controller.OnMouseWheel(e);

            // Ресайз окна
            this.Resize += (s, e) =>
            {
                _linker.Width = ClientSize.Width;
                _linker.Height = ClientSize.Height;
                this.Invalidate();
            };
        }

        // Метод загрузки файла
        private void LoadModel()
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "OBJ files|*.obj|All files|*.*";
            ofd.Title = "Выберите 3D модель";

            if (ofd.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    // Парсим файл
                    _model = new Model(ofd.FileName);

                    // Сбрасываем трансформации (чтобы новая модель была в центре)
                    _linker.ModelPosition = new Vec4(0, 0, 0);
                    _linker.ModelRotation = new Vec4(0, 0, 0);
                    _linker.ModelScale = new Vec4(1, 1, 1);

                    // Обновляем заголовок окна
                    this.Text = $"3D Viewer | {System.IO.Path.GetFileName(ofd.FileName)}";

                    // Возвращаем фокус форме, чтобы колесико мыши работало сразу
                    this.Focus();

                    // Перерисовка
                    this.Invalidate();
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Ошибка при чтении файла:\n{ex.Message}", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);

            // Создаем холст
            Bitmap bmp = new Bitmap(ClientSize.Width, ClientSize.Height);

            using (Graphics g = Graphics.FromImage(bmp))
            {
                // Заливаем фон
                g.Clear(Color.White);

                // Если модель загружена - рисуем её
                if (_model != null)
                {
                    Rasterizer rasterizer = new Rasterizer(bmp);
                    _linker.Render(_model, rasterizer);
                }
                else
                {
                    // Если модели нет, пишем инструкцию
                    string msg = "Нажмите кнопку 'Загрузить .obj', чтобы открыть модель";
                    Font font = new Font("Arial", 14);
                    SizeF size = g.MeasureString(msg, font);
                    g.DrawString(msg, font, Brushes.Gray,
                        (ClientSize.Width - size.Width) / 2,
                        (ClientSize.Height - size.Height) / 2);
                }
            }

            // Выводим результат на экран
            e.Graphics.DrawImage(bmp, 0, 0);

            // Отрисовка кнопки поверх битмапа происходит автоматически, 
            // так как она добавлена в this.Controls

            bmp.Dispose();
        }

        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }
    }
}