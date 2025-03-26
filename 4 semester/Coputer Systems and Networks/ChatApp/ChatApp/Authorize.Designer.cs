using System.ComponentModel;

namespace ChatApp;

partial class Authorize
{
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private IContainer components = null;

    /// <summary>
    /// Clean up any resources being used.
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
        NameTextBox = new System.Windows.Forms.TextBox();
        ConnectButton = new System.Windows.Forms.Button();
        EnterLabel = new System.Windows.Forms.Label();
        SuspendLayout();
        // 
        // NameTextBox
        // 
        NameTextBox.Font = new System.Drawing.Font("Segoe UI", 14F);
        NameTextBox.Location = new System.Drawing.Point(267, 24);
        NameTextBox.Name = "NameTextBox";
        NameTextBox.Size = new System.Drawing.Size(331, 45);
        NameTextBox.TabIndex = 0;
        NameTextBox.TextChanged += NameTextBox_TextChanged;
        // 
        // ConnectButton
        // 
        ConnectButton.Font = new System.Drawing.Font("Segoe UI", 14F);
        ConnectButton.Location = new System.Drawing.Point(406, 99);
        ConnectButton.Name = "ConnectButton";
        ConnectButton.Size = new System.Drawing.Size(192, 54);
        ConnectButton.TabIndex = 1;
        ConnectButton.Text = "Confirm";
        ConnectButton.UseVisualStyleBackColor = true;
        ConnectButton.Click += ConnectButton_Click;
        // 
        // EnterLabel
        // 
        EnterLabel.Font = new System.Drawing.Font("Segoe UI", 14F);
        EnterLabel.Location = new System.Drawing.Point(30, 22);
        EnterLabel.Name = "EnterLabel";
        EnterLabel.Size = new System.Drawing.Size(231, 47);
        EnterLabel.TabIndex = 2;
        EnterLabel.Text = "Enter your name:";
        // 
        // Authorize
        // 
        AutoScaleDimensions = new System.Drawing.SizeF(10F, 25F);
        AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        ClientSize = new System.Drawing.Size(625, 180);
        Controls.Add(EnterLabel);
        Controls.Add(ConnectButton);
        Controls.Add(NameTextBox);
        Text = "Authorize";
        ResumeLayout(false);
        PerformLayout();
    }

    private System.Windows.Forms.Label EnterLabel;

    private System.Windows.Forms.TextBox NameTextBox;
    private System.Windows.Forms.Button ConnectButton;

    #endregion
}