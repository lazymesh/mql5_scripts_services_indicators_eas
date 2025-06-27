import socket

CURRENCY_PAIRS = [
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
    "NZDCHF"
]

server = "127.0.0.1"
port = 9071

def receiveData(client):
    repeatativeEmpty = 0
    while True:
        data = client.recv(1024).decode("ascii")
        print("data received ", data)
        repeatativeEmpty = repeatativeEmpty + 1 if len(data) == 0 else 0
        if repeatativeEmpty > 10:
            print(f"data is not recieved for 10 times in a row {data}")
            break

if __name__ == "__main__":
    print(f"please choose from the currency pairs given below as name \n {', '.join(CURRENCY_PAIRS)}")
    name = input("enter the name for the client : ")
    if name in CURRENCY_PAIRS:
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        if client.connect_ex((server, port)) == 0:
            client.send(name.encode("ascii"))
            receiveData(client)
        else: 
            print("server could not be connected.")
    else: 
        print("you didn't choose from the above list")