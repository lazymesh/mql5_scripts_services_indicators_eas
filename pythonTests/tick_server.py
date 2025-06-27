import socket
import threading
import json
import time

connectedClients = {}
host = '127.0.0.1'
CURRENCY_PAIRS = [
    "AUDUSD",
    "EURUSD"
]

MT5_RECIEVING_PORT = 9070
CLIENT_SENDING_PORT = 9071

mt5Socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
mt5Socket.bind((host, MT5_RECIEVING_PORT))
mt5Socket.listen()
clientSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
clientSocket.bind((host, CLIENT_SENDING_PORT))
clientSocket.listen()

def broadcastToClients(pair, message):
    for client in connectedClients[pair]:
        print("sending data to clients")
        try:
            client.send(str(message).encode("ascii"))
        except Exception as ex:
            print(f"error while sending {message} to {client} for {pair}")
            client.close()
            clients = connectedClients[pair]
            clients.remove(client)
            connectedClients[pair] = clients
            
        
def processMt5Data(mt5Client):
    data = "mt5 client connected"
    repeatativeEmpty = 0
    while(len(data) > 0):
        try:
            data = mt5Client.recv(1024000).decode("ascii")
            if len(data) > 0:
                for jsn in data.split("#@#"):
                    if "}{" in jsn:
                        print(f"data contains {jsn}")
                        splittedTickData = jsn.split("}{")
                        jsn = splittedTickData[0] + "}"
                        print(f"after removing {jsn}")
                    jsonTickData = json.loads(jsn)
                    pair = jsonTickData["pair"]
                    if pair in connectedClients.keys():
                        broadcastToClients(pair, jsonTickData)
            repeatativeEmpty = repeatativeEmpty + 1 if len(data) == 0 else 0
            if repeatativeEmpty > 10:
                print(f"data is not recieved for 10 times in a row {data}")
                break
        except Exception as ex:
            print(f"error in processing mt5 data {ex}")
            break
        time.sleep(0.1)
    acceptFromMt5()
    
def acceptFromClients():
    try: 
        while True:
            print("Server is listening for clients")
            client, address = clientSocket.accept()
            pair = client.recv(7).decode("ascii")
            print(f"{pair} client service is connected at {str(address)}")
            clients = connectedClients[pair] if connectedClients and pair in connectedClients.keys() else []
            clients.append(client)
            connectedClients[pair] = clients
    except Exception as ex:
        print(f"error in accepting other clients {ex}")
        acceptFromClients()
    
def acceptFromMt5():
    try: 
        print("Server is listening for mt5")
        mt5Client, address = mt5Socket.accept()
        print(f"mt5 service is connected at {str(address)}")
        processMt5Data(mt5Client)
    except Exception as ex:
        print(f"error in accepting mt5 client {ex}")
        acceptFromMt5()

if __name__ == "__main__":
    thread = threading.Thread(target=acceptFromMt5)
    thread.start()
    thread = threading.Thread(target=acceptFromClients)
    thread.start()