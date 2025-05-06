using System;
using System.IO;
using System.Net;
using System.Net.Sockets; 
using System.Text;
using System.Threading;
using System.Text.RegularExpressions;

class HttpProxyServer
{
    private readonly int port;
    private readonly TcpListener listener;
    private bool isRunning;

    public HttpProxyServer(int port)
    {
        this.port = port;
        listener = new TcpListener(IPAddress.Any, port);
    }

    public void Start()
    {
        isRunning = true;
        listener.Start();
        Console.WriteLine($"Proxy server started on port {port}");

        while (isRunning)
        {
            try
            {
                TcpClient client = listener.AcceptTcpClient();
                Thread clientThread = new Thread(() => HandleClient(client));
                clientThread.Start();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error accepting client: {ex.Message}");
            }
        }
    }

    public void Stop()
    {
        isRunning = false;
        listener.Stop();
    }

    private void HandleClient(TcpClient client)
    {
        try
        {
            using (client)
            using (NetworkStream clientStream = client.GetStream())
            {
                // Читаем HTTP-запрос
                byte[] buffer = new byte[4096];
                int bytesRead = clientStream.Read(buffer, 0, buffer.Length);
                string request = Encoding.ASCII.GetString(buffer, 0, bytesRead);
                
                if (!ParseRequest(request, out string host, out int port, out string fullUrl, out string requestLine))
                {
                    Console.WriteLine("Invalid request");
                    return;
                }

                string logEntry = $"[{DateTime.Now}] URL: {fullUrl}";

                // Подключаемся к целевому серверу
                using (TcpClient server = new TcpClient(host, port))
                using (NetworkStream serverStream = server.GetStream())
                {
                    // Отправляем преобразованный запрос серверу
                    byte[] requestBytes = Encoding.ASCII.GetBytes(requestLine);
                    serverStream.Write(requestBytes, 0, requestBytes.Length);

                    // Читаем ответ сервера
                    bytesRead = serverStream.Read(buffer, 0, buffer.Length);
                    string response = Encoding.ASCII.GetString(buffer, 0, bytesRead);

                    // Извлекаем код ответа
                    string statusCode = ExtractStatusCode(response);

                    // Завершаем лог с кодом ответа
                    logEntry += $", Status: {statusCode}\n";
                    Console.WriteLine(logEntry);
                    File.AppendAllText("proxy_log.txt", logEntry);

                    // Отправляем ответ клиенту
                    clientStream.Write(buffer, 0, bytesRead);

                    // Продолжаем пересылку данных
                    while ((bytesRead = serverStream.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        clientStream.Write(buffer, 0, bytesRead);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error handling client: {ex.Message}");
        }
    }

    private bool ParseRequest(string request, out string host, out int port, out string fullUrl, out string modifiedRequest)
    {
        host = string.Empty;
        port = 80;
        fullUrl = string.Empty;
        modifiedRequest = request;

        string[] lines = request.Split(new[] { "\r\n" }, StringSplitOptions.None);
        if (lines.Length == 0) return false;

        // Парсим первую строку запроса
        string firstLine = lines[0];
        var match = Regex.Match(firstLine, @"^(GET|POST|HEAD) (http://[^/]+)(/.*)? (HTTP/\d\.\d)$");
        if (!match.Success) return false;

        string method = match.Groups[1].Value;
        string hostPart = match.Groups[2].Value;
        string path = match.Groups[3].Success ? match.Groups[3].Value : "/";
        string httpVersion = match.Groups[4].Value;

        fullUrl = hostPart + path;

        // Извлекаем хост и порт
        host = hostPart.Replace("http://", "");
        if (host.Contains(":"))
        {
            string[] parts = host.Split(':');
            host = parts[0];
            if (!int.TryParse(parts[1], out port))
                port = 80;
        }

        // Формируем модифицированный запрос (только путь)
        modifiedRequest = $"{method} {path} {httpVersion}\r\n";
        for (int i = 1; i < lines.Length; i++)
        {
            // Пропускаем или модифицируем заголовки, если нужно
            if (!lines[i].StartsWith("Proxy-Connection:", StringComparison.OrdinalIgnoreCase))
            {
                modifiedRequest += lines[i] + "\r\n";
            }
            else
            {
                // Заменяем Proxy-Connection на Connection
                modifiedRequest += "Connection: close\r\n";
            }
        }

        return !string.IsNullOrEmpty(host);
    }

    private string ExtractStatusCode(string response)
    {
        string[] lines = response.Split(new[] { "\r\n" }, StringSplitOptions.None);
        if (lines.Length == 0) return "Unknown";
        
        var match = Regex.Match(lines[0], @"HTTP/\d\.\d (\d{3})");
        return match.Success ? match.Groups[1].Value : "Unknown";
    }

    static void Main(string[] args)
    {
        HttpProxyServer proxy = new HttpProxyServer(8080);
        try
        {
            proxy.Start();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Server error: {ex.Message}");
        }
        finally
        {
            proxy.Stop();
        }
    }
}