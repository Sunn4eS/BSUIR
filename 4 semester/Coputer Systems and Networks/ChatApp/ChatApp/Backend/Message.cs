using System.Net.Sockets;
using System.Text;

namespace ChatApp.Backend;

internal enum MessageType : byte
{
    MessageText,
    NameTransfer,
    UserConnected,
    HistoryRequest,
    HistoryResponse,
    UserDisconnected,
}

internal class Message
{
    public MessageType Type { get; set; }
    public byte[] Data { get; set; }
    public string Time { get; set; }
    public ushort Length { get; set; }
    
    public Message(MessageType type, byte[] data) : this(type, DateTime.Now.ToString("HH:mm"), data) {}
    private Message(MessageType type, string time, byte[] data)
    {
        Type = type;
        Time = time;
        Length = (ushort)data.Length;
        Data = data;
    }
    public const int HeaderSize = sizeof(MessageType) + 5 + sizeof(ushort);

    public byte[] Serialize()
    {
        byte[] dataArr = new byte[HeaderSize + Length];
        dataArr[0] = (byte)Type;
        Array.Copy(Encoding.UTF8.GetBytes(Time), 0, dataArr, 1, Encoding.UTF8.GetBytes(Time).Length);
        dataArr[6] = (byte)(Length >> 8);
        dataArr[7] = (byte)(Length & 0xFF);
        Array.Copy(Data, 0, dataArr, 8, Data.Length);
        return dataArr;
    }

    // public static Message Deserialize(byte[] dataArr)
    // {
    //     MessageType type = (MessageType)dataArr[0];
    //     string time = Encoding.UTF8.GetString(dataArr[1..6]);
    //     ushort length = (ushort)((dataArr[6] << 8) + dataArr[7]);
    //     var data = new byte[length];
    //     Array.Copy(dataArr, HeaderSize, data, 0, length);
    //
    //     return new Message(type, time, data);
    // }
    public static Message Deserialize(byte[] dataArr)
    {
        if (dataArr == null || dataArr.Length < HeaderSize)
            throw new ArgumentException("Invalid message data: insufficient length");

        MessageType type = (MessageType)dataArr[0];
    
        string time = Encoding.UTF8.GetString(dataArr, 1, 5);
    
        ushort length = (ushort)((dataArr[6] << 8) | dataArr[7]);
    
        if (dataArr.Length < HeaderSize + length)
            throw new ArgumentException($"Invalid message data: expected {HeaderSize + length} bytes, got {dataArr.Length}");
        byte[] data = new byte[length];
        Buffer.BlockCopy(dataArr, HeaderSize, data, 0, length);

        return new Message(type, time, data);
    }

    public override string ToString()
    {
        string text = Encoding.UTF8.GetString(Data);

        return Type switch
        {
            MessageType.NameTransfer => $"{Time} {text} connected",
            MessageType.UserConnected => $"{Time} {text} connected",
            MessageType.HistoryRequest => "",
            MessageType.HistoryResponse => "",
            MessageType.MessageText => $"{Time}, {text}",
            MessageType.UserDisconnected => $"{Time} {text} disconnected",
            _ => ""
        };
    }

}