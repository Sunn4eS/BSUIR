namespace MSiSvIT
{
    partial class MainForm
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.codeTextBox = new System.Windows.Forms.RichTextBox();
            this.splitContainer2 = new System.Windows.Forms.SplitContainer();
            this.operatorsDataGridView = new System.Windows.Forms.DataGridView();
            this.Operator = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.CountOperator = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.panel1 = new System.Windows.Forms.Panel();
            this.metricsPanel = new System.Windows.Forms.Panel();
            this.maxNestingLevelLabel = new System.Windows.Forms.Label();
            this.relativeComplexityLabel = new System.Windows.Forms.Label();
            this.clLabel = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.buttonsPanel = new System.Windows.Forms.Panel();
            this.calculateButton = new System.Windows.Forms.Button();
            this.loadButton = new System.Windows.Forms.Button();
            this.openFileDialog = new System.Windows.Forms.OpenFileDialog();
            this.toolTip = new System.Windows.Forms.ToolTip(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).BeginInit();
            this.splitContainer2.Panel1.SuspendLayout();
            this.splitContainer2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.operatorsDataGridView)).BeginInit();
            this.panel1.SuspendLayout();
            this.metricsPanel.SuspendLayout();
            this.buttonsPanel.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.codeTextBox);
            this.splitContainer1.Panel1MinSize = 300;
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.splitContainer2);
            this.splitContainer1.Panel2MinSize = 200;
            this.splitContainer1.Size = new System.Drawing.Size(1476, 1171);
            this.splitContainer1.SplitterDistance = 531;
            this.splitContainer1.SplitterWidth = 6;
            this.splitContainer1.TabIndex = 0;
            // 
            // codeTextBox
            // 
            this.codeTextBox.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(242)))), ((int)(((byte)(230)))));
            this.codeTextBox.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.codeTextBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.codeTextBox.Font = new System.Drawing.Font("Consolas", 10F);
            this.codeTextBox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(193)))), ((int)(((byte)(93)))), ((int)(((byte)(0)))));
            this.codeTextBox.Location = new System.Drawing.Point(0, 0);
            this.codeTextBox.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.codeTextBox.Name = "codeTextBox";
            this.codeTextBox.Size = new System.Drawing.Size(1476, 531);
            this.codeTextBox.TabIndex = 0;
            this.codeTextBox.Text = "";
            // 
            // splitContainer2
            // 
            this.splitContainer2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer2.Location = new System.Drawing.Point(0, 0);
            this.splitContainer2.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.splitContainer2.Name = "splitContainer2";
            // 
            // splitContainer2.Panel1
            // 
            this.splitContainer2.Panel1.Controls.Add(this.operatorsDataGridView);
            this.splitContainer2.Panel1MinSize = 200;
            this.splitContainer2.Panel2MinSize = 200;
            this.splitContainer2.Size = new System.Drawing.Size(1476, 634);
            this.splitContainer2.SplitterDistance = 738;
            this.splitContainer2.SplitterWidth = 6;
            this.splitContainer2.TabIndex = 0;
            // 
            // operatorsDataGridView
            // 
            this.operatorsDataGridView.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(242)))), ((int)(((byte)(230)))));
            this.operatorsDataGridView.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(200)))), ((int)(((byte)(150)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(193)))), ((int)(((byte)(93)))), ((int)(((byte)(0)))));
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(170)))), ((int)(((byte)(100)))));
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.Color.Black;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.operatorsDataGridView.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.operatorsDataGridView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.operatorsDataGridView.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Operator,
            this.CountOperator});
            this.operatorsDataGridView.Dock = System.Windows.Forms.DockStyle.Fill;
            this.operatorsDataGridView.EnableHeadersVisualStyles = false;
            this.operatorsDataGridView.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(200)))), ((int)(((byte)(150)))));
            this.operatorsDataGridView.Location = new System.Drawing.Point(0, 0);
            this.operatorsDataGridView.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.operatorsDataGridView.Name = "operatorsDataGridView";
            this.operatorsDataGridView.RowHeadersWidth = 62;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(242)))), ((int)(((byte)(230)))));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(193)))), ((int)(((byte)(93)))), ((int)(((byte)(0)))));
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(200)))), ((int)(((byte)(150)))));
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.Black;
            this.operatorsDataGridView.RowsDefaultCellStyle = dataGridViewCellStyle2;
            this.operatorsDataGridView.Size = new System.Drawing.Size(738, 634);
            this.operatorsDataGridView.TabIndex = 0;
            // 
            // Operator
            // 
            this.Operator.HeaderText = "Оператор";
            this.Operator.MinimumWidth = 8;
            this.Operator.Name = "Operator";
            this.Operator.Width = 300;
            // 
            // CountOperator
            // 
            this.CountOperator.HeaderText = "Количество";
            this.CountOperator.MinimumWidth = 8;
            this.CountOperator.Name = "CountOperator";
            this.CountOperator.Width = 150;
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(200)))), ((int)(((byte)(150)))));
            this.panel1.Controls.Add(this.metricsPanel);
            this.panel1.Controls.Add(this.buttonsPanel);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.panel1.Location = new System.Drawing.Point(0, 1017);
            this.panel1.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(1476, 154);
            this.panel1.TabIndex = 1;
            // 
            // metricsPanel
            // 
            this.metricsPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(230)))), ((int)(((byte)(200)))));
            this.metricsPanel.Controls.Add(this.maxNestingLevelLabel);
            this.metricsPanel.Controls.Add(this.relativeComplexityLabel);
            this.metricsPanel.Controls.Add(this.clLabel);
            this.metricsPanel.Controls.Add(this.label3);
            this.metricsPanel.Controls.Add(this.label2);
            this.metricsPanel.Controls.Add(this.label1);
            this.metricsPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.metricsPanel.Location = new System.Drawing.Point(300, 0);
            this.metricsPanel.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.metricsPanel.Name = "metricsPanel";
            this.metricsPanel.Padding = new System.Windows.Forms.Padding(15, 15, 15, 15);
            this.metricsPanel.Size = new System.Drawing.Size(1176, 154);
            this.metricsPanel.TabIndex = 1;
            // 
            // maxNestingLevelLabel
            // 
            this.maxNestingLevelLabel.AutoSize = true;
            this.maxNestingLevelLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.maxNestingLevelLabel.Location = new System.Drawing.Point(945, 25);
            this.maxNestingLevelLabel.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.maxNestingLevelLabel.Name = "maxNestingLevelLabel";
            this.maxNestingLevelLabel.Size = new System.Drawing.Size(24, 25);
            this.maxNestingLevelLabel.TabIndex = 5;
            this.maxNestingLevelLabel.Text = "0";
            // 
            // relativeComplexityLabel
            // 
            this.relativeComplexityLabel.AutoSize = true;
            this.relativeComplexityLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.relativeComplexityLabel.Location = new System.Drawing.Point(555, 25);
            this.relativeComplexityLabel.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.relativeComplexityLabel.Name = "relativeComplexityLabel";
            this.relativeComplexityLabel.Size = new System.Drawing.Size(24, 25);
            this.relativeComplexityLabel.TabIndex = 4;
            this.relativeComplexityLabel.Text = "0";
            // 
            // clLabel
            // 
            this.clLabel.AutoSize = true;
            this.clLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.clLabel.Location = new System.Drawing.Point(255, 25);
            this.clLabel.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.clLabel.Name = "clLabel";
            this.clLabel.Size = new System.Drawing.Size(24, 25);
            this.clLabel.TabIndex = 3;
            this.clLabel.Text = "0";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.label3.Location = new System.Drawing.Point(705, 25);
            this.label3.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(197, 25);
            this.label3.TabIndex = 2;
            this.label3.Text = "Макс. влож. MaxNL:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.label2.Location = new System.Drawing.Point(345, 25);
            this.label2.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(206, 25);
            this.label2.TabIndex = 1;
            this.label2.Text = "Относ. сложность c:";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.label1.Location = new System.Drawing.Point(15, 25);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(197, 25);
            this.label1.TabIndex = 0;
            this.label1.Text = "Абс. сложность CL:";
            // 
            // buttonsPanel
            // 
            this.buttonsPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(230)))), ((int)(((byte)(200)))));
            this.buttonsPanel.Controls.Add(this.calculateButton);
            this.buttonsPanel.Controls.Add(this.loadButton);
            this.buttonsPanel.Dock = System.Windows.Forms.DockStyle.Left;
            this.buttonsPanel.Location = new System.Drawing.Point(0, 0);
            this.buttonsPanel.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.buttonsPanel.Name = "buttonsPanel";
            this.buttonsPanel.Padding = new System.Windows.Forms.Padding(15, 15, 15, 15);
            this.buttonsPanel.Size = new System.Drawing.Size(300, 154);
            this.buttonsPanel.TabIndex = 0;
            // 
            // calculateButton
            // 
            this.calculateButton.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(170)))), ((int)(((byte)(100)))));
            this.calculateButton.Dock = System.Windows.Forms.DockStyle.Top;
            this.calculateButton.FlatAppearance.BorderSize = 0;
            this.calculateButton.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.calculateButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.calculateButton.Location = new System.Drawing.Point(15, 77);
            this.calculateButton.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.calculateButton.Name = "calculateButton";
            this.calculateButton.Size = new System.Drawing.Size(270, 62);
            this.calculateButton.TabIndex = 1;
            this.calculateButton.Text = "Рассчитать метрики";
            this.calculateButton.UseVisualStyleBackColor = false;
            // 
            // loadButton
            // 
            this.loadButton.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(170)))), ((int)(((byte)(100)))));
            this.loadButton.Dock = System.Windows.Forms.DockStyle.Top;
            this.loadButton.FlatAppearance.BorderSize = 0;
            this.loadButton.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.loadButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.loadButton.Location = new System.Drawing.Point(15, 15);
            this.loadButton.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.loadButton.Name = "loadButton";
            this.loadButton.Size = new System.Drawing.Size(270, 62);
            this.loadButton.TabIndex = 0;
            this.loadButton.Text = "Загрузить код";
            this.loadButton.UseVisualStyleBackColor = false;
            // 
            // openFileDialog
            // 
            this.openFileDialog.FileName = "openFileDialog1";
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(230)))), ((int)(((byte)(200)))));
            this.ClientSize = new System.Drawing.Size(1476, 1171);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.splitContainer1);
            this.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.MinimumSize = new System.Drawing.Size(1489, 1201);
            this.Name = "MainForm";
            this.Text = "Анализатор кода Ruby (Метрики Джилба)";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.splitContainer2.Panel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).EndInit();
            this.splitContainer2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.operatorsDataGridView)).EndInit();
            this.panel1.ResumeLayout(false);
            this.metricsPanel.ResumeLayout(false);
            this.metricsPanel.PerformLayout();
            this.buttonsPanel.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.RichTextBox codeTextBox;
        private System.Windows.Forms.SplitContainer splitContainer2;
        private System.Windows.Forms.DataGridView operatorsDataGridView;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Panel buttonsPanel;
        private System.Windows.Forms.Button calculateButton;
        private System.Windows.Forms.Button loadButton;
        private System.Windows.Forms.Panel metricsPanel;
        private System.Windows.Forms.Label maxNestingLevelLabel;
        private System.Windows.Forms.Label relativeComplexityLabel;
        private System.Windows.Forms.Label clLabel;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.OpenFileDialog openFileDialog;
        private System.Windows.Forms.DataGridViewTextBoxColumn Operator;
        private System.Windows.Forms.DataGridViewTextBoxColumn CountOperator;
        private System.Windows.Forms.ToolTip toolTip;
    }
}