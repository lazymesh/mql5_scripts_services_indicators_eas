import socket
from socket import timeout
import json
import sys

SOCKET_TIMEOUT = 20

CURRENCYPAIR_PORT = {
    
    "EURUSD": 9078
}

class TickHelper:
    def __init__(self, isClient = False):
        self.isClient = isClient
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
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            if self.isClient :
                sock.connect(("127.0.0.1", CURRENCYPAIR_PORT[key]))
                print("client is connected")
                sock.send("client".encode('ascii'))
            else :
                sock.bind(("127.0.0.1", CURRENCYPAIR_PORT[key]))
                sock.listen()
                print('Server is listening')
                self.conn, self.addr = sock.accept()
                print("Connection from: " + str(self.addr))
            self.sockets[key] = sock
            self.bid[key] = 0
            self.prevBid[key] = 0
            self.ask[key] = 0
            self.prevAsk[key] = 0
            self.resetMaxMinBids(key)
            sock.settimeout(self.timeout)

    def setTimeout(self, timeout):
        self.timeout = timeout

    def getTickData(self, currencyPair):
        try:
            if self.isClient: 
                data = self.sockets[currencyPair].recv(1024)
            else:
                data = self.conn.recv(200)
            if not data: 
                return json.loads("data hasn't arrived yet")
            tickData = data.decode("utf-8")
            jsonTickData = json.loads(tickData)
            self.prevBid[currencyPair] = self.bid[currencyPair]
            self.bid[currencyPair] = jsonTickData["bid"]
            self.prevAsk[currencyPair] = self.ask[currencyPair]
            self.ask[currencyPair] = jsonTickData["ask"]
            self.maxBid[currencyPair] = self.bid[currencyPair] if self.bid[currencyPair] > self.maxBid[currencyPair] else self.maxBid[currencyPair]
            self.minBid[currencyPair] = self.bid[currencyPair] if self.bid[currencyPair] < self.minBid[currencyPair] else self.minBid[currencyPair]
            self.maxAsk[currencyPair] = self.ask[currencyPair] if self.ask[currencyPair] > self.maxAsk[currencyPair] else self.maxAsk[currencyPair]
            return jsonTickData
        except Exception as ex:
            print(f"issue with socket connection in mt5. {ex} retrying...")

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
