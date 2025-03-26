namespace maximin;
partial class Form1
{
    private System.ComponentModel.IContainer components = null;

   
    private System.Windows.Forms.TrackBar trackBar1;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.Button button1;

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
        button1 = new System.Windows.Forms.Button();
        pictureBox1 = new System.Windows.Forms.PictureBox();
        countOfDotsLabel = new System.Windows.Forms.Label();
        label1 = new System.Windows.Forms.Label();
        trackBar1 = new System.Windows.Forms.TrackBar();
        ((System.ComponentModel.ISupportInitialize)pictureBox1).BeginInit();
        ((System.ComponentModel.ISupportInitialize)trackBar1).BeginInit();
        SuspendLayout();
        // 
        // button1
        // 
        button1.Location = new System.Drawing.Point(959, 124);
        button1.Name = "button1";
        button1.Size = new System.Drawing.Size(197, 46);
        button1.TabIndex = 9;
        button1.Text = "Начать";
        button1.UseVisualStyleBackColor = true;
        button1.Click += Button1_Click;
        // 
        // pictureBox1
        // 
        pictureBox1.Location = new System.Drawing.Point(12, 12);
        pictureBox1.Name = "pictureBox1";
        pictureBox1.Size = new System.Drawing.Size(917, 772);
        pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
        pictureBox1.TabIndex = 6;
        pictureBox1.TabStop = false;
        // 
        // countOfDotsLabel
        // 
        countOfDotsLabel.AutoSize = true;
        countOfDotsLabel.CausesValidation = false;
        countOfDotsLabel.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
        countOfDotsLabel.Location = new System.Drawing.Point(1140, 59);
        countOfDotsLabel.Name = "countOfDotsLabel";
        countOfDotsLabel.Size = new System.Drawing.Size(0, 25);
        countOfDotsLabel.TabIndex = 13;
        // 
        // label1
        // 
        label1.Location = new System.Drawing.Point(959, 21);
        label1.Name = "label1";
        label1.Size = new System.Drawing.Size(158, 35);
        label1.TabIndex = 10;
        label1.Text = "Количество точек";
        // 
        // trackBar1
        // 
        trackBar1.Location = new System.Drawing.Point(959, 59);
        trackBar1.Name = "trackBar1";
        trackBar1.Size = new System.Drawing.Size(177, 69);
        trackBar1.TabIndex = 7;
        trackBar1.Scroll += TrackBar_Scroll;
        // 
        // Form1
        // 
        BackColor = System.Drawing.SystemColors.Control;
        ClientSize = new System.Drawing.Size(1288, 803);
        Controls.Add(countOfDotsLabel);
        Controls.Add(pictureBox1);
        Controls.Add(trackBar1);
        Controls.Add(label1);
        Controls.Add(button1);
        FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
        Location = new System.Drawing.Point(22, 22);
        Text = "Maximin Clustering";
        ((System.ComponentModel.ISupportInitialize)pictureBox1).EndInit();
        ((System.ComponentModel.ISupportInitialize)trackBar1).EndInit();
        ResumeLayout(false);
        PerformLayout();
    }

    private System.Windows.Forms.Label countOfDotsLabel;

    private System.Windows.Forms.PictureBox pictureBox1;
}