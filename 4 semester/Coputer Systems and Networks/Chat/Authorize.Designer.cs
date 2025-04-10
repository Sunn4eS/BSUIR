namespace LocalChat
{
    partial class AuthorizeForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

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
            NameLabel = new System.Windows.Forms.Label();
            NameTextBox = new System.Windows.Forms.TextBox();
            ConnectButton = new System.Windows.Forms.Button();
            SuspendLayout();
            // 
            // NameLabel
            // 
            NameLabel.AutoSize = true;
            NameLabel.Font = new System.Drawing.Font("Segoe UI", 13.8F);
            NameLabel.ForeColor = System.Drawing.SystemColors.ActiveCaptionText;
            NameLabel.Location = new System.Drawing.Point(26, 28);
            NameLabel.Name = "NameLabel";
            NameLabel.Size = new System.Drawing.Size(155, 38);
            NameLabel.TabIndex = 2;
            NameLabel.Text = "Your name:";
            // 
            // NameTextBox
            // 
            NameTextBox.Font = new System.Drawing.Font("Segoe UI", 13.8F);
            NameTextBox.Location = new System.Drawing.Point(187, 28);
            NameTextBox.MaxLength = 12;
            NameTextBox.Name = "NameTextBox";
            NameTextBox.PlaceholderText = "Name";
            NameTextBox.Size = new System.Drawing.Size(226, 44);
            NameTextBox.TabIndex = 3;
            NameTextBox.TextChanged += NameTextBox_TextChanged;
            NameTextBox.KeyPress += NameTextBox_KeyPress;
            // 
            // ConnectButton
            // 
            ConnectButton.Enabled = false;
            ConnectButton.Font = new System.Drawing.Font("Segoe UI", 13.8F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)204));
            ConnectButton.ForeColor = System.Drawing.Color.Black;
            ConnectButton.Location = new System.Drawing.Point(244, 91);
            ConnectButton.Name = "ConnectButton";
            ConnectButton.Size = new System.Drawing.Size(169, 54);
            ConnectButton.TabIndex = 4;
            ConnectButton.Text = "Connect";
            ConnectButton.UseVisualStyleBackColor = true;
            ConnectButton.Click += ConnectButton_Click;
            // 
            // AuthorizeForm
            // 
            AutoScaleDimensions = new System.Drawing.SizeF(10F, 25F);
            AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            BackColor = System.Drawing.Color.SeaShell;
            ClientSize = new System.Drawing.Size(451, 157);
            Controls.Add(ConnectButton);
            Controls.Add(NameTextBox);
            Controls.Add(NameLabel);
            Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            MaximizeBox = false;
            MaximumSize = new System.Drawing.Size(473, 213);
            MinimumSize = new System.Drawing.Size(473, 213);
            StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            Text = "Authorize";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion
        private System.Windows.Forms.Label NameLabel;
        private System.Windows.Forms.TextBox NameTextBox;
        private System.Windows.Forms.Button ConnectButton;
    }
}