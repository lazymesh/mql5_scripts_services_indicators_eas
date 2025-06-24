import socket
from socket import timeout
import json
import sys

CONNECTION_HOST = "127.0.0.1"
CONNECTION_PORT = 80
SOCKET_TIMEOUT = 20

CURRENCYPAIR_PORT = {
    "AUDUSD": 9070,
    "EURUSD": 9078
}

class ClientSocketHelper:
    def __init__(self, host = CONNECTION_HOST, port = CONNECTION_PORT):
        self.host = host
        self.port = port
        self.timeout = SOCKET_TIMEOUT
        self.sockets = {}
        self.bid = {}
        self.prevBid = {}
        self.minBid = {}
        self.maxBid = {}
        self.ask = {}
        self.prevAsk = {}
        self.maxAsk = {}
        for key in CURRENCYPAIR_PORT:
            self.createSocketAndConnect(key)
            self.bid[key] = 0
            self.prevBid[key] = 0
            self.ask[key] = 0
            self.prevAsk[key] = 0
            self.resetMaxMinBids(key)
            
    def createSocketAndConnect(self, currencyPair):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            if sock.connect_ex((self.host, CURRENCYPAIR_PORT[currencyPair])) != 0 :
                sock.close()
            else:
                sock.send("client {}".format(currencyPair).encode('ascii'))
                self.sockets[currencyPair] = sock
        except Exception as ex:
            print("socket for {} could not be connected due to {}".format(currencyPair, ex))
            sock.close()
            

    def setTimeout(self, timeout):
        self.timeout = timeout

    def getTickData(self, currencyPair):
        try:
            if len(self.sockets) > 0:
                data = self.sockets[currencyPair].recv(1024)
                if not data: 
                    return json.loads("data hasn't arrived yet")
                tickData = data.decode("utf-8")
                if "}{" not in tickData:
                    return self.analyzeAndReturnTickData(tickData, currencyPair)
                else :
                    splittedTickData = tickData.split("}{")
                    lastTickData = splittedTickData[len(splittedTickData) - 2]
                    if not lastTickData.startswith("{") :
                        lastTickData = "{" + lastTickData
                    if not lastTickData.endswith("}") :
                        lastTickData = lastTickData +"}"
                    return self.analyzeAndReturnTickData(lastTickData, currencyPair)
                    
            else:
                print(f"{currencyPair} socket is not connected yet")
        except Exception as ex:
            print(f"issue with socket connection in mt5. {ex} retrying...")
            
    def analyzeAndReturnTickData(self, tickData, currencyPair):
        jsonTickData = json.loads(tickData)
        self.prevBid[currencyPair] = self.bid[currencyPair]
        self.bid[currencyPair] = jsonTickData["bid"]
        self.prevAsk[currencyPair] = self.ask[currencyPair]
        self.ask[currencyPair] = jsonTickData["ask"]
        self.maxBid[currencyPair] = self.bid[currencyPair] if self.bid[currencyPair] > self.maxBid[currencyPair] else self.maxBid[currencyPair]
        self.minBid[currencyPair] = self.bid[currencyPair] if self.bid[currencyPair] < self.minBid[currencyPair] else self.minBid[currencyPair]
        self.maxAsk[currencyPair] = self.ask[currencyPair] if self.ask[currencyPair] > self.maxAsk[currencyPair] else self.maxAsk[currencyPair]
        return jsonTickData

    def resetMaxMinBids(self, currencyPair):
        self.maxBid[currencyPair] = -sys.maxsize
        self.minBid[currencyPair] = sys.maxsize
        self.maxAsk[currencyPair] = -sys.maxsize

    def getBid(self, currencyPair):
        return self.bid[currencyPair]

    def getPrevBid(self, currencyPair):
        return self.prevBid[currencyPair]

    def getPrevAsk(self, currencyPair):
        return self.prevAsk[currencyPair]

    def getAsk(self, currencyPair):
        return self.ask[currencyPair]

    def getMaxBid(self, currencyPair):
        return self.maxBid[currencyPair]

    def getMinBid(self, currencyPair):
        return self.minBid[currencyPair]

    def getMaxAsk(self, currencyPair):
        return self.maxAsk[currencyPair]

    def __del__(self):
        for key in CURRENCYPAIR_PORT:
            self.sockets[key].close()
