#pragma once
#define _WINSOCK_DEPRECATED_NO_WARNINGS 
#define WIN32_LEAN_AND_MEAN

#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <string>


enum PacketType {
    PKT_INIT,       
    PKT_READY,      
    PKT_GAME_DATA,  
    PKT_GAME_OVER   
};

struct GamePacket {
    int type;
    int role;
    int x, y;
    int dirX, dirY;
    int score;
    int lives;
    int winner; 
    int eatenX;      
    int eatenY;      
    bool powerPellet;
};

extern SOCKET connectSocket;
extern bool isHost;
extern bool isConnected;

void InitWinsock();
bool StartServer();             
bool ConnectToServer(const char* ip); 
std::string GetLocalIPAddress();      
void SendGamePacket(GamePacket p);
bool ReceiveGamePacket(GamePacket& p);
void CleanupNetwork();