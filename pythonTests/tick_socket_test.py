import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

currencyPair = ["EURUSD", "AUDUSD"]

if __name__ == "__main__":
    sys.path.insert(1, os.getcwd()+"/helpers/")
    from client_socket_helper import ClientSocketHelper
    tickHelp = ClientSocketHelper()
    tickHelp.setTimeout(3)
    while True:
        for cp in currencyPair:
            tickData = tickHelp.getTickData(cp)
            if tickData is not None:
                print(tickData)
            if tickData is None:
                print("timeout occured retrying for {}".format(cp))