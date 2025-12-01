#include "Network.h"

SOCKET connectSocket = INVALID_SOCKET;
bool isHost = false;
bool isConnected = false;

void InitWinsock() {
    WSADATA wsaData;
    WSAStartup(MAKEWORD(2, 2), &wsaData);
}

void SetNonBlocking(SOCKET s) {
    u_long mode = 1;
    ioctlsocket(s, FIONBIO, &mode);
}

bool StartServer() {
    SOCKET listenSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (listenSocket == INVALID_SOCKET) return false;

    sockaddr_in service;
    service.sin_family = AF_INET;
    service.sin_addr.s_addr = INADDR_ANY;
    service.sin_port = htons(27015);

    if (bind(listenSocket, (SOCKADDR*)&service, sizeof(service)) == SOCKET_ERROR) {
        closesocket(listenSocket);
        return false;
    }

    if (listen(listenSocket, 1) == SOCKET_ERROR) {
        closesocket(listenSocket);
        return false;
    }

    connectSocket = listenSocket;
    SetNonBlocking(connectSocket);
    isHost = true;
    return true;
}

std::string GetLocalIPAddress() {
    char hostname[256];
    if (gethostname(hostname, sizeof(hostname)) == SOCKET_ERROR) return "Error";

    struct addrinfo hints = { 0 }, * res = NULL;
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;

    if (getaddrinfo(hostname, NULL, &hints, &res) == 0) {
        struct addrinfo* ptr = res;
        while (ptr != NULL) {
            sockaddr_in* sockaddr_ipv4 = (sockaddr_in*)ptr->ai_addr;
            char ipStr[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, &sockaddr_ipv4->sin_addr, ipStr, INET_ADDRSTRLEN);

            std::string ip(ipStr);
            if (ip != "127.0.0.1") {
                freeaddrinfo(res);
                return ip;
            }
            ptr = ptr->ai_next;
        }
        freeaddrinfo(res);
    }
    return "Check ipconfig";
}

bool ConnectToServer(const char* ip) {
    if (connectSocket != INVALID_SOCKET) closesocket(connectSocket);
    connectSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (connectSocket == INVALID_SOCKET) return false;

    int flag = 1;
    setsockopt(connectSocket, IPPROTO_TCP, TCP_NODELAY, (char*)&flag, sizeof(int));

    sockaddr_in clientService;
    clientService.sin_family = AF_INET;
    inet_pton(AF_INET, ip, &clientService.sin_addr);
    clientService.sin_port = htons(27015);

    if (connect(connectSocket, (SOCKADDR*)&clientService, sizeof(clientService)) == SOCKET_ERROR) {
        closesocket(connectSocket);
        connectSocket = INVALID_SOCKET;
        return false;
    }

    u_long mode = 1;
    ioctlsocket(connectSocket, FIONBIO, &mode);
    isConnected = true;
    isHost = false;
    return true;
}

void SendGamePacket(GamePacket p) {
    if (connectSocket != INVALID_SOCKET) {
        send(connectSocket, (char*)&p, sizeof(GamePacket), 0);
    }
}

bool ReceiveGamePacket(GamePacket& p) {
    if (connectSocket == INVALID_SOCKET) return false;

    int bytes = recv(connectSocket, (char*)&p, sizeof(GamePacket), 0);
    if (bytes > 0) {
        return true;
    }
    return false;
}

void CleanupNetwork() {
    if (connectSocket != INVALID_SOCKET) closesocket(connectSocket);
    WSACleanup();
}