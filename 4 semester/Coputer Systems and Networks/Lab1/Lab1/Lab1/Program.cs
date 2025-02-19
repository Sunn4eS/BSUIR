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
            // Если аргументы переданы – обрабатываем их, иначе интерактивный режим
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
            // Преобразование имени или IP в объект IPAddress
            IPAddress targetIP;
            if (!IPAddress.TryParse(targetInput, out targetIP))
            {
                try
                {
                    targetIP = Dns.GetHostEntry(targetInput).AddressList[0];
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Неверное имя или IP-адрес: " + ex.Message);
                    return;
                }
            }
            


            Console.WriteLine("Трассировка маршрута к {0} [{1}], 30 hops max", targetInput, targetIP);
            const int maxHops = 30;
            const int timeout = 3000; // миллисекунд
            const int probesPerHop = 3; // число запросов на один TTL
            ushort sequence = 1;
            bool reached = false;

            try
            {
                // Для работы с ICMP требуется запуск с правами администратора
                using (Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Raw, ProtocolType.Icmp))
                {
                    socket.ReceiveTimeout = timeout;

                    // Основной цикл по значениям TTL (хопам)
                    for (int ttl = 1; ttl <= maxHops; ttl++)
                    {
                        socket.SetSocketOption(SocketOptionLevel.IP, SocketOptionName.IpTimeToLive, ttl);
                        string[] probeResults = new string[probesPerHop];
                        string hopAddress = "";
                        bool gotResponse = false;

                        // Отправляем несколько (3) запросов для каждого значения TTL
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

                                // Извлекаем длину IP-заголовка и поле ICMP Type
                                int ipHeaderLength = (buffer[0] & 0x0F) * 4;
                                byte icmpType = buffer[ipHeaderLength];

                                // Сохраняем адрес узла, который ответил
                                hopAddress = sender.ToString();
                                probeResults[probe] = stopwatch.ElapsedMilliseconds + " ms";
                                gotResponse = true;

                                // Если получен Echo Reply (тип 0), значит цель достигнута
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

                        // Выводим результаты для текущего TTL в одну строку
                        Console.Write("{0,2}   ", ttl);
                        for (int i = 0; i < probesPerHop; i++)
                        {
                            Console.Write("{0,8} ", probeResults[i]);
                        }
                        if (gotResponse)
                        {
                            // Пытаемся получить имя узла по IP
                            try
                            {
                                // Убираем возможный порт (например, "216.58.208.110:0")
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
            }
            catch (SocketException ex)
            {
                Console.WriteLine("Ошибка сокета: " + ex.Message);
            }

            Console.WriteLine("Трассировка завершена.\n");
        }

        // Метод формирования ICMP Echo Request
        static byte[] CreateIcmpPacket(ushort sequence)
        {
            // Размер пакета: 8 байт заголовка + 24 байта данных (всего 32 байта)
            byte[] packet = new byte[32];

            packet[0] = 8;   // Type: Echo Request
            packet[1] = 0;   // Code: 0

            // Контрольная сумма пока заполняется нулями
            packet[2] = 0;
            packet[3] = 0;

            // Identifier (можно задать произвольное значение, например, 1)
            packet[4] = 0;
            packet[5] = 1;

            // Sequence Number
            packet[6] = (byte)(sequence >> 8);
            packet[7] = (byte)(sequence & 0xFF);

            // Заполняем оставшуюся часть пакета данными (например, символами 'a')
            for (int i = 8; i < packet.Length; i++)
            {
                packet[i] = (byte)'a';
            }

            // Вычисляем и вставляем контрольную сумму
            ushort checksum = ComputeChecksum(packet);
            packet[2] = (byte)(checksum >> 8);
            packet[3] = (byte)(checksum & 0xFF);

            return packet;
        }

        // Метод вычисления контрольной суммы для ICMP-пакета
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
