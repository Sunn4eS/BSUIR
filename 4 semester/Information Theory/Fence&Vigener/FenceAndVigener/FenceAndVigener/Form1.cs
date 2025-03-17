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
        }
        else
        {
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
        }
        else
        {
            outTextBox.Text = Fence.Decipher(enterTextBox.Text, keyTextbox.Text);
        }
    }

    private void keyTextbox_TextChanged(object sender, EventArgs e)
    {
        if ((keyTextbox.Text != "") && (chooseTypeComboBox.SelectedIndex == 1) && (enterTextBox.Text != ""))
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
}