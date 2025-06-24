import socket
import threading

mt5Sockets = {} # for storing ports for recieving mt5 messages
clientSockets = {} # for storing ports for sending messages
mt5clients = [] # storing mt5 connections 
otherClients = {} # storing currency pair wise other clients
host = '127.0.0.1'
CURRENCY_PAIRS = {
    "AUDUSD",
    "AUDJPY",
    "AUDCAD",
    "AUDNZD",
    "AUDCHF",
    "CADJPY",
    "CADCHF",
    "CHFJPY",
    "EURUSD",
    "EURJPY",
    "EURGBP",
    "EURCAD",
    "EURAUD",
    "EURNZD",
    "EURCHF",
    "GBPUSD",
    "GBPJPY",
    "GBPCAD",
    "GBPAUD",
    "GBPNZD",
    "GBPCHF",
    "NZDUSD",
    "NZDJPY",
    "NZDCAD",
    "USDCHF",
    "USDJPY",
    "USDCAD",
    "NZDCHF",
}

MT5_SOCKET_PORT_START = 9020
CLIENT_SOCKET_PORT_START = 9050

for index, key in enumerate(CURRENCY_PAIRS):
    # these sockets and ports are for mt5 side for recieving info from mt5
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    port = MT5_SOCKET_PORT_START + index
    print(port)
    sock.bind((host, port))
    sock.listen()
    mt5Sockets[key] = sock
    # these sockets and ports are for other clients for sending info
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    port = CLIENT_SOCKET_PORT_START + index
    sock.bind((host, port))
    sock.listen()
    clientSockets[key] = sock

def broadcast(message, key):
    if otherClients and key in otherClients.keys():
        for client in otherClients[key]:
            try:
                client.send(message)
            except Exception as ex:
                print(f"A client is being closed for {key} due to {ex}")
                sendClients = otherClients[key]
                sendClients.remove(client)
                client.close()
                otherClients[key] = sendClients

def mt5ReceiveBroadcast(mt5Client, key):
     while True:
        try:
            message = mt5Client.recv(1024)
            if not message:
                break
            broadcast(message, key)
        except Exception as ex:
            mt5clients.remove(mt5Client)
            mt5Client.close()
            listenForMt5Clients(key)

def listenForMt5Clients(key):
    client, addresss = mt5Sockets[key].accept()
    messageFromClient = client.recv(20).decode('utf-8')
    if messageFromClient == "mt5":
        print(f"connected mt5 for {key} on {client.getsockname()}")
        mt5clients.append(client)
        mt5ReceiveBroadcast(client, key)
        
def listenForOtherClients(key):
    client, addresss = clientSockets[key].accept()
    messageFromClient = client.recv(20).decode('utf-8')
    if messageFromClient != "mt5":
        print(f"new client for {key}")
        sockClients = otherClients[key] if key in otherClients.keys() else []
        sockClients.append(client)
        otherClients[key] = sockClients
        # new thread for new client connections
        thread = threading.Thread(target=listenForOtherClients, args=(key,))
        thread.start()

def startClients():
    for key in CURRENCY_PAIRS:
        # threads for mt5 socket connections
        thread = threading.Thread(target=listenForMt5Clients, args=(key,))
        thread.start()
        # threads for other socket client connections
        thread = threading.Thread(target=listenForOtherClients, args=(key,))
        thread.start()

print('Server is listening')
startClients()