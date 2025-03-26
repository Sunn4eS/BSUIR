using System.Net;

namespace ChatApp;

public partial class Chat : Form
{
    public Chat(IPAddress address, string name)
    {
        InitializeComponent();
        IpLabel.Text += address.ToString();
        NameLabel.Text += name;
    }

    private void SendButton_Click(object sender, EventArgs e)
    {
        throw new System.NotImplementedException();
    }

    private void InputTextBox_TextChanged(object sender, EventArgs e)
    {
        SendButton.Enabled = InputTextBox.Text.Trim().Length > 0;
    }
}