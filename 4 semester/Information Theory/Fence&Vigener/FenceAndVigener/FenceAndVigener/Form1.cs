using System.Security;
using FenceAndVigener.Classes;

namespace FenceAndVigener;

public partial class Form1 : Form
{
    public Form1()
    {
        InitializeComponent();
    }


  

    private void cipherButton_Click(object sender, EventArgs e)
    {
        outTextBox.Enabled = true;
        if (chooseTypeComboBox.SelectedIndex == 1)
        {
            outTextBox.Text = ProgressiveVigener.Encrypt(enterTextBox.Text, keyTextbox.Text);
            keyTextbox.Text = ProgressiveVigener.FilterRussianLetters(keyTextbox.Text);
        }
        else
        {
            keyTextbox.Text = Fence.GetKey(keyTextbox.Text).ToString();
            outTextBox.Text = Fence.Encipher(enterTextBox.Text, keyTextbox.Text);
        }

    }

    private void enterTextBox_TextChanged(object sender, EventArgs e)
    {
        if (((enterTextBox.Text != "") && chooseTypeComboBox.SelectedIndex == 1 && keyTextbox.Text != "") || (enterTextBox.Text != "" && chooseTypeComboBox.SelectedIndex == 0))
        {
            cipherButton.Enabled = true;
            decipherButton.Enabled = true;
        }
        else
        {
            cipherButton.Enabled = false;
            decipherButton.Enabled = false;
        }
        
    }

    private void decipherButton_Click(object sender, EventArgs e)
    {
        outTextBox.Enabled = true;
        if (chooseTypeComboBox.SelectedIndex == 1)
        {
            outTextBox.Text = ProgressiveVigener.Decrypt(enterTextBox.Text, keyTextbox.Text);
            keyTextbox.Text = ProgressiveVigener.FilterRussianLetters(keyTextbox.Text);
        }
        else
        {
            keyTextbox.Text = Fence.GetKey(keyTextbox.Text).ToString();
            outTextBox.Text = Fence.Decipher(enterTextBox.Text, keyTextbox.Text);
        }
    }

    private void keyTextbox_TextChanged(object sender, EventArgs e)
    {
        if ((keyTextbox.Text != "") && (enterTextBox.Text != ""))
        {
            cipherButton.Enabled = true;
            decipherButton.Enabled = true;
        }
        else
        {
            cipherButton.Enabled = false;
            decipherButton.Enabled = false;
        }
    }

    private void chooseTypeComboBox_SelectedIndexChanged(object sender, EventArgs e)
    {
        keyTextbox.Enabled = true;
    }

    private void openFileMenuItem_Click(object sender, EventArgs e)
    {
        if (openFileDialog1.ShowDialog() == DialogResult.OK)
        {
            StreamReader sr = new StreamReader(openFileDialog1.FileName);
            enterTextBox.Text = sr.ReadToEnd();
            sr.Close();
            cipherButton.Enabled = true;
            decipherButton.Enabled = true;
        }
    }

    private void saveFileMenuItem_Click(object sender, EventArgs e)
    {
        if (saveFileDialog1.ShowDialog() == DialogResult.OK)
        {
            StreamWriter sr = new StreamWriter(saveFileDialog1.FileName);
            sr.Write(outTextBox.Text);
            sr.Close();
        }
    }

    private void outTextBox_TextChanged(object sender, EventArgs e)
    {
        saveFileMenuItem.Enabled = outTextBox.MaxLength != 0;
    }
}