namespace LocalChat
{
    partial class ChatForm
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
            components = new System.ComponentModel.Container();
            sidePanel = new System.Windows.Forms.Panel();
            ParticipantsFlowLayoutPanel = new System.Windows.Forms.FlowLayoutPanel();
            ParticipantsLabel = new System.Windows.Forms.Label();
            ClientPanel = new System.Windows.Forms.Panel();
            NameLabel = new System.Windows.Forms.Label();
            AddressLabel = new System.Windows.Forms.Label();
            messagePanel = new System.Windows.Forms.Panel();
            SendButton = new System.Windows.Forms.Button();
            InputTextBox = new System.Windows.Forms.TextBox();
            OutputTextBox = new System.Windows.Forms.TextBox();
            onlineTimer = new System.Windows.Forms.Timer(components);
            sidePanel.SuspendLayout();
            ParticipantsFlowLayoutPanel.SuspendLayout();
            ClientPanel.SuspendLayout();
            messagePanel.SuspendLayout();
            SuspendLayout();
            // 
            // sidePanel
            // 
            sidePanel.Controls.Add(ParticipantsFlowLayoutPanel);
            sidePanel.Controls.Add(ClientPanel);
            sidePanel.Dock = System.Windows.Forms.DockStyle.Left;
            sidePanel.ForeColor = System.Drawing.SystemColors.ButtonHighlight;
            sidePanel.Location = new System.Drawing.Point(0, 0);
            sidePanel.Name = "sidePanel";
            sidePanel.Size = new System.Drawing.Size(303, 548);
            sidePanel.TabIndex = 0;
            // 
            // ParticipantsFlowLayoutPanel
            // 
            ParticipantsFlowLayoutPanel.BackColor = System.Drawing.Color.SeaShell;
            ParticipantsFlowLayoutPanel.Controls.Add(ParticipantsLabel);
            ParticipantsFlowLayoutPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            ParticipantsFlowLayoutPanel.FlowDirection = System.Windows.Forms.FlowDirection.TopDown;
            ParticipantsFlowLayoutPanel.Location = new System.Drawing.Point(0, 85);
            ParticipantsFlowLayoutPanel.Name = "ParticipantsFlowLayoutPanel";
            ParticipantsFlowLayoutPanel.Size = new System.Drawing.Size(303, 463);
            ParticipantsFlowLayoutPanel.TabIndex = 1;
            // 
            // ParticipantsLabel
            // 
            ParticipantsLabel.AutoSize = true;
            ParticipantsLabel.Font = new System.Drawing.Font("Segoe UI", 13.8F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)204));
            ParticipantsLabel.ForeColor = System.Drawing.SystemColors.ActiveCaptionText;
            ParticipantsLabel.Location = new System.Drawing.Point(3, 0);
            ParticipantsLabel.Name = "ParticipantsLabel";
            ParticipantsLabel.Size = new System.Drawing.Size(111, 38);
            ParticipantsLabel.TabIndex = 0;
            ParticipantsLabel.Text = "Online:";
            // 
            // ClientPanel
            // 
            ClientPanel.BackColor = System.Drawing.Color.White;
            ClientPanel.Controls.Add(NameLabel);
            ClientPanel.Controls.Add(AddressLabel);
            ClientPanel.Dock = System.Windows.Forms.DockStyle.Top;
            ClientPanel.Location = new System.Drawing.Point(0, 0);
            ClientPanel.Name = "ClientPanel";
            ClientPanel.Size = new System.Drawing.Size(303, 85);
            ClientPanel.TabIndex = 0;
            // 
            // NameLabel
            // 
            NameLabel.AutoSize = true;
            NameLabel.Font = new System.Drawing.Font("Segoe UI", 13.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
            NameLabel.ForeColor = System.Drawing.SystemColors.ActiveCaptionText;
            NameLabel.Location = new System.Drawing.Point(12, 45);
            NameLabel.Name = "NameLabel";
            NameLabel.Size = new System.Drawing.Size(163, 38);
            NameLabel.TabIndex = 1;
            NameLabel.Text = "Your name: ";
            // 
            // AddressLabel
            // 
            AddressLabel.AutoSize = true;
            AddressLabel.Font = new System.Drawing.Font("Segoe UI", 13.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
            AddressLabel.ForeColor = System.Drawing.SystemColors.ActiveCaptionText;
            AddressLabel.Location = new System.Drawing.Point(12, 9);
            AddressLabel.Name = "AddressLabel";
            AddressLabel.Size = new System.Drawing.Size(117, 38);
            AddressLabel.TabIndex = 0;
            AddressLabel.Text = "Your IP: ";
            // 
            // messagePanel
            // 
            messagePanel.BackColor = System.Drawing.Color.FromArgb(((int)((byte)255)), ((int)((byte)224)), ((int)((byte)192)));
            messagePanel.Controls.Add(SendButton);
            messagePanel.Controls.Add(InputTextBox);
            messagePanel.Controls.Add(OutputTextBox);
            messagePanel.Dock = System.Windows.Forms.DockStyle.Fill;
            messagePanel.Location = new System.Drawing.Point(303, 0);
            messagePanel.Name = "messagePanel";
            messagePanel.Size = new System.Drawing.Size(822, 548);
            messagePanel.TabIndex = 1;
            // 
            // SendButton
            // 
            SendButton.Enabled = false;
            SendButton.Font = new System.Drawing.Font("Segoe UI", 13.8F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)204));
            SendButton.Location = new System.Drawing.Point(694, 471);
            SendButton.Name = "SendButton";
            SendButton.Size = new System.Drawing.Size(120, 74);
            SendButton.TabIndex = 1;
            SendButton.Text = "Send →";
            SendButton.UseVisualStyleBackColor = true;
            SendButton.Click += SendButton_Click;
            // 
            // InputTextBox
            // 
            InputTextBox.BackColor = System.Drawing.Color.SeaShell;
            InputTextBox.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
            InputTextBox.ForeColor = System.Drawing.SystemColors.ControlText;
            InputTextBox.Location = new System.Drawing.Point(6, 471);
            InputTextBox.MaxLength = 1000;
            InputTextBox.Multiline = true;
            InputTextBox.Name = "InputTextBox";
            InputTextBox.PlaceholderText = "Write a message...";
            InputTextBox.Size = new System.Drawing.Size(682, 74);
            InputTextBox.TabIndex = 0;
            InputTextBox.TextChanged += InputTextBox_TextChanged;
            InputTextBox.KeyDown += InputTextBox_KeyDown;
            // 
            // OutputTextBox
            // 
            OutputTextBox.BackColor = System.Drawing.Color.Linen;
            OutputTextBox.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)204));
            OutputTextBox.ForeColor = System.Drawing.SystemColors.ControlText;
            OutputTextBox.Location = new System.Drawing.Point(6, 9);
            OutputTextBox.Multiline = true;
            OutputTextBox.Name = "OutputTextBox";
            OutputTextBox.ReadOnly = true;
            OutputTextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            OutputTextBox.Size = new System.Drawing.Size(808, 453);
            OutputTextBox.TabIndex = 2;
            OutputTextBox.TabStop = false;
            // 
            // onlineTimer
            // 
            onlineTimer.Enabled = true;
            onlineTimer.Interval = 500;
            onlineTimer.Tick += OnlineTimer_Tick;
            // 
            // ChatForm
            // 
            AutoScaleDimensions = new System.Drawing.SizeF(10F, 25F);
            AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            BackColor = System.Drawing.Color.FromArgb(((int)((byte)255)), ((int)((byte)192)), ((int)((byte)255)));
            ClientSize = new System.Drawing.Size(1125, 548);
            Controls.Add(messagePanel);
            Controls.Add(sidePanel);
            DoubleBuffered = true;
            Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            MaximizeBox = false;
            MaximumSize = new System.Drawing.Size(1147, 604);
            MinimumSize = new System.Drawing.Size(1147, 604);
            StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            Text = "Chat";
            FormClosing += Chat_FormClosing;
            sidePanel.ResumeLayout(false);
            ParticipantsFlowLayoutPanel.ResumeLayout(false);
            ParticipantsFlowLayoutPanel.PerformLayout();
            ClientPanel.ResumeLayout(false);
            ClientPanel.PerformLayout();
            messagePanel.ResumeLayout(false);
            messagePanel.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private Panel sidePanel;
        private System.Windows.Forms.Panel ClientPanel;
        private System.Windows.Forms.Label AddressLabel;
        private System.Windows.Forms.Label NameLabel;
        private System.Windows.Forms.FlowLayoutPanel ParticipantsFlowLayoutPanel;
        private System.Windows.Forms.Label ParticipantsLabel;
        private System.Windows.Forms.Panel messagePanel;
        private Button SendButton;
        private System.Windows.Forms.TextBox InputTextBox;
        private System.Windows.Forms.TextBox OutputTextBox;
        private System.Windows.Forms.Timer onlineTimer;
    }
}
