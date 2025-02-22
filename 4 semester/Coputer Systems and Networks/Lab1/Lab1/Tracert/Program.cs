using System;
using System.Diagnostics;
using System.Net;
using System.Net.Sockets;

namespace MyTraceroute
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length > 0)
            {
                foreach (string targetInput in args)
                {
                    if (targetInput.Trim().ToLower() == "exit")
                        return;
                    PerformTraceroute(targetInput);
                }
            }
            else
            {
                while (true)
                {
                    Console.Write("Введите IP или доменное имя для traceroute (или 'exit' для выхода): ");
                    string targetInput = Console.ReadLine();
                    if (targetInput.Trim().ToLower() == "exit")
                        break;
                    PerformTraceroute(targetInput);
                }
            }
        }

        static void PerformTraceroute(string targetInput)
        {
            IPAddress targetIP;
            if (!IPAddress.TryParse(targetInput, out targetIP))
            {
                try
                {
                    targetIP = Dns.GetHostEntry(targetInput).AddressList[0];
                    Console.WriteLine("Трассировка маршрута к {0} [{1}], 30 hops max", targetInput, targetIP);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Неверное имя или IP-адрес: " + ex.Message);
                    return;
                }
            }
            else
            {
                try
                {
                    string hostName = Dns.GetHostEntry(targetInput).HostName;
                    Console.WriteLine("Трассировка маршрута к {0} [{1}], 30 hops max", hostName, targetIP);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Трассировка маршрута к {0} [Этот хост неизвестен], 30 hops max", targetInput);
                }
                
            }
            
            const int maxHops = 30;
            const int timeout = 3000; // миллисекунд
            const int probesPerHop = 3; // число запросов на один TTL
            ushort sequence = 1;
            bool reached = false;

            using (Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Raw, ProtocolType.Icmp))
            {
                socket.ReceiveTimeout = timeout;
                for (int ttl = 1; ttl <= maxHops; ttl++)
                {
                    socket.SetSocketOption(SocketOptionLevel.IP, SocketOptionName.IpTimeToLive, ttl);
                    string[] probeResults = new string[probesPerHop];
                    string hopAddress = "";
                    bool gotResponse = false;

                    for (int probe = 0; probe < probesPerHop; probe++)
                    {
                        byte[] packet = CreateIcmpPacket(sequence);
                        EndPoint remoteEndpoint = new IPEndPoint(targetIP, 0);
                        Stopwatch stopwatch = new Stopwatch();
                        stopwatch.Start();

                        try
                        {
                            socket.SendTo(packet, remoteEndpoint);
                            byte[] buffer = new byte[1024];
                            EndPoint sender = new IPEndPoint(IPAddress.Any, 0);
                            int bytesReceived = socket.ReceiveFrom(buffer, ref sender);
                            stopwatch.Stop();

                            int ipHeaderLength = (buffer[0] & 0x0F) * 4;
                            byte icmpType = buffer[ipHeaderLength];

                            hopAddress = sender.ToString();
                            probeResults[probe] = stopwatch.ElapsedMilliseconds + " ms";
                            gotResponse = true;

                            if (icmpType == 0)
                                reached = true;
                        }
                        catch (SocketException)
                        {
                            stopwatch.Stop();
                            probeResults[probe] = "*";
                        }

                        sequence++;
                    }

                    Console.Write("{0,2}   ", ttl);
                    for (int i = 0; i < probesPerHop; i++)
                    {
                        Console.Write("{0,8} ", probeResults[i]);
                    }

                    if (gotResponse)
                    {
                        try
                        {
                            string ipOnly = hopAddress.Split(':')[0];
                            IPAddress addr = IPAddress.Parse(ipOnly);
                            string hostName = Dns.GetHostEntry(addr).HostName;
                            Console.Write(" {0} [{1}]", hostName, addr);
                        }
                        catch
                        {
                            Console.Write(" {0}", hopAddress);
                        }
                    }

                    Console.WriteLine();

                    if (reached)
                    {
                        Console.WriteLine("Целевой узел достигнут.");
                        break;
                    }
                }
            }
            Console.WriteLine("Трассировка завершена.\n");
        }
        static byte[] CreateIcmpPacket(ushort sequence)
        {
            byte[] packet = new byte[32];
            packet[0] = 8;  
            packet[1] = 0;
            packet[2] = 0;
            packet[3] = 0;
            packet[4] = 0;
            packet[5] = 1;
            packet[6] = (byte)(sequence >> 8);
            packet[7] = (byte)(sequence & 0xFF);

            for (int i = 8; i < packet.Length; i++)
            {
                packet[i] = (byte)'a';
            }
            ushort checksum = ComputeChecksum(packet);
            packet[2] = (byte)(checksum >> 8);
            packet[3] = (byte)(checksum & 0xFF);

            return packet;
        }

        static ushort ComputeChecksum(byte[] data)
        {
            uint sum = 0;
            int i = 0;
            while (i < data.Length - 1)
            {
                ushort word = (ushort)((data[i] << 8) + data[i + 1]);
                sum += word;
                i += 2;
            }

            if (data.Length % 2 == 1)
            {
                sum += (ushort)(data[data.Length - 1] << 8);
            }

            while ((sum >> 16) != 0)
            {
                sum = (sum & 0xFFFF) + (sum >> 16);
            }
            return (ushort)~sum;
        }
    }
}
