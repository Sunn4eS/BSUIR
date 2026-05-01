using lab1_obj_parser;
using System;
using System.Drawing;
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
            this.Text = "3D Viewer | Lab 4";

            _linker = new LinkerForRender(ClientSize.Width, ClientSize.Height);
            _controller = new CameraControl(_linker, () => this.Invalidate());

            Button btnLoad = new Button() { Text = "Load OBJ", Location = new Point(10, 10), Size = new Size(120, 30) };
            Button btnDiff = new Button() { Text = "Diffuse Map", Location = new Point(10, 50), Size = new Size(120, 30) };
            Button btnNorm = new Button() { Text = "Normal Map", Location = new Point(10, 90), Size = new Size(120, 30) };
            Button btnSpec = new Button() { Text = "Specular Map", Location = new Point(10, 130), Size = new Size(120, 30) };

            btnLoad.Click += (s, e) => LoadModel();
            btnDiff.Click += (s, e) => LoadTexture(out _linker.DiffuseMap);
            btnNorm.Click += (s, e) => LoadTexture(out _linker.NormalMap);
            btnSpec.Click += (s, e) => LoadTexture(out _linker.SpecularMap);

            this.Controls.Add(btnLoad);
            this.Controls.Add(btnDiff);
            this.Controls.Add(btnNorm);
            this.Controls.Add(btnSpec);

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
            using (Graphics g = Graphics.FromImage(bmp)) g.Clear(Color.Gray);

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