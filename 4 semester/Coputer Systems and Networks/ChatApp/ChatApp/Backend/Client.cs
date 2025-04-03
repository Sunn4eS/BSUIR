using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Collections.Concurrent;

namespace ChatApp.Backend;

internal class Client
{
    public delegate void Writer(string name);

    public Writer _writer;
    public const int UdpPort = 3000;
    public const int TcpPort = 3001;

    private Socket _udpSender;
    private Socket _tcpListener;

    private readonly IPAddress _address;
    private readonly string _name;
    private CancellationTokenSource _cancellationTokenSource;

    public List<Message> _history;

    public ConcurrentDictionary<IPAddress, (string Name, Socket socket)> _clients = new();
    private bool _isRunning;

    public Client(IPAddress address, string name, Writer writer)
    {
        _address = address;
        _name = name;
        _writer = writer;
    }

    public void Start()
    {
        _isRunning = true;
        InitializeSockets();
        StartListening();
    }

    private void InitializeSockets()
    {
        _udpSender = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);
        _udpSender.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
        _udpSender.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.Broadcast, true);
        _udpSender.Bind(new IPEndPoint(_address, UdpPort));

        _tcpListener = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        _tcpListener.Bind(new IPEndPoint(_address, TcpPort));
        _tcpListener.Listen(10);
    }

    private void StartListening()
    {
        Task.Run(() => StartUdp());

    }

    private async Task SendBroadcast()
    {
        
       IPEndPoint broadCastEndPoint = new IPEndPoint(IPAddress.Broadcast, UdpPort);
       await _udpSender.SendToAsync(new byte[1], broadCastEndPoint, _cancellationTokenSource.Token);
    }

    private async Task StartUdp()
    {
        for (int i = 0; i < 3; i++)
        {
            await SendBroadcast();
            await Task.Delay(1000);
        }

        await ListenUDP();
    }

    private async Task ListenUDP()
    {
        while (!_cancellationTokenSource.IsCancellationRequested)
        {
            try
            {
                var result = await _udpSender.ReceiveFromAsync(new byte[1], new IPEndPoint(IPAddress.Any, 0),
                    _cancellationTokenSource.Token);
                var address = ((IPEndPoint)result.RemoteEndPoint).Address;
                if (address.Equals(_address) && !_clients.ContainsKey(address))
                {
                    

                }
            }
            catch
            {
                _writer("Receiving broadcast error");
            }
        }
    }
    // private async Task ListenUDP()
    // {
    //     while (_isRunning)
    //     {
    //         try
    //         {
    //             var buffer = new byte[1024];
    //             EndPoint remoteEp = new IPEndPoint(IPAddress.Any, 0);
    //             int received = _udpSender.ReceiveFrom(buffer, ref remoteEp);
    //                 
    //             var message = Message.Deserialize(buffer[..received]);
    //             var ip = ((IPEndPoint)remoteEp).Address;
    //
    //             if (message.Type == MessageType.NameTransfer && !_clients.ContainsKey(ip))
    //             {
    //                 Connect(ip, Encoding.UTF8.GetString(message.Data));
    //             }
    //         }
    //         catch { /* Handle exceptions */ }
    //     }
    // }

    private void ListenTcp()
    {
        while (_isRunning)
        {
            var socket = _tcpListener.Accept();
            var ip = ((IPEndPoint)socket.RemoteEndPoint).Address;
            var buffer = new byte[Message.HeaderSize];
            socket.Receive(buffer);
            var msg = Message.Deserialize(buffer);
            _clients[ip] = (Encoding.UTF8.GetString(msg.Data), socket);
     //       NewNodeDetected?.Invoke(_clients[ip].Name, ip);
            new Thread(() => HandleConnection(socket, ip)).Start();
        }
    }

    public void SendMessageToAll(string text)
    {
        Message msg = new Message(MessageType.MessageText, Encoding.UTF8.GetBytes(text));
        foreach (var client in _clients) 
        {
            client.Value.socket.Send(msg.Serialize());
        }
        _writer?.Invoke($"[{DateTime.Now:HH:mm}] Вы: {text}");
    }
    
    static private byte[] ReceiveExact(Socket socket, int byteCount)
    {
        byte[] buffer = new byte[byteCount];
        int totalRead = 0;
        while (totalRead < byteCount)
        {
            int read = socket.Receive(buffer, totalRead, byteCount - totalRead, SocketFlags.None);
            if (read == 0)
                throw new Exception("Соединение закрыто");
            totalRead += read;
        }
        return buffer;
    }

    private void HandleConnection(Socket socket, IPAddress ip)
    {
        try
        {
            while (_isRunning)
            { 
                byte[] buffer = new byte[Message.HeaderSize];
                //socket.Receive(buffer);
                buffer = ReceiveExact(socket, Message.HeaderSize);
                Message header = Message.Deserialize(buffer);
                byte[] data = new byte[header.Length];
                //socket.Receive(data);
                data = ReceiveExact(socket, Message.HeaderSize);
                Message message = new Message(header.Type, data) {Time = header.Time};

                switch (message.Type)
                {
                    case MessageType.MessageText:
                        _writer?.Invoke($"[{message.Time}] {_clients[ip].Name}: {Encoding.UTF8.GetString(message.Data)}");
                        break;
                    case MessageType.UserDisconnected:
                        Disconnect(ip);
                        break;
                }
            }
        }
        catch
        {
            Disconnect(ip);    
        }
    }

    public void Stop()
    {
        _isRunning = false;
        Message msg = new Message(MessageType.UserDisconnected, Encoding.UTF8.GetBytes(""));
        foreach (var client in _clients.Values)
        {
            client.socket.Send(msg.Serialize());
            client.socket.Close();
        }
        _udpSender.Close();
        _tcpListener.Close();
    }

    private void Disconnect(IPAddress ip)
    {
        if (_clients.ContainsKey(ip))
        {
            if (_clients.TryRemove(ip, out var client))
            {
                client.socket.Close();
    //            NodeDisconnected?.Invoke(client.Name, ip);
            }
        }
    }

    // private void Connect(IPAddress ip, string name)
    // {
    //     try
    //     {
    //         Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
    //         socket.Connect(new IPEndPoint(ip, TcpPort));
    //         
    //         Message connectMsg = new Message(MessageType.NameTransfer, Encoding.UTF8.GetBytes(name));
    //         socket.Send(connectMsg.Serialize());
    //         _clients[ip] = (name, socket);
    //         NewNodeDetected?.Invoke(name, ip);
    //         new Thread(() => HandleConnection(socket, ip)).Start();  
    //     }
    //     catch
    //     {
    //         
    //     }
    // }
    private void Connect(IPAddress ip, string name)
    {
        try
        {
            Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            socket.Connect(new IPEndPoint(ip, TcpPort));
        
            // Сначала получаем заголовок от удаленного узла
        
            // Теперь отправляем свое имя
            Message connectMsg = new Message(MessageType.NameTransfer, Encoding.UTF8.GetBytes(_name));
            socket.Send(connectMsg.Serialize());
            
            _clients[ip] = (name, socket);
  //          NewNodeDetected?.Invoke(name, ip);
            new Thread(() => HandleConnection(socket, ip)).Start();
        }
        catch (Exception ex)
        {
            _writer?.Invoke($"Connection error to {ip}: {ex.Message}");
        }
    }
    
    
    
    
}