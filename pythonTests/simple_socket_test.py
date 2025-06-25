import socket

host = "localhost"
port = 9070

if __name__ == "__main__":
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(20)
    text = str(input("mt5 or something else: "))
    if sock.connect_ex((host, port)) != 0 :
        sock.close()
    else:
        while(len(text) > 0):
            sock.send(text.encode('ascii'))
            text = str(input("enter something : "))