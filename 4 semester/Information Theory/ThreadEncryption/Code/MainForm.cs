using ThreadEncryption.BackEnd;
using System;
using System.IO;
using System.Text;
using System.Windows.Forms;

namespace ThreadEncryption
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
        }


        private void registerStatusTextBox_TextChanged(object sender, EventArgs e)
        {
            int length = 0;
            for (int i = 0; i < registerStatusTextBox.Text.Length; i++)
            {
                if (registerStatusTextBox.Text[i] == '0' || registerStatusTextBox.Text[i] == '1') {
                    length++;
                }
            }
            registerLengthTextBox.Text = length.ToString();

            encryptButton.Enabled = CanEncrypt();
        }

        private void openToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                byte[] bytes = File.ReadAllBytes(openFileDialog.FileName);

                Encryption.plainText = new byte[bytes.Length * 8];
                for (int i = 0; i < bytes.Length; i++)
                {
                    for (int j = 0; j < 8; j++)
                    {
                        Encryption.plainText[i * 8 + j] = (byte)((bytes[i] >> j) & 0x1);
                    }
                }

                ShowPlainText(Encryption.plainText);

                generatedKeyTextBox.Clear();
                cipherTextTextBox.Clear();

                encryptButton.Enabled = CanEncrypt();
            }
        }

        private void ShowPlainText(byte[] bits)
        {
            plainTextTextBox.Text = bits.Length > 30 * 8 ? "Первые 15 байт: " + BackEnd.Convert.BitsToString(bits, 0, 15 * 8) + Environment.NewLine + "Последние 15 байт: " + BackEnd.Convert.BitsToString(bits, bits.Length - 15 * 8, 15 * 8) :
                                                           BackEnd.Convert.BitsToString(bits, 0, bits.Length);
        }

        private bool CanEncrypt()
        {
            return registerLengthTextBox.Text == Key.polynomial[0].ToString() && plainTextTextBox.Text.Length > 0;
        }


        private void encryptButton_Click(object sender, EventArgs e)
        {
            byte[] keyBytes = new byte[Key.polynomial[0]];
            StringBuilder key = new StringBuilder();
            int i = 0;
            for (int j = 0; j < registerStatusTextBox.Text.Length; j++)
            {
                if (registerStatusTextBox.Text[j] == '0' || registerStatusTextBox.Text[j] == '1')
                {
                    keyBytes[i] = (byte)(registerStatusTextBox.Text[j] - '0');
                    i++;
                    key.Append(registerStatusTextBox.Text[j]);
                }
            }
            registerStatusTextBox.Text = key.ToString();

            byte[] generatedKeyBytes = Key.Generate(keyBytes, Encryption.plainText.Length);
            ShowGeneratedKey(generatedKeyBytes);

            Encryption.Encrypt(generatedKeyBytes);
            ShowCipherText(Encryption.cipherText);
        }

        private void ShowGeneratedKey(byte[] bits)
        {
            generatedKeyTextBox.Text = bits.Length > 30 * 8 ? "Первые 15 байт: " + BackEnd.Convert.BitsToString(bits, 0, 15 * 8) + Environment.NewLine + "Последние 15 байт: " + BackEnd.Convert.BitsToString(bits, bits.Length - 15 * 8, 15 * 8) :
                                                              BackEnd.Convert.BitsToString(bits, 0, bits.Length);
        }

        private void ShowCipherText(byte[] bits)
        {
            cipherTextTextBox.Text = bits.Length > 30 * 8 ? "Первые 15 байт: " + BackEnd.Convert.BitsToString(bits, 0, 15 * 8) + Environment.NewLine + "Последние 15 байт: " + BackEnd.Convert.BitsToString(bits, bits.Length - 15 * 8, 15 * 8) :
                                                            BackEnd.Convert.BitsToString(bits, 0, bits.Length);
        }


        private void saveToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (saveFileDialog.ShowDialog() == DialogResult.OK)
            {
                byte[] result = new byte[Encryption.cipherText.Length / 8];
                for (int i = 0; i < result.Length; i++)
                {
                    byte oneByte = 0;
                    for (int j = 0; j < 8; j++)
                    {
                        oneByte |= (byte)(Encryption.cipherText[i * 8 + j] << j);
                    }
                    result[i] = oneByte;
                }
                using (FileStream fileStream = new FileStream(saveFileDialog.FileName, FileMode.Create))
                {
                    fileStream.Write(result, 0, result.Length);
                }
            }
        }
    }
}
