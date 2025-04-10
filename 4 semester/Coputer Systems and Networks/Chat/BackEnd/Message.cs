using System.Text;

namespace LocalChat.BackEnd
{
    internal enum MessageType : byte
    {
        NameTransfer,
        UserConnection,
        HistoryRequest,
        HistoryReply,
        Text,       
        UserDisconnection,
    }

    internal class Message
    {
        public const int HeaderSize = sizeof(MessageType) + 5 + sizeof(ushort);

        public MessageType Type { get; }
        public string Time { get; }
        public ushort Length { get; }
        public byte[] Data { get; }

        public Message(MessageType type, byte[] data) : this(type, DateTime.Now.ToString("HH:mm"), data) { }

        private Message(MessageType type, string time, byte[] data)
        {
            Type = type;
            Time = time;
            Length = (ushort)data.Length;
            Data = data;
        }

        public byte[] ToArray()
        {
            var arr = new byte[HeaderSize + Length];
            arr[0] = (byte)Type;
            var time = Encoding.UTF8.GetBytes(Time);
            Array.Copy(time, 0, arr, 1, time.Length);
            arr[6] = (byte)(Length >> 8);
            arr[7] = (byte)(Length & 0xFF);
            Array.Copy(Data, 0, arr, HeaderSize, Length);

            return arr;
        }

        public static Message ArrayToMessage(byte[] arr)
        {
            MessageType type = (MessageType)arr[0];
            string time = Encoding.UTF8.GetString(arr[1..6]);
            ushort length = (ushort)((arr[6] << 8) + arr[7]);
            var data = new byte[length];
            Array.Copy(arr, HeaderSize, data, 0, length);

            return new Message(type, time, data);
        }

        public override string ToString()
        {
            string text = Encoding.UTF8.GetString(Data);

            return Type switch
            {
                MessageType.NameTransfer => $"{Time} {text} connected",
                MessageType.UserConnection => $"{Time} {text} connected",
                MessageType.HistoryRequest => "",
                MessageType.HistoryReply => "",
                MessageType.Text => $"{Time}, {text}",
                MessageType.UserDisconnection => $"{Time} {text} disconnected",
                _ => ""
            };
        }
    }
}