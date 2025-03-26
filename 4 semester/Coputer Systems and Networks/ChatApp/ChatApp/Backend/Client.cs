using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Collections.Concurrent;

namespace ChatApp.Backend;

internal class Client
{
    public delegate void Writer(string name);
    public Writer _writer;
    
    private readonly Socket _udpSender;
    private readonly Socket _tcpListener;
    
    private readonly IPAddress _address;
    private readonly string _name;
    
    private readonly ConcurrentDictionary<IPAddress, (string Name, Socket)> _clients = new();


    public Client(IPAddress address, string name, Writer writer)
    {
        _address = address;
        _name = name;
        _writer = writer;
        
        _udpSender = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);
        _udpSender.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
        _udpSender.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.Broadcast, true);
        _udpSender.Bind(new IPEndPoint(_address, 3001));
        
        _tcpListener = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        _tcpListener.Bind(new IPEndPoint(_address, 3000));
    }
    
    
}