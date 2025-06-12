using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace OpenKey
{
    public partial class fMain: Form
    {
        private Checker _checker;
        private ElGamal _encryptor;
        private Model _model;
        private int _p;
        public fMain()
        {
            InitializeComponent();
            _checker = new Checker();
            _encryptor = new ElGamal();
            _model = new Model();
        }

        private void ClearAll() 
        {
            cbG.DataSource = new List<int> ();
            tbX.Clear();
            cbK.Text = "";
            cbK.DataSource = new List<int>();

            cbG.Enabled = false;
            tbX.Enabled = false;    
            cbK.Enabled = false;

            lYValue.Text = "";
            lEilerValue.Text = "";

            btnEncryption.Enabled = false;
            btnDecryption.Enabled = false; 
        }

        private void PrepareAll(int p) 
        {
            cbG.Enabled = true;
            cbG.DataSource = _encryptor.GetPrimitiveRoots(p);

            tbX.Enabled = true;
            tbX.Clear();

            cbK.Enabled = true;
            cbK.DataSource = _encryptor.GetListK(p);
            cbK.Text = "";

            btnDecryption.Enabled = true;
            btnEncryption.Enabled = true;
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnAcceptP_Click(object sender, EventArgs e)
        {
            string pStr = tbP.Text;
            if (_checker.IsValidP(pStr))
            {
                _p = int.Parse(pStr);
                lEilerValue.Text = $"{_p - 1}";
                PrepareAll(_p);
            }
            else 
            { 
                ClearAll();
            }
        }

        private void btnEncryption_Click(object sender, EventArgs e)
        {
            if (_checker.IsValidSelectedG(cbG.SelectedIndex) &&
                _checker.IsValidX(tbX.Text, _p) &&
                _checker.IsValidK(cbK.Text, _p) &&
                _checker.IsValidSourceData(_model.SourceDataBytes))
            {
                int x = int.Parse(tbX.Text);
                int k = int.Parse(cbK.Text);
                int g = (int)cbG.SelectedItem;

                _encryptor.InitializeElGamal(_p, g, x, k);
                lYValue.Text = $"{_encryptor.Y}";

                _model.ResultDataBytes = _encryptor.StartEncryption(_model.SourceDataBytes);
                if (_model.ResultDataBytes == null) 
                {
                    MessageBox.Show("В файле имеются символы, имеющие код больший или равный P! Это может привести к неоднозначному расшифрованию!", 
                        "Error",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error
                        );
                }

                ViewUpdate(true);
            }
        }

        private void btnDecryption_Click(object sender, EventArgs e)
        {
            if (_checker.IsValidSelectedG(cbG.SelectedIndex) &&
                _checker.IsValidX(tbX.Text, _p) &&
                _checker.IsValidK(cbK.Text, _p) &&
                _checker.IsValidSourceData(_model.SourceDataBytes))
            {
                int x = int.Parse(tbX.Text);
                int k = int.Parse(cbK.Text);
                int g = (int)cbG.SelectedItem;

                _encryptor.InitializeElGamal(_p, g, x, k);
                lYValue.Text = $"{_encryptor.Y}";

                _model.ResultDataBytes = _encryptor.StartDecryption(_model.SourceDataBytes);

                ViewUpdate(false);
            }
        }

        private void ViewUpdate(bool isEncryption) 
        {
                tbOpenedFile.Text = isEncryption ? ConvertToDecimalNumbers(_model.SourceDataBytes) : ConvertToDecimalNumbersPairs(_model.SourceDataBytes);
                tbResult.Text = isEncryption ? ConvertToDecimalNumbersPairs(_model.ResultDataBytes) : ConvertToDecimalNumbers(_model.ResultDataBytes);
        }

        private string ConvertToDecimalNumbers(byte[] data) 
        {
            if (data == null || data.Length == 0)
            {
                return string.Empty;
            }

            return string.Join(" ", data.Select(value => value.ToString()));
        }

        private string ConvertToDecimalNumbersPairs(byte[] data)
        {
            if (data == null || data.Length == 0)
            {
                return string.Empty;
            }

            var pairs = new List<string>();
            for (int i = 0; i < data.Length / 8; i ++)
            {
                int a = BitConverter.ToInt32(data, 2*i * 4);
                int b = BitConverter.ToInt32(data, (2 * i + 1) * 4);

                if (i + 1 < data.Length)
                {
                    pairs.Add($"({a}, {b})");
                }
                else
                {
                    // Если остался один байт без пары, добавляем его как (X, 0)
                    pairs.Add($"({a}, 0)");
                }
            }

            return string.Join(" ", pairs);
        }

        private void btnOpenSourceFile_Click(object sender, EventArgs e)
        {
            if (openFileDialog.ShowDialog() == DialogResult.OK) 
            {
                try
                {
                    byte[] fileContent = File.ReadAllBytes(openFileDialog.FileName);
                    _model.SourceDataBytes = fileContent;
                    _model.ResultDataBytes = null;
                    ViewUpdate(true);
                }
                catch
                {
                    MessageBox.Show("Не удалось открыть файл!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }        
        private void btnOpenEncryptedFile_Click(object sender, EventArgs e)
        {
            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    byte[] fileContent = File.ReadAllBytes(openFileDialog.FileName);
                    _model.SourceDataBytes = fileContent;
                    _model.ResultDataBytes = null;
                    ViewUpdate(false);
                }
                catch
                {
                    MessageBox.Show("Не удалось открыть файл!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void btnSaveFile_Click(object sender, EventArgs e)
        {
            if (saveFileDialog.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    if (_model.ResultDataBytes != null)
                    {
                        File.WriteAllBytes(saveFileDialog.FileName, _model.ResultDataBytes);
                    }
                    else
                    {
                        MessageBox.Show("Отсутствует результат работы программы!", "Сохранение", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
                catch
                {
                    MessageBox.Show("Не удалось сохранить файл!", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }


    }
}
