namespace ChatApp;

partial class Chat
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
        SendButton = new System.Windows.Forms.Button();
        OutTextBox = new System.Windows.Forms.TextBox();
        InputTextBox = new System.Windows.Forms.TextBox();
        InfoPanel = new System.Windows.Forms.Panel();
        flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
        ClientListBox = new System.Windows.Forms.ListBox();
        IpLabel = new System.Windows.Forms.Label();
        NameLabel = new System.Windows.Forms.Label();
        InfoPanel.SuspendLayout();
        flowLayoutPanel1.SuspendLayout();
        SuspendLayout();
        // 
        // SendButton
        // 
        SendButton.Location = new System.Drawing.Point(595, 726);
        SendButton.Name = "SendButton";
        SendButton.Size = new System.Drawing.Size(107, 57);
        SendButton.TabIndex = 0;
        SendButton.Text = "Send";
        SendButton.UseVisualStyleBackColor = true;
        SendButton.Click += SendButton_Click;
        // 
        // OutTextBox
        // 
        OutTextBox.Font = new System.Drawing.Font("Segoe UI", 12F);
        OutTextBox.Location = new System.Drawing.Point(205, 26);
        OutTextBox.Multiline = true;
        OutTextBox.Name = "OutTextBox";
        OutTextBox.Size = new System.Drawing.Size(497, 694);
        OutTextBox.TabIndex = 1;
        // 
        // InputTextBox
        // 
        InputTextBox.Font = new System.Drawing.Font("Segoe UI", 12F);
        InputTextBox.Location = new System.Drawing.Point(205, 739);
        InputTextBox.Name = "InputTextBox";
        InputTextBox.Size = new System.Drawing.Size(370, 39);
        InputTextBox.TabIndex = 2;
        InputTextBox.TextChanged += InputTextBox_TextChanged;
        // 
        // InfoPanel
        // 
        InfoPanel.Controls.Add(flowLayoutPanel1);
        InfoPanel.Controls.Add(IpLabel);
        InfoPanel.Controls.Add(NameLabel);
        InfoPanel.Location = new System.Drawing.Point(-1, 26);
        InfoPanel.Name = "InfoPanel";
        InfoPanel.Size = new System.Drawing.Size(200, 694);
        InfoPanel.TabIndex = 3;
        // 
        // flowLayoutPanel1
        // 
        flowLayoutPanel1.Controls.Add(ClientListBox);
        flowLayoutPanel1.Location = new System.Drawing.Point(7, 96);
        flowLayoutPanel1.Name = "flowLayoutPanel1";
        flowLayoutPanel1.Size = new System.Drawing.Size(192, 595);
        flowLayoutPanel1.TabIndex = 2;
        // 
        // ClientListBox
        // 
        ClientListBox.FormattingEnabled = true;
        ClientListBox.ItemHeight = 25;
        ClientListBox.Location = new System.Drawing.Point(3, 3);
        ClientListBox.Name = "ClientListBox";
        ClientListBox.Size = new System.Drawing.Size(181, 554);
        ClientListBox.TabIndex = 0;
        // 
        // IpLabel
        // 
        IpLabel.Location = new System.Drawing.Point(11, 53);
        IpLabel.Name = "IpLabel";
        IpLabel.Size = new System.Drawing.Size(180, 31);
        IpLabel.TabIndex = 1;
        IpLabel.Text = "Ip:";
        // 
        // NameLabel
        // 
        NameLabel.Location = new System.Drawing.Point(3, 9);
        NameLabel.Name = "NameLabel";
        NameLabel.Size = new System.Drawing.Size(188, 34);
        NameLabel.TabIndex = 0;
        NameLabel.Text = "Name:";
        // 
        // Chat
        // 
        AutoScaleDimensions = new System.Drawing.SizeF(10F, 25F);
        AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        ClientSize = new System.Drawing.Size(714, 795);
        Controls.Add(InfoPanel);
        Controls.Add(InputTextBox);
        Controls.Add(OutTextBox);
        Controls.Add(SendButton);
        Text = "MyChat";
        InfoPanel.ResumeLayout(false);
        flowLayoutPanel1.ResumeLayout(false);
        ResumeLayout(false);
        PerformLayout();
    }

    private System.Windows.Forms.ListBox ClientListBox;

    private System.Windows.Forms.Label IpLabel;
    private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;

    private System.Windows.Forms.Panel InfoPanel;
    private System.Windows.Forms.Label NameLabel;

    private System.Windows.Forms.TextBox OutTextBox;

    private System.Windows.Forms.TextBox InputTextBox;

    private System.Windows.Forms.Button SendButton;

    #endregion
}