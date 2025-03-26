using System.Text;

namespace ChatApp.Backend;

internal enum MessageType : byte
{
    MessageText,
    NameTransfer,
    UserConnected,
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

    public Message Deserialize(byte[] dataArr)
    {
        MessageType type = (MessageType)dataArr[0];
        string time = Encoding.UTF8.GetString(dataArr[1..6]);
        ushort length = (ushort)((dataArr[6] << 8) + dataArr[7]);
        var data = new byte[length];
        Array.Copy(data, HeaderSize, data, 0, length);

        return new Message(type, time, data);
    }
    
}