namespace Lab3;

partial class Form1
{
    /// <summary>
    ///  Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    ///  Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }

        base.Dispose(disposing);
    }

    #region Windows Form Designer generated code

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
        p_leftBar = new System.Windows.Forms.Panel();
        tb_cumulativeErrorProbability = new System.Windows.Forms.TextBox();
        lb_cumulativeErrorProbability = new System.Windows.Forms.Label();
        tb_missingErrorProbability = new System.Windows.Forms.TextBox();
        lb_missingErrorProbability = new System.Windows.Forms.Label();
        tb_falseAlarmProbability = new System.Windows.Forms.TextBox();
        lb_falseAlarmProbability = new System.Windows.Forms.Label();
        btn_calculate = new System.Windows.Forms.Button();
        tb_secondProbability = new System.Windows.Forms.TextBox();
        l_secondProbability = new System.Windows.Forms.Label();
        tb_firstProbability = new System.Windows.Forms.TextBox();
        lb_firstProbability = new System.Windows.Forms.Label();
        p_canvas = new System.Windows.Forms.Panel();
        pb_canvas = new System.Windows.Forms.PictureBox();
        p_leftBar.SuspendLayout();
        p_canvas.SuspendLayout();
        ((System.ComponentModel.ISupportInitialize)pb_canvas).BeginInit();
        SuspendLayout();
        // 
        // p_leftBar
        // 
        p_leftBar.BackColor = System.Drawing.SystemColors.ControlDark;
        p_leftBar.Controls.Add(tb_cumulativeErrorProbability);
        p_leftBar.Controls.Add(lb_cumulativeErrorProbability);
        p_leftBar.Controls.Add(tb_missingErrorProbability);
        p_leftBar.Controls.Add(lb_missingErrorProbability);
        p_leftBar.Controls.Add(tb_falseAlarmProbability);
        p_leftBar.Controls.Add(lb_falseAlarmProbability);
        p_leftBar.Controls.Add(btn_calculate);
        p_leftBar.Controls.Add(tb_secondProbability);
        p_leftBar.Controls.Add(l_secondProbability);
        p_leftBar.Controls.Add(tb_firstProbability);
        p_leftBar.Controls.Add(lb_firstProbability);
        p_leftBar.Dock = System.Windows.Forms.DockStyle.Left;
        p_leftBar.Location = new System.Drawing.Point(0, 0);
        p_leftBar.Name = "p_leftBar";
        p_leftBar.Size = new System.Drawing.Size(164, 539);
        p_leftBar.TabIndex = 0;
        // 
        // tb_cumulativeErrorProbability
        // 
        tb_cumulativeErrorProbability.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        tb_cumulativeErrorProbability.Enabled = false;
        tb_cumulativeErrorProbability.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
        tb_cumulativeErrorProbability.Location = new System.Drawing.Point(0, 480);
        tb_cumulativeErrorProbability.Name = "tb_cumulativeErrorProbability";
        tb_cumulativeErrorProbability.ReadOnly = true;
        tb_cumulativeErrorProbability.Size = new System.Drawing.Size(164, 29);
        tb_cumulativeErrorProbability.TabIndex = 10;
        // 
        // lb_cumulativeErrorProbability
        // 
        lb_cumulativeErrorProbability.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        lb_cumulativeErrorProbability.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
        lb_cumulativeErrorProbability.Location = new System.Drawing.Point(0, 430);
        lb_cumulativeErrorProbability.Name = "lb_cumulativeErrorProbability";
        lb_cumulativeErrorProbability.Size = new System.Drawing.Size(164, 47);
        lb_cumulativeErrorProbability.TabIndex = 9;
        lb_cumulativeErrorProbability.Text = "Вероятность суммарной ошибки";
        lb_cumulativeErrorProbability.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        // 
        // tb_missingErrorProbability
        // 
        tb_missingErrorProbability.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        tb_missingErrorProbability.Enabled = false;
        tb_missingErrorProbability.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
        tb_missingErrorProbability.Location = new System.Drawing.Point(0, 398);
        tb_missingErrorProbability.Name = "tb_missingErrorProbability";
        tb_missingErrorProbability.ReadOnly = true;
        tb_missingErrorProbability.Size = new System.Drawing.Size(164, 29);
        tb_missingErrorProbability.TabIndex = 8;
        // 
        // lb_missingErrorProbability
        // 
        lb_missingErrorProbability.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        lb_missingErrorProbability.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
        lb_missingErrorProbability.Location = new System.Drawing.Point(0, 320);
        lb_missingErrorProbability.Name = "lb_missingErrorProbability";
        lb_missingErrorProbability.Size = new System.Drawing.Size(164, 75);
        lb_missingErrorProbability.TabIndex = 7;
        lb_missingErrorProbability.Text = "Вероятность пропуска обнаружения ошибки";
        lb_missingErrorProbability.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        // 
        // tb_falseAlarmProbability
        // 
        tb_falseAlarmProbability.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        tb_falseAlarmProbability.Enabled = false;
        tb_falseAlarmProbability.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
        tb_falseAlarmProbability.Location = new System.Drawing.Point(0, 288);
        tb_falseAlarmProbability.Name = "tb_falseAlarmProbability";
        tb_falseAlarmProbability.ReadOnly = true;
        tb_falseAlarmProbability.Size = new System.Drawing.Size(164, 29);
        tb_falseAlarmProbability.TabIndex = 6;
        // 
        // lb_falseAlarmProbability
        // 
        lb_falseAlarmProbability.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        lb_falseAlarmProbability.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
        lb_falseAlarmProbability.Location = new System.Drawing.Point(0, 238);
        lb_falseAlarmProbability.Name = "lb_falseAlarmProbability";
        lb_falseAlarmProbability.Size = new System.Drawing.Size(164, 47);
        lb_falseAlarmProbability.TabIndex = 5;
        lb_falseAlarmProbability.Text = "Вероятность ложной тревоги";
        lb_falseAlarmProbability.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        // 
        // btn_calculate
        // 
        btn_calculate.Enabled = false;
        btn_calculate.Location = new System.Drawing.Point(27, 143);
        btn_calculate.Name = "btn_calculate";
        btn_calculate.Size = new System.Drawing.Size(113, 32);
        btn_calculate.TabIndex = 4;
        btn_calculate.Text = "Посчитать";
        btn_calculate.UseVisualStyleBackColor = true;
        btn_calculate.Click += btn_calculate_Click;
        // 
        // tb_secondProbability
        // 
        tb_secondProbability.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        tb_secondProbability.Enabled = false;
        tb_secondProbability.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
        tb_secondProbability.Location = new System.Drawing.Point(0, 108);
        tb_secondProbability.Name = "tb_secondProbability";
        tb_secondProbability.ReadOnly = true;
        tb_secondProbability.Size = new System.Drawing.Size(164, 29);
        tb_secondProbability.TabIndex = 3;
        // 
        // l_secondProbability
        // 
        l_secondProbability.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        l_secondProbability.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
        l_secondProbability.Location = new System.Drawing.Point(0, 70);
        l_secondProbability.Name = "l_secondProbability";
        l_secondProbability.Size = new System.Drawing.Size(164, 35);
        l_secondProbability.TabIndex = 2;
        l_secondProbability.Text = "Вероятность 2 класса";
        l_secondProbability.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        // 
        // tb_firstProbability
        // 
        tb_firstProbability.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        tb_firstProbability.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
        tb_firstProbability.Location = new System.Drawing.Point(0, 38);
        tb_firstProbability.Name = "tb_firstProbability";
        tb_firstProbability.Size = new System.Drawing.Size(164, 29);
        tb_firstProbability.TabIndex = 1;
        tb_firstProbability.TextChanged += tb_firstProbability_TextChanged;
        tb_firstProbability.KeyPress += tb_firstProbability_KeyPress;
        // 
        // lb_firstProbability
        // 
        lb_firstProbability.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        lb_firstProbability.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
        lb_firstProbability.Location = new System.Drawing.Point(0, 0);
        lb_firstProbability.Name = "lb_firstProbability";
        lb_firstProbability.Size = new System.Drawing.Size(164, 35);
        lb_firstProbability.TabIndex = 0;
        lb_firstProbability.Text = "Вероятность 1 класса";
        lb_firstProbability.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        // 
        // p_canvas
        // 
        p_canvas.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right));
        p_canvas.Controls.Add(pb_canvas);
        p_canvas.Location = new System.Drawing.Point(164, 0);
        p_canvas.Name = "p_canvas";
        p_canvas.Size = new System.Drawing.Size(637, 539);
        p_canvas.TabIndex = 1;
        // 
        // pb_canvas
        // 
        pb_canvas.Dock = System.Windows.Forms.DockStyle.Fill;
        pb_canvas.Location = new System.Drawing.Point(0, 0);
        pb_canvas.Name = "pb_canvas";
        pb_canvas.Size = new System.Drawing.Size(637, 539);
        pb_canvas.TabIndex = 0;
        pb_canvas.TabStop = false;
        // 
        // Form1
        // 
        AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
        AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        ClientSize = new System.Drawing.Size(801, 539);
        Controls.Add(p_canvas);
        Controls.Add(p_leftBar);
        StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
        Text = "Form1";
        p_leftBar.ResumeLayout(false);
        p_leftBar.PerformLayout();
        p_canvas.ResumeLayout(false);
        ((System.ComponentModel.ISupportInitialize)pb_canvas).EndInit();
        ResumeLayout(false);
    }

    private System.Windows.Forms.PictureBox pb_canvas;

    private System.Windows.Forms.Panel p_canvas;

    private System.Windows.Forms.TextBox tb_missingErrorProbability;

    private System.Windows.Forms.Label lb_missingErrorProbability;

    private System.Windows.Forms.TextBox tb_cumulativeErrorProbability;
    private System.Windows.Forms.Label lb_cumulativeErrorProbability;

    private System.Windows.Forms.TextBox tb_falseAlarmProbability;

    private System.Windows.Forms.Label lb_falseAlarmProbability;

    private System.Windows.Forms.Button btn_calculate;

    private System.Windows.Forms.TextBox tb_secondProbability;
    private System.Windows.Forms.Label l_secondProbability;

    private System.Windows.Forms.TextBox tb_firstProbability;

    private System.Windows.Forms.Label lb_firstProbability;

    private System.Windows.Forms.Panel p_leftBar;

    #endregion
}