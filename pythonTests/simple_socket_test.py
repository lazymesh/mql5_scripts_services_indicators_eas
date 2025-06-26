import socket
import threading

server = "localhost"

def sockInit():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(20)
    return sock
        
def connectAndSend(sock, host, port):
    if sock.connect_ex((host, port)) != 0:
        sock.close()
    strInput = "write something to send to the server on port {} : ".format(port)
    text = str(input(strInput))
    while(text != "close"):
        sock.send(text.encode('ascii'))
        text = str(input("type 'close' to close the connection "))
    sock.close()
    
    
if __name__ == "__main__":
    port = input("enter a port to connect to server : ")
    sock = sockInit()
    thread = threading.Thread(target=connectAndSend, args=(sock, server, int(port)))
    thread.start()
    