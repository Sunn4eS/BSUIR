using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Collections.Concurrent;

namespace ChatApp.Backend;

internal class Client
{
    public delegate void Writer(string name);
    public Writer _writer;
    public const int UdpPort = 3001;
    public const int TcpPort = 3000;
    public delegate void NodeEventHandler(string name, IPAddress ip);

    public event NodeEventHandler NewNodeDetected;
    public event NodeEventHandler NodeDisconnected;
    
    private Socket _udpSender;
    private Socket _tcpListener;
    
    private readonly IPAddress _address;
    private readonly string _name;
    
    
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
        SendBroadcast();
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
      new Thread(ListenUDP).Start();
      new Thread(ListenTcp).Start();
    }

    private void SendBroadcast()
    {
       Message msg = new Message(MessageType.NameTransfer, Encoding.UTF8.GetBytes(_name));
       IPEndPoint broadCastEndPoint = new IPEndPoint(IPAddress.Broadcast, UdpPort);
       _udpSender.SendTo(msg.Serialize(), broadCastEndPoint);
    }

    private void ListenUDP()
    {
        while (_isRunning)
        {
            try
            {
                var buffer = new byte[1024];
                EndPoint remoteEp = new IPEndPoint(IPAddress.Any, 0);
                int received = _udpSender.ReceiveFrom(buffer, ref remoteEp);
                    
                var message = new Message(MessageType.MessageText, buffer).Deserialize(buffer[..received]);
                var ip = ((IPEndPoint)remoteEp).Address;

                if (message.Type == MessageType.NameTransfer && !_clients.ContainsKey(ip))
                {
                    Connect(ip, Encoding.UTF8.GetString(message.Data));
                }
            }
            catch { /* Handle exceptions */ }
        }
    }

    private void ListenTcp()
    {
        while (_isRunning)
        {
            var socket = _tcpListener.Accept();
            var ip = ((IPEndPoint)socket.RemoteEndPoint).Address;
            var buffer = new byte[Message.HeaderSize];
            socket.Receive(buffer);
            var msg = new Message(MessageType.NameTransfer, buffer).Deserialize(buffer);
            _clients[ip] = (Encoding.UTF8.GetString(msg.Data), socket);
            NewNodeDetected?.Invoke(_clients[ip].Name, ip);
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

    private void HandleConnection(Socket socket, IPAddress ip)
    {
        try
        {
            while (_isRunning)
            { 
                byte[] buffer = new byte[Message.HeaderSize];
                socket.Receive(buffer);
                Message header = new Message(MessageType.MessageText, buffer).Deserialize(buffer);
                byte[] data = new byte[header.Length];
                socket.Receive(data);
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
                NodeDisconnected?.Invoke(client.Name, ip);
            }
        }
    }

    private void Connect(IPAddress ip, string name)
    {
        try
        {
            Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            socket.Connect(new IPEndPoint(ip, TcpPort));
            Message connectMsg = new Message(MessageType.NameTransfer, Encoding.UTF8.GetBytes(name));
            socket.Send(connectMsg.Serialize());
            _clients[ip] = (name, socket);
            NewNodeDetected?.Invoke(name, ip);
            new Thread(() => HandleConnection(socket, ip)).Start();  
        }
        catch
        {
            
        }
    }
    
    
    
    
}