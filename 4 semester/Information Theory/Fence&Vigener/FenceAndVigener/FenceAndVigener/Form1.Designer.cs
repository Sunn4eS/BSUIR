namespace FenceAndVigener;

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
        cipherButton = new System.Windows.Forms.Button();
        decipherButton = new System.Windows.Forms.Button();
        chooseTypeComboBox = new System.Windows.Forms.ComboBox();
        menuStrip1 = new System.Windows.Forms.MenuStrip();
        toolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
        openFileMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        saveFileMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        toolStripMenuItem2 = new System.Windows.Forms.ToolStripMenuItem();
        toolStripMenuItem3 = new System.Windows.Forms.ToolStripMenuItem();
        toolStripMenuItem5 = new System.Windows.Forms.ToolStripMenuItem();
        toolStripMenuItem6ToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
        keyTextbox = new System.Windows.Forms.TextBox();
        keyLabel = new System.Windows.Forms.Label();
        enterTextBox = new System.Windows.Forms.TextBox();
        enterLabel = new System.Windows.Forms.Label();
        outTextBox = new System.Windows.Forms.TextBox();
        outLabel = new System.Windows.Forms.Label();
        chooselabel = new System.Windows.Forms.Label();
        menuStrip1.SuspendLayout();
        SuspendLayout();
        // 
        // cipherButton
        // 
        cipherButton.Enabled = false;
        cipherButton.Location = new System.Drawing.Point(409, 98);
        cipherButton.Name = "cipherButton";
        cipherButton.Size = new System.Drawing.Size(157, 51);
        cipherButton.TabIndex = 0;
        cipherButton.Text = "Шифрование";
        cipherButton.UseVisualStyleBackColor = true;
        cipherButton.Click += cipherButton_Click;
        // 
        // decipherButton
        // 
        decipherButton.Enabled = false;
        decipherButton.Location = new System.Drawing.Point(572, 97);
        decipherButton.Name = "decipherButton";
        decipherButton.Size = new System.Drawing.Size(148, 51);
        decipherButton.TabIndex = 1;
        decipherButton.Text = "Дешифрование";
        decipherButton.UseVisualStyleBackColor = true;
        decipherButton.Click += decipherButton_Click;
        // 
        // chooseTypeComboBox
        // 
        chooseTypeComboBox.FormattingEnabled = true;
        chooseTypeComboBox.Items.AddRange(new object[] { "Железодорожная изгородь", "Шифр Виженера с прогрессивным ключом" });
        chooseTypeComboBox.Location = new System.Drawing.Point(23, 98);
        chooseTypeComboBox.Name = "chooseTypeComboBox";
        chooseTypeComboBox.Size = new System.Drawing.Size(374, 33);
        chooseTypeComboBox.TabIndex = 2;
        chooseTypeComboBox.SelectedIndexChanged += chooseTypeComboBox_SelectedIndexChanged;
        // 
        // menuStrip1
        // 
        menuStrip1.ImageScalingSize = new System.Drawing.Size(24, 24);
        menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] { toolStripMenuItem1 });
        menuStrip1.Location = new System.Drawing.Point(0, 0);
        menuStrip1.Name = "menuStrip1";
        menuStrip1.Size = new System.Drawing.Size(1093, 33);
        menuStrip1.TabIndex = 3;
        menuStrip1.Text = "menuStrip1";
        // 
        // toolStripMenuItem1
        // 
        toolStripMenuItem1.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] { openFileMenuItem, saveFileMenuItem });
        toolStripMenuItem1.Name = "toolStripMenuItem1";
        toolStripMenuItem1.Size = new System.Drawing.Size(69, 29);
        toolStripMenuItem1.Text = "Файл";
        // 
        // openFileMenuItem
        // 
        openFileMenuItem.Name = "openFileMenuItem";
        openFileMenuItem.Size = new System.Drawing.Size(200, 34);
        openFileMenuItem.Text = "Открыть";
        // 
        // saveFileMenuItem
        // 
        saveFileMenuItem.Name = "saveFileMenuItem";
        saveFileMenuItem.Size = new System.Drawing.Size(200, 34);
        saveFileMenuItem.Text = "Сохранить";
        // 
        // toolStripMenuItem2
        // 
        toolStripMenuItem2.Name = "toolStripMenuItem2";
        toolStripMenuItem2.Size = new System.Drawing.Size(32, 19);
        // 
        // toolStripMenuItem3
        // 
        toolStripMenuItem3.Name = "toolStripMenuItem3";
        toolStripMenuItem3.Size = new System.Drawing.Size(32, 19);
        // 
        // toolStripMenuItem5
        // 
        toolStripMenuItem5.Name = "toolStripMenuItem5";
        toolStripMenuItem5.Size = new System.Drawing.Size(32, 19);
        // 
        // toolStripMenuItem6ToolStripMenuItem
        // 
        toolStripMenuItem6ToolStripMenuItem.Name = "toolStripMenuItem6ToolStripMenuItem";
        toolStripMenuItem6ToolStripMenuItem.Size = new System.Drawing.Size(32, 19);
        toolStripMenuItem6ToolStripMenuItem.Text = "toolStripMenuItem6";
        // 
        // keyTextbox
        // 
        keyTextbox.Enabled = false;
        keyTextbox.Location = new System.Drawing.Point(27, 195);
        keyTextbox.Name = "keyTextbox";
        keyTextbox.Size = new System.Drawing.Size(370, 31);
        keyTextbox.TabIndex = 4;
        keyTextbox.TextChanged += keyTextbox_TextChanged;
        // 
        // keyLabel
        // 
        keyLabel.Font = new System.Drawing.Font("Segoe UI", 11F);
        keyLabel.Location = new System.Drawing.Point(32, 162);
        keyLabel.Name = "keyLabel";
        keyLabel.Size = new System.Drawing.Size(276, 30);
        keyLabel.TabIndex = 5;
        keyLabel.Text = "Ключ";
        // 
        // enterTextBox
        // 
        enterTextBox.Location = new System.Drawing.Point(27, 300);
        enterTextBox.Multiline = true;
        enterTextBox.Name = "enterTextBox";
        enterTextBox.Size = new System.Drawing.Size(370, 169);
        enterTextBox.TabIndex = 6;
        enterTextBox.TextChanged += enterTextBox_TextChanged;
        // 
        // enterLabel
        // 
        enterLabel.Font = new System.Drawing.Font("Segoe UI", 11F);
        enterLabel.Location = new System.Drawing.Point(32, 259);
        enterLabel.Name = "enterLabel";
        enterLabel.Size = new System.Drawing.Size(328, 38);
        enterLabel.TabIndex = 7;
        enterLabel.Text = "Исходный текст";
        // 
        // outTextBox
        // 
        outTextBox.Enabled = false;
        outTextBox.Location = new System.Drawing.Point(511, 297);
        outTextBox.Multiline = true;
        outTextBox.Name = "outTextBox";
        outTextBox.ReadOnly = true;
        outTextBox.Size = new System.Drawing.Size(367, 172);
        outTextBox.TabIndex = 8;
        // 
        // outLabel
        // 
        outLabel.Font = new System.Drawing.Font("Segoe UI", 11F);
        outLabel.Location = new System.Drawing.Point(511, 259);
        outLabel.Name = "outLabel";
        outLabel.Size = new System.Drawing.Size(328, 34);
        outLabel.TabIndex = 9;
        outLabel.Text = "Результат";
        // 
        // chooselabel
        // 
        chooselabel.Font = new System.Drawing.Font("Segoe UI", 11F);
        chooselabel.Location = new System.Drawing.Point(23, 57);
        chooselabel.Name = "chooselabel";
        chooselabel.Size = new System.Drawing.Size(328, 38);
        chooselabel.TabIndex = 10;
        chooselabel.Text = "Выберите метод шифрования:";
        // 
        // Form1
        // 
        AutoScaleDimensions = new System.Drawing.SizeF(10F, 25F);
        AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        ClientSize = new System.Drawing.Size(1093, 541);
        Controls.Add(chooselabel);
        Controls.Add(outLabel);
        Controls.Add(outTextBox);
        Controls.Add(enterLabel);
        Controls.Add(enterTextBox);
        Controls.Add(keyLabel);
        Controls.Add(keyTextbox);
        Controls.Add(chooseTypeComboBox);
        Controls.Add(decipherButton);
        Controls.Add(cipherButton);
        Controls.Add(menuStrip1);
        Text = "Лабораторная работа №1, Бражалович Александр. 351004";
        menuStrip1.ResumeLayout(false);
        menuStrip1.PerformLayout();
        ResumeLayout(false);
        PerformLayout();
    }

    private System.Windows.Forms.Label chooselabel;

    private System.Windows.Forms.Label outLabel;

    private System.Windows.Forms.TextBox outTextBox;

    private System.Windows.Forms.Label enterLabel;

    private System.Windows.Forms.TextBox keyTextbox;
    private System.Windows.Forms.Label keyLabel;
    private System.Windows.Forms.TextBox enterTextBox;

    private System.Windows.Forms.OpenFileDialog openFileDialog1;

    private System.Windows.Forms.ToolStripMenuItem saveFileMenuItem;
    private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem6ToolStripMenuItem;

    private System.Windows.Forms.ToolStripMenuItem openFileMenuItem;
    private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem5;

    private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem3;

    private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem2;

    private System.Windows.Forms.ToolStripMenuItem toolStripMenuItem1;

    private System.Windows.Forms.MenuStrip menuStrip1;

    private System.Windows.Forms.Button cipherButton;
    private System.Windows.Forms.Button decipherButton;
    private System.Windows.Forms.ComboBox chooseTypeComboBox;

    #endregion
}