using LocalChat.BackEnd;
using System.Net;

namespace LocalChat
{
    public partial class ChatForm : Form
    {
        private readonly Client client;

        public ChatForm(IPAddress address, string name)
        {
            InitializeComponent();

            AddressLabel.Text += address.ToString();
            NameLabel.Text += name;

            client = new Client(address, name, text =>
            {
                if (OutputTextBox.InvokeRequired)
                {
                    OutputTextBox.Invoke(new Action(() => OutputTextBox.AppendText(text + Environment.NewLine)));
                }
                else
                {
                    OutputTextBox.AppendText(text + Environment.NewLine);
                }
            });
            client.Connect();
        }

        private bool CanSend()
        {
            return InputTextBox.Text.Trim().Length > 0;
        }

        private void InputTextBox_TextChanged(object sender, EventArgs e)
        {
            SendButton.Enabled = CanSend();
        }

        private void InputTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if ((!e.Shift && !e.Control) && e.KeyCode == Keys.Enter)
            {
                if (SendButton.Enabled)
                {
                    SendButton_Click(sender, e);
                }
                e.SuppressKeyPress = true;
            }
        }

        private void SendButton_Click(object sender, EventArgs e)
        {
            _ = client.SendMessageAsync(InputTextBox.Text.Trim());
            InputTextBox.Text = "";
            InputTextBox.Focus();
        }

        private void Chat_FormClosing(object sender, FormClosingEventArgs e)
        {
            _ = client.DisconnectAsync();
            Application.Exit();
        }

        private void OnlineTimer_Tick(object sender, EventArgs e)
        {
            ParticipantsFlowLayoutPanel.Controls.Clear();
            ParticipantsFlowLayoutPanel.Controls.Add(ParticipantsLabel);
            (IPAddress Address, string Name)[] participants = client.GetParticipants();
            foreach (var participant in participants)
            {
                var participantLabel = new Label();

                participantLabel.AutoSize = true;
                participantLabel.Font = new Font("Segoe UI", 12.8F, 0, GraphicsUnit.Point, 204);
                participantLabel.Text = $"{participant.Address.ToString()}, {participant.Name}";

                ParticipantsFlowLayoutPanel.Controls.Add(participantLabel);
            }
        }
    }
}