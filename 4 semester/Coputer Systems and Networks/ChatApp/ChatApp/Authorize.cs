using System.Net.NetworkInformation;

namespace ChatApp;

public partial class Authorize : Form
{
    public Authorize()
    {
        InitializeComponent();
    }

    private void ConnectButton_Click(object sender, EventArgs e)
    {
        NetworkInterface[] nics = NetworkInterface.GetAllNetworkInterfaces();
        foreach (var ni in nics)
        {
            if ((ni.NetworkInterfaceType == NetworkInterfaceType.Wireless80211 &&
                ni.OperationalStatus == OperationalStatus.Up) || (ni.NetworkInterfaceType == NetworkInterfaceType.Ethernet && ni.OperationalStatus == OperationalStatus.Up))
            {
                UnicastIPAddressInformationCollection ipInfo = ni.GetIPProperties().UnicastAddresses;
                foreach (UnicastIPAddressInformation ip in ipInfo)
                {
                    if (ip.Address.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
                    {
                        var chat = new Chat(ip.Address, NameTextBox.Text.Trim());
                        chat.Show();
                        this.Hide();
                        return;
                    }
                }
            }
        }
    }

    private void NameTextBox_TextChanged(object sender, EventArgs e)
    {
        ConnectButton.Enabled = NameTextBox.Text.Trim().Length > 0;
    }
}