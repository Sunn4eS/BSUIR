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

            _linker.CameraPosition = new Vec4(0, 0, -300);

            _controller = new CameraControl(_linker, () => this.Invalidate());

            this.MouseDown += (s, e) => _controller.OnMouseDown(e);
            this.MouseUp += (s, e) => _controller.OnMouseUp(e);
            this.MouseMove += (s, e) => _controller.OnMouseMove(e);
            this.MouseWheel += (s, e) => _controller.OnMouseWheel(e);

            this.Resize += (s, e) =>
            {
                _linker.Width = ClientSize.Width;
                _linker.Height = ClientSize.Height;
                this.Invalidate();
            };
        }

        private void LoadModel()
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "OBJ files|*.obj|All files|*.*";
            ofd.Title = "Выберите 3D модель";

            if (ofd.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    _model = new Model(ofd.FileName);

                    _linker.ModelPosition = new Vec4(0, 0, 0);
                    _linker.ModelRotation = new Vec4(0, 0, 0);
                    _linker.ModelScale = new Vec4(1, 1, 1);

                    this.Text = $"3D Viewer | {System.IO.Path.GetFileName(ofd.FileName)}";

                    this.Focus();

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

            Bitmap bmp = new Bitmap(ClientSize.Width, ClientSize.Height);

            using (Graphics g = Graphics.FromImage(bmp))
            {
                g.Clear(Color.White);

            }
                if (_model != null)
                {
                    using(NewBitmap newBitmap = new NewBitmap(bmp))
                    {
                    Rasterizer rasterizer = new Rasterizer(newBitmap);
                        _linker.Render(_model, rasterizer);
                    }
                    
                }
                else
                {
                using (Graphics g = Graphics.FromImage(bmp))
                {
                    string msg = "Нажмите кнопку 'Загрузить .obj', чтобы открыть модель";
                    Font font = new Font("Arial", 14);
                    SizeF size = g.MeasureString(msg, font);
                    g.DrawString(msg, font, Brushes.Gray,
                        (ClientSize.Width - size.Width) / 2,
                        (ClientSize.Height - size.Height) / 2);
                }
                
            }
           

            e.Graphics.DrawImage(bmp, 0, 0);
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