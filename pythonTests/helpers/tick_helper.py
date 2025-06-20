import socket
from socket import timeout
import json
import sys

SOCKET_TIMEOUT = 20

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

class TickHelper:
    def __init__(self):
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
            sock.bind(("127.0.0.1", CURRENCYPAIR_PORT[key]))
            sock.listen()
            self.sockets[key] = sock
            self.bid[key] = 0
            self.prevBid[key] = 0
            self.ask[key] = 0
            self.prevAsk[key] = 0
            self.resetMaxMinBids(key)

    def setTimeout(self, timeout):
        self.timeout = timeout

    def getTickData(self, currencyPair):
        try:
            print("Waiting for connection on port {}".format(CURRENCYPAIR_PORT[currencyPair]))
            self.sockets[currencyPair].settimeout(self.timeout)
            conn, addr = self.sockets[currencyPair].accept()
            print("Connection from: " + str(addr))
            while True:
                try:
                    data = conn.recv(200)
                    if not data: 
                        break
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
                    break
        except timeout:
            return None

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
