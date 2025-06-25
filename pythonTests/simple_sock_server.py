import sys
import os
import socket

host = "localhost"
port = 9070

if __name__ == "__main__":
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.bind((host, port))
    sock.listen()
    print("Server is listening....")
    client, address = sock.accept()
    text = client.recv(40).decode("ascii")
    while(len(text) > 0):
        print("client sent : ", text)
        text = client.recv(40).decode("ascii")