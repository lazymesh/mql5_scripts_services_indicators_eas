import socket
import threading

sockets = {}
clients = {}
mt5clients = []
nicknames = []
host = '127.0.0.1'
CURRENCYPAIR_PORT = {
    "AUDUSD": 9070,
    "AUDJPY": 9071,
    "AUDCAD": 9072,
    "AUDNZD": 9073,
    "AUDCHF": 9074,
    "CADJPY": 9075,
    "CADCHF": 9076,
    "CHFJPY": 9077,
    "EURUSD": 9078,
    "EURJPY": 9079,
    "EURGBP": 9080,
    "EURCAD": 9081,
    "EURAUD": 9082,
    "EURNZD": 9083,
    "EURCHF": 9084,
    "GBPUSD": 9085,
    "GBPJPY": 9086,
    "GBPCAD": 9087,
    "GBPAUD": 9088,
    "GBPNZD": 9089,
    "GBPCHF": 9090,
    "NZDUSD": 9091,
    "NZDJPY": 9092,
    "NZDCAD": 9093,
    "USDCHF": 9094,
    "USDJPY": 9095,
    "USDCAD": 9096,
    "NZDCHF": 9097
}

for key in CURRENCYPAIR_PORT:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.bind((host, CURRENCYPAIR_PORT[key]))
    sock.listen()
    sockets[key] = sock

def broadcast(message, key):
    if clients and key in clients.keys():
        
        for client in clients[key]:
            try:
                client.send(message)
            except Exception as ex:
                print(f"A client is being closed for {key} due to {ex}")
                sendClients = clients[key]
                sendClients.remove(client)
                clients[key] = sendClients

def mt5ReceiveBroadcast(client, key):
     while True:
        try:
            message = client.recv(1024)
            if not message:
                break
            broadcast(message, key)
        except Exception as ex:
            mt5clients.remove(client)
            client.close()
            listenForClient(key)

def listenForClient(key):
    client, addresss = sockets[key].accept()
    isMt5 = client.recv(10).decode('utf-8')
    print(isMt5)
    if isMt5 == "mt5":
        print(f"connected mt5 for {key} on {client.getsockname()}")
        mt5clients.append(client)
        mt5ReceiveBroadcast(client, key)
    else:
        print(f"new client for {key}")
        sockClients = clients[key] if key in clients.keys() else []
        sockClients.append(client)
        clients[key] = sockClients
        thread = threading.Thread(target=listenForClient, args=(key,))
        thread.start()

def startClients():
    for key in CURRENCYPAIR_PORT:
        thread = threading.Thread(target=listenForClient, args=(key,))
        thread.start()

print('Server is listening')
# one for mt5 connection and one for other clients
startClients()
startClients()