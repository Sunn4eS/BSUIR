using System.Net;
using System;
using ChatApp.Backend;

namespace ChatApp;

public partial class Chat : Form
{
    private Client _client;
    
    public Chat(IPAddress address, string name)
    {
        InitializeComponent();
        InitializeClient(address, name);
        IpLabel.Text += address.ToString();
        NameLabel.Text += name;
        this.FormClosing += Chat_Closing;
    }

    private void InitializeClient(IPAddress ip, string name)
    {
        _client = new Client(ip, name, UpdateChatHistory);
        _client.NewNodeDetected += Client_NewNodeDetected;
        _client.NodeDisconnected += Client_NodeDisconnected;
        _client.Start();
    }
    
    private void UpdateChatHistory(string message)
    {
        if (OutTextBox.InvokeRequired)
        {
            OutTextBox.Invoke(new Action<string>(UpdateChatHistory), message);
            return;
        }
        OutTextBox.AppendText($"{message}{Environment.NewLine}");
    }
    
    private void Client_NewNodeDetected(string name, IPAddress ip)
    {
        ClientListBox.Invoke((MethodInvoker)delegate
        {
            ClientListBox.Items.Add($"{name} ({ip})");
        });
    }

    private void Client_NodeDisconnected(string name, IPAddress ip)
    {
        ClientListBox.Invoke((MethodInvoker)delegate
        {
            for (int i = 0; i < ClientListBox.Items.Count; i++)
            {
                if (ClientListBox.Items[i].ToString().Contains(ip.ToString()))
                {
                    ClientListBox.Items.RemoveAt(i);
                    break;
                }
            }
        });
    }

    private void Chat_Closing(object sender, FormClosingEventArgs e)
    {
        _client.Stop();
    }

    private void SendButton_Click(object sender, EventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(InputTextBox.Text))
        {
            _client.SendMessageToAll(InputTextBox.Text);
            InputTextBox.Clear();
        }
    }

    private void InputTextBox_TextChanged(object sender, EventArgs e)
    {
        SendButton.Enabled = InputTextBox.Text.Trim().Length > 0;
    }
    
}