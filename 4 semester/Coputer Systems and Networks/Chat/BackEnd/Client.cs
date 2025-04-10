using System.Collections.Concurrent;
using System.Net;
using System.Net.Sockets;
using System.Text;

namespace LocalChat.BackEnd
{
    internal class Client
    {
        public delegate void Writer(string text);

        private const int UdpPort = 3000;
        private const int TcpPort = 3001;

        private readonly IPAddress _address;
        private readonly string _name;

        private readonly Socket _udpClient;
        private readonly Socket _tcpListener;

        private readonly ConcurrentDictionary<IPAddress, (string Name, Socket TcpClient)> _participants = new();
        private readonly List<Message> _history = [];

        private bool _isGettedHistory = false;

        private readonly CancellationTokenSource _cancellationTokenSource = new();

        private readonly Writer _writer;

        public Client(IPAddress address, string name, Writer writer)
        {
            _address = address;
            _name = name;

            _udpClient = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);
            _udpClient.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.Broadcast, true);
            _udpClient.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
            _udpClient.Bind(new IPEndPoint(_address, UdpPort));
            _tcpListener = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            _tcpListener.Bind(new IPEndPoint(_address, TcpPort));

            _writer = writer;
        }

        public void Connect()
        {
            Task.Run(() => StartUdpServerAsync());
            Task.Run(() => StartTcpServerAsync());
        }

        public async Task DisconnectAsync()
        {
            await SendMessageAsync(new Message(MessageType.UserDisconnection, Encoding.UTF8.GetBytes(_name)));

            _cancellationTokenSource.Cancel();

            _udpClient.Close();
            try
            {
                _tcpListener.Shutdown(SocketShutdown.Both);
            }
            finally
            {
                _tcpListener.Close();
            }
        }

        public async Task SendMessageAsync(string text)
        {
            var message = new Message(MessageType.Text, Encoding.UTF8.GetBytes($"{_address.ToString()}, {_name}: " + text));
            await SendMessageAsync(message);
            _writer(message.ToString());
            _history.Add(message);
        }

        public (IPAddress Address, string Name)[] GetParticipants()
        {
            var participants = new (IPAddress Address, string Name)[_participants.Count];
            int i = 0;
            foreach (var participant in _participants)
            {
                participants[i++] = (participant.Key, participant.Value.Name);
            }
            return participants;
        }

        private async Task StartUdpServerAsync()
        {
            for (int i = 0; i < 3; i++)
            {
                await SendBroadcastAsync();
                await Task.Delay(1000);
            }
            await ReceiveBroadcastAsync();
        }

        private async Task SendBroadcastAsync()
        {
            try
            {
                await _udpClient.SendToAsync(new byte[1], new IPEndPoint(IPAddress.Broadcast, UdpPort), _cancellationTokenSource.Token);
            }
            catch (Exception)
            {
                _writer("Send broadcast fail.");
            }
        }

        private async Task ReceiveBroadcastAsync()
        {
            while (!_cancellationTokenSource.IsCancellationRequested)
            {
                try
                {
                    var result = await _udpClient.ReceiveFromAsync(new byte[1], new IPEndPoint(IPAddress.Any, 0), _cancellationTokenSource.Token);

                    IPAddress address = ((IPEndPoint)result.RemoteEndPoint).Address;
                    if (!address.Equals(_address) && !_participants.ContainsKey(address))
                    { 
                        await ConnectByTcpAsync(address);
                    }
                }
                catch (Exception)
                {
                    _writer("Receive broadcast fail.");
                }
            }
        }

        private async Task ConnectByTcpAsync(IPAddress address)
        {
            var tcpClient = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            try
            {
                await tcpClient.ConnectAsync(address, TcpPort, _cancellationTokenSource.Token);

                var message = new Message(MessageType.NameTransfer, Encoding.UTF8.GetBytes(_name));
                await SendMessageAsync(tcpClient, message);

                _ = HandleTcpClientAsync(address, tcpClient);
            }
            catch (Exception)
            {
                _writer("Connect by TCP fail.");
            }
        }

        private async Task StartTcpServerAsync()
        {
            _tcpListener.Listen();

            while (!_cancellationTokenSource.IsCancellationRequested)
            {
                try
                {
                    var tcpClient = await _tcpListener.AcceptAsync(_cancellationTokenSource.Token);

                    if (tcpClient.RemoteEndPoint is IPEndPoint remoteEndPoint)
                    {
                        IPAddress address = remoteEndPoint.Address;

                        _ = HandleTcpClientAsync(address, tcpClient);
                    }
                }
                catch (Exception)
                {
                    _writer("TCP accept fail.");
                }
            }
        }

        private async Task HandleTcpClientAsync(IPAddress address, Socket tcpClient)
        {
            bool canLeaving = false;
            do
            {
                var data = new List<byte>();
                var buffer = new byte[256];
                try
                {
                    using var stream = new NetworkStream(tcpClient);
                    int bytes = 0;
                    do
                    {
                        bytes = await stream.ReadAsync(buffer, _cancellationTokenSource.Token);
                        data.AddRange(buffer);
                    }
                    while (bytes >= buffer.Length);
                }
                catch (Exception)
                {
                    _writer($"Read data fail.");
                    break;
                }

                canLeaving = await HandleMessageAsync(address, tcpClient, Message.ArrayToMessage(data.ToArray()));
                if (!_isGettedHistory)
                {
                    await SendMessageAsync(_participants[new List<IPAddress>(_participants.Keys)[0]].TcpClient, new Message(MessageType.HistoryRequest, new byte[1]));
                    _isGettedHistory = true;
                }
            }
            while (!canLeaving);

            _participants.TryRemove(address, out (string, Socket) _);
            tcpClient.Disconnect(false);
            tcpClient.Shutdown(SocketShutdown.Both);
            tcpClient.Close();
        }

        private async Task<bool> HandleMessageAsync(IPAddress address, Socket tcpClient, Message message)
        {
            var text = Encoding.UTF8.GetString(message.Data);

            bool canDisconnect = false;
            switch (message.Type)
            {
                case MessageType.NameTransfer:
                    _participants[address] = (text, tcpClient);

                    var replyMessage = new Message(MessageType.UserConnection, Encoding.UTF8.GetBytes(_name));
                    await SendMessageAsync(tcpClient, replyMessage);
                    break;
                case MessageType.UserConnection:
                    _participants[address] = (text, tcpClient);

                    var newText = address.ToString() + ", " + Encoding.UTF8.GetString(message.Data);
                    var newMessage = new Message(message.Type, Encoding.UTF8.GetBytes(newText));
                    _writer(newMessage.ToString());
                    _history.Add(newMessage);
                    break;
                case MessageType.HistoryRequest:
                    List<byte> history = new List<byte>();
                    foreach (var item in _history)
                    {
                        var data = item.ToArray();
                        for (var i = 0; i < data.Length; i++)
                        {
                            history.Add(data[i]);
                        }
                    }
                    message = new Message(MessageType.HistoryReply, history.ToArray());
                    await SendMessageAsync(tcpClient, message);
                    break;
                case MessageType.HistoryReply:
                    int j = 0;
                    while (j < message.Data.Length)
                    {
                        int startMessage = j;
                        int endMessage = startMessage + Message.HeaderSize + (message.Data[j + 6] << 8) + message.Data[j + 7];
                        var oneMessage = Message.ArrayToMessage(message.Data[startMessage..endMessage]);
                        _history.Add(oneMessage);
                        _writer(oneMessage.ToString());
                        j = endMessage;
                    }
                    break;
                case MessageType.Text:
                    _writer(message.ToString());
                    _history.Add(message);
                    break;
                case MessageType.UserDisconnection:
                    canDisconnect = true;

                    newText = address.ToString() + ", " + Encoding.UTF8.GetString(message.Data);
                    newMessage = new Message(message.Type, Encoding.UTF8.GetBytes(newText));
                    _writer(newMessage.ToString());
                    _history.Add(newMessage);
                    break;
            }
            return canDisconnect;
        }

        public async Task SendMessageAsync(Message message)
        {
            foreach (var participant in _participants)
            {
                await SendMessageAsync(participant.Value.TcpClient, message);
            }
        }

        private async Task SendMessageAsync(Socket tcpClient, Message message)
        {
            var data = message.ToArray();
            try
            {
                using var stream = new NetworkStream(tcpClient);
                await stream.WriteAsync(data, _cancellationTokenSource.Token);
            }
            catch (Exception)
            {
                _writer("Write data fail.");
            }
        }
    }
}