import sys
import os
import socket
import threading

host = "localhost"
ports = [9070, 9071]
threads = {}

def sockListen(host, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.bind((host, port))
    sock.listen()
    return sock

def recvUntilClose(sock):
    client, address = sock.accept()
    text = client.recv(40).decode("ascii")
    repeatativeEmpty = 0
    while(len(text) > 0 or text != "close"):
        print("thread {} and client {} sent {}".format(threading.current_thread().name, client.getsockname(), text))
        try:
            text = client.recv(40).decode("ascii")
            repeatativeEmpty = repeatativeEmpty + 1 if len(text) == 0 else 0
            if repeatativeEmpty > 10:
                break
        except Exception as ex:
            print(ex)
            break
    client.close()
    recvUntilClose(sock)
    
def __del__():
    for key in thread.keys():
        threads[key].join()

if __name__ == "__main__":
    for port in ports:
        sock = sockListen(host, port)
        thread = threading.Thread(target=recvUntilClose, args=(sock,), name=port)
        thread.start()
        threads[port] = thread
        print("Server on port {} is listening....".format(port))
    