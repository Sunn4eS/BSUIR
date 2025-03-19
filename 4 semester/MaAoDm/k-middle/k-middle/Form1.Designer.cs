namespace k_middle;
partial class Form1
{
    private System.ComponentModel.IContainer components = null;

   
    private TrackBar trackBar1;
    private TrackBar trackBar2;
    private Label label1;
    private Label label2;
    private Button button1;

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
        trackBar1 = new System.Windows.Forms.TrackBar();
        trackBar2 = new System.Windows.Forms.TrackBar();
        label1 = new System.Windows.Forms.Label();
        label2 = new System.Windows.Forms.Label();
        button1 = new System.Windows.Forms.Button();
        pictureBox1 = new System.Windows.Forms.PictureBox();
        ((System.ComponentModel.ISupportInitialize)pictureBox1).BeginInit();
        ((System.ComponentModel.ISupportInitialize)trackBar1).BeginInit();
        ((System.ComponentModel.ISupportInitialize)trackBar2).BeginInit();
        SuspendLayout();
        trackBar1.Location = new System.Drawing.Point(10, 10);
        trackBar1.Name = "trackBar1";
        trackBar1.Size = new System.Drawing.Size(200, 69);
        trackBar1.TabIndex = 1;
        trackBar2.Location = new System.Drawing.Point(10, 60);
        trackBar2.Name = "trackBar2";
        trackBar2.Size = new System.Drawing.Size(200, 69);
        trackBar2.TabIndex = 2;
        label1.Location = new System.Drawing.Point(220, 10);
        label1.Name = "label1";
        label1.Size = new System.Drawing.Size(100, 23);
        label1.TabIndex = 3;
        label1.Text = "Points: 1000";
        label2.Location = new System.Drawing.Point(220, 60);
        label2.Name = "label2";
        label2.Size = new System.Drawing.Size(100, 23);
        label2.TabIndex = 4;
        label2.Text = "Clusters: 2";
        button1.Location = new System.Drawing.Point(10, 110);
        button1.Name = "button1";
        button1.Size = new System.Drawing.Size(200, 30);
        button1.TabIndex = 5;
        button1.Text = "Start";
        button1.Click += Button1_Click;
        pictureBox1.Location = new System.Drawing.Point(73, 85);
        pictureBox1.Name = "pictureBox1";
        pictureBox1.Size = new System.Drawing.Size(342, 415);
        pictureBox1.TabIndex = 6;
        pictureBox1.TabStop = false;
        trackBar1.Location = new System.Drawing.Point(641, 105);
        trackBar1.Name = "trackBar1";
        trackBar1.Size = new System.Drawing.Size(115, 69);
        trackBar1.TabIndex = 7;
        trackBar2.Location = new System.Drawing.Point(641, 225);
        trackBar2.Name = "trackBar2";
        trackBar2.Size = new System.Drawing.Size(115, 69);
        trackBar2.TabIndex = 8;
        button1.Location = new System.Drawing.Point(639, 441);
        button1.Name = "button1";
        button1.Size = new System.Drawing.Size(135, 46);
        button1.TabIndex = 9;
        button1.Text = "button1";
        button1.UseVisualStyleBackColor = true;
        label1.Location = new System.Drawing.Point(621, 43);
        label1.Name = "label1";
        label1.Size = new System.Drawing.Size(116, 35);
        label1.TabIndex = 10;
        label1.Text = "label1";
        label2.Location = new System.Drawing.Point(646, 197);
        label2.Name = "label2";
        label2.Size = new System.Drawing.Size(127, 28);
        label2.TabIndex = 11;
        label2.Text = "label2";
        ClientSize = new System.Drawing.Size(778, 544);
        Controls.Add(label2);
        Controls.Add(label1);
        Controls.Add(button1);
        Controls.Add(trackBar2);
        Controls.Add(trackBar1);
        Controls.Add(pictureBox1);
        
        Controls.Add(trackBar1);
        Controls.Add(trackBar2);
        Controls.Add(label1);
        Controls.Add(label2);
        Controls.Add(button1);
        Text = "K-Means Clustering";
        ((System.ComponentModel.ISupportInitialize)trackBar1).EndInit();
        ((System.ComponentModel.ISupportInitialize)trackBar2).EndInit();
        ((System.ComponentModel.ISupportInitialize)pictureBox1).EndInit();
        ((System.ComponentModel.ISupportInitialize)trackBar1).EndInit();
        ((System.ComponentModel.ISupportInitialize)trackBar2).EndInit();
        ResumeLayout(false);
        PerformLayout();
    }

    private System.Windows.Forms.PictureBox pictureBox1;
}