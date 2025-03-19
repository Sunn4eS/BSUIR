namespace MusicShop
{
    partial class Form1
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.contextMenuStrip = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.инструментыToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.гитарыToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.electricToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.classicToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.acousticToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.аксессуарыToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.медиаторыToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.ремниToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.addButton = new System.Windows.Forms.Button();
            this.itemsflowLayoutPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.contextMenuStrip.SuspendLayout();
            this.SuspendLayout();
            // 
            // contextMenuStrip
            // 
            this.contextMenuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] { this.инструментыToolStripMenuItem, this.аксессуарыToolStripMenuItem });
            this.contextMenuStrip.Name = "contextMenuStrip";
            this.contextMenuStrip.Size = new System.Drawing.Size(179, 64);
            // 
            // инструментыToolStripMenuItem
            // 
            this.инструментыToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] { this.гитарыToolStripMenuItem });
            this.инструментыToolStripMenuItem.Name = "инструментыToolStripMenuItem";
            this.инструментыToolStripMenuItem.Size = new System.Drawing.Size(178, 30);
            this.инструментыToolStripMenuItem.Text = "Instruments";
            // 
            // гитарыToolStripMenuItem
            // 
            this.гитарыToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] { this.electricToolStripMenuItem, this.classicToolStripMenuItem, this.acousticToolStripMenuItem });
            this.гитарыToolStripMenuItem.Name = "гитарыToolStripMenuItem";
            this.гитарыToolStripMenuItem.Size = new System.Drawing.Size(139, 30);
            this.гитарыToolStripMenuItem.Text = "Guitars";
            // 
            // electricToolStripMenuItem
            // 
            this.electricToolStripMenuItem.Name = "electricToolStripMenuItem";
            this.electricToolStripMenuItem.Size = new System.Drawing.Size(151, 30);
            this.electricToolStripMenuItem.Text = "Electic";
            // 
            // classicToolStripMenuItem
            // 
            this.classicToolStripMenuItem.Name = "classicToolStripMenuItem";
            this.classicToolStripMenuItem.Size = new System.Drawing.Size(151, 30);
            this.classicToolStripMenuItem.Text = "Classic";
            // 
            // acousticToolStripMenuItem
            // 
            this.acousticToolStripMenuItem.Name = "acousticToolStripMenuItem";
            this.acousticToolStripMenuItem.Size = new System.Drawing.Size(151, 30);
            this.acousticToolStripMenuItem.Text = "Acoustic";
            this.acousticToolStripMenuItem.Click += new System.EventHandler(this.acousticToolStripMenuItem_Click);
            // 
            // аксессуарыToolStripMenuItem
            // 
            this.аксессуарыToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] { this.медиаторыToolStripMenuItem, this.ремниToolStripMenuItem });
            this.аксессуарыToolStripMenuItem.Name = "аксессуарыToolStripMenuItem";
            this.аксессуарыToolStripMenuItem.Size = new System.Drawing.Size(178, 30);
            this.аксессуарыToolStripMenuItem.Text = "Accessories";
            // 
            // медиаторыToolStripMenuItem
            // 
            this.медиаторыToolStripMenuItem.Name = "медиаторыToolStripMenuItem";
            this.медиаторыToolStripMenuItem.Size = new System.Drawing.Size(180, 30);
            this.медиаторыToolStripMenuItem.Text = "Медиаторы";
            // 
            // ремниToolStripMenuItem
            // 
            this.ремниToolStripMenuItem.Name = "ремниToolStripMenuItem";
            this.ремниToolStripMenuItem.Size = new System.Drawing.Size(180, 30);
            this.ремниToolStripMenuItem.Text = "Ремни";
            // 
            // addButton
            // 
            this.addButton.Location = new System.Drawing.Point(1160, 314);
            this.addButton.Name = "addButton";
            this.addButton.Size = new System.Drawing.Size(35, 48);
            this.addButton.TabIndex = 1;
            this.addButton.Text = "add new item";
            this.addButton.UseVisualStyleBackColor = true;
            this.addButton.Visible = false;
            this.addButton.Click += new System.EventHandler(this.addButton_Click);
            // 
            // itemsflowLayoutPanel
            // 
            this.itemsflowLayoutPanel.Location = new System.Drawing.Point(12, 653);
            this.itemsflowLayoutPanel.Name = "itemsflowLayoutPanel";
            this.itemsflowLayoutPanel.Size = new System.Drawing.Size(1104, 308);
            this.itemsflowLayoutPanel.TabIndex = 2;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1194, 760);
            this.Controls.Add(this.itemsflowLayoutPanel);
            this.Controls.Add(this.addButton);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximumSize = new System.Drawing.Size(1200, 800);
            this.MinimumSize = new System.Drawing.Size(1200, 800);
            this.Name = "Form1";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "MusicShop";
            this.contextMenuStrip.ResumeLayout(false);
            this.ResumeLayout(false);
        }

        private System.Windows.Forms.FlowLayoutPanel itemsflowLayoutPanel;

        private System.Windows.Forms.Button addButton;

        private System.Windows.Forms.ContextMenuStrip contextMenuStrip;
        private System.Windows.Forms.ToolStripMenuItem инструментыToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem аксессуарыToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem медиаторыToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem ремниToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem гитарыToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem electricToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem classicToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem acousticToolStripMenuItem;

        #endregion
    }
}