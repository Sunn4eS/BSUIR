using lab1_obj_parser;
using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace Lab1_3D
{
    public partial class MainForm : Form
    {
        private Model _model;
        private LinkerForRender _linker;
        private CameraControl _controller;

        public MainForm()
        {
            this.DoubleBuffered = true;
            this.Width = 1024; this.Height = 768;
            this.Text = "3D Viewer | SSR & MTL Auto-load";

            _linker = new LinkerForRender(ClientSize.Width, ClientSize.Height);
            _controller = new CameraControl(_linker, () => this.Invalidate());

            Button btnLoad = new Button() { Text = "Load OBJ", Location = new Point(10, 10), Size = new Size(120, 30) };
            Button btnDiff = new Button() { Text = "Diffuse Map", Location = new Point(10, 50), Size = new Size(120, 30) };
            Button btnNorm = new Button() { Text = "Normal Map", Location = new Point(10, 90), Size = new Size(120, 30) };
            Button btnSpec = new Button() { Text = "Specular Map", Location = new Point(10, 130), Size = new Size(120, 30) };

            CheckBox chkSSR = new CheckBox() { Text = "Enable SSR", Location = new Point(10, 170), Checked = true, BackColor = Color.Transparent, ForeColor = Color.White };

            btnLoad.Click += (s, e) => LoadModel();
            btnDiff.Click += (s, e) => LoadTexture(out _linker.DiffuseMap);
            btnNorm.Click += (s, e) => LoadTexture(out _linker.NormalMap);
            btnSpec.Click += (s, e) => LoadTexture(out _linker.SpecularMap);
            chkSSR.CheckedChanged += (s, e) => { _linker.EnableSSR = chkSSR.Checked; this.Invalidate(); };

            this.Controls.Add(btnLoad);
            this.Controls.Add(btnDiff);
            this.Controls.Add(btnNorm);
            this.Controls.Add(btnSpec);
            this.Controls.Add(chkSSR);

            this.MouseDown += (s, e) => _controller.OnMouseDown(e);
            this.MouseUp += (s, e) => _controller.OnMouseUp(e);
            this.MouseMove += (s, e) => _controller.OnMouseMove(e);
            this.MouseWheel += (s, e) => _controller.OnMouseWheel(e);
            this.Resize += (s, e) => { _linker.Width = ClientSize.Width; _linker.Height = ClientSize.Height; this.Invalidate(); };
        }

        private void LoadModel()
        {
            OpenFileDialog ofd = new OpenFileDialog { Filter = "OBJ files|*.obj" };
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                _model = new Model(ofd.FileName);
                _linker.ModelScale = new Vec4(1, 1, 1);

                // Автоматическая загрузка текстур из MTL
                if (!string.IsNullOrEmpty(_model.DiffuseMapPath) && File.Exists(_model.DiffuseMapPath))
                    _linker.DiffuseMap = Texture.LoadFromFile(_model.DiffuseMapPath);
                else _linker.DiffuseMap = null;

                if (!string.IsNullOrEmpty(_model.NormalMapPath) && File.Exists(_model.NormalMapPath))
                    _linker.NormalMap = Texture.LoadFromFile(_model.NormalMapPath);
                else _linker.NormalMap = null;

                if (!string.IsNullOrEmpty(_model.SpecularMapPath) && File.Exists(_model.SpecularMapPath))
                    _linker.SpecularMap = Texture.LoadFromFile(_model.SpecularMapPath);
                else _linker.SpecularMap = null;

                this.Focus(); this.Invalidate();
            }
        }

        private void LoadTexture(out Texture tex)
        {
            tex = null;
            OpenFileDialog ofd = new OpenFileDialog { Filter = "Images|*.jpg;*.png;*.bmp;*.tga" };
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                tex = Texture.LoadFromFile(ofd.FileName);
                this.Focus(); this.Invalidate();
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            Bitmap bmp = new Bitmap(ClientSize.Width, ClientSize.Height);
            using (Graphics g = Graphics.FromImage(bmp)) g.Clear(Color.FromArgb(40, 40, 40)); // Темный фон для лучшей видимости отражений

            if (_model != null)
            {
                using (NewBitmap newBitmap = new NewBitmap(bmp))
                {
                    Rasterizer rasterizer = new Rasterizer(newBitmap);
                    _linker.Render(_model, rasterizer);
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