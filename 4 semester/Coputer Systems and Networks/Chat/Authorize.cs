
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;

namespace LocalChat
{
    public partial class AuthorizeForm : Form
    {
        public AuthorizeForm()
        {
            InitializeComponent();
        }

        private bool CanConnect()
        {
            return NameTextBox.Text.Trim().Length > 0;
        }

        private void NameTextBox_TextChanged(object sender, EventArgs e)
        {
            ConnectButton.Enabled = CanConnect();
        }

        private void NameTextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == Convert.ToChar(Keys.Return) && ConnectButton.Enabled)
            {
                ConnectButton_Click(sender, e);
            }
        }

        private void ConnectButton_Click(object sender, EventArgs e)
        {
            NetworkInterface[] networkInterfaces = NetworkInterface.GetAllNetworkInterfaces();

            foreach (NetworkInterface ni in networkInterfaces)
            {
                if (ni.OperationalStatus == OperationalStatus.Up && 
                       (ni.NetworkInterfaceType == NetworkInterfaceType.Wireless80211))
                {
                    UnicastIPAddressInformationCollection ipInfo = ni.GetIPProperties().UnicastAddresses;
                    foreach (UnicastIPAddressInformation ip in ipInfo)
                    {
                        if (ip.Address.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
                        {
                            var chat = new ChatForm(ip.Address, NameTextBox.Text.Trim());
                            chat.Show();
                            this.Hide();
                            return;
                        }
                    }
                }
            }
        }
    }
}