import socket
import threading
import os
import sqlite3
from datetime import datetime

# Constants
BUFFER_SIZE = 1024
HOST = '0.0.0.0'
PORT = 12345
clients = {}
groups = {}

# Database setup
conn = sqlite3.connect('messenger.db', check_same_thread=False)
c = conn.cursor()

# Create tables
c.execute('''
CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_name TEXT,
    sender TEXT,
    message TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
)
''')

c.execute('''
CREATE TABLE IF NOT EXISTS files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_name TEXT,
    sender TEXT,
    file_name TEXT,
    file_path TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
)
''')

conn.commit()

# Server-Side Functions
def broadcast_to_group(group_name, message, sender=None):
    if group_name in groups:
        # Store message in database
        c.execute('INSERT INTO messages (group_name, sender, message) VALUES (?, ?, ?)', 
                  (group_name, clients[sender]['nickname'], message.decode('utf-8')))
        conn.commit()
        
        for client_socket in groups[group_name]:
            if client_socket != sender:
                try:
                    client_socket.send(message)
                except:
                    pass

def handle_client(client_socket, address):
    print(f"Client connected: {address}")
    clients[client_socket] = {"nickname": None, "address": f"{address[0]}:{address[1]}"}
    client_socket.send(b"Welcome! Type /help for commands.")
    
    current_group = None
    
    while True:
        try:
            data = client_socket.recv(BUFFER_SIZE)
            if not data:
                break

            command = data.decode('utf-8').strip()
            if command.startswith("/join"):
                group_name = command.split(" ", 1)[1] if " " in command else None
                if not group_name:
                    client_socket.send(b"Usage: /join <group_name>")
                    continue
                if group_name not in groups:
                    groups[group_name] = []
                groups[group_name].append(client_socket)
                current_group = group_name
                client_socket.send(f"Joined group {group_name}".encode('utf-8'))
            elif command == "/leave":
                if current_group and client_socket in groups.get(current_group, []):
                    groups[current_group].remove(client_socket)
                    client_socket.send(f"Left group {current_group}".encode('utf-8'))
                    current_group = None
                else:
                    client_socket.send(b"You are not in any group.")
            elif command.startswith("/sendfile"):
                group_name = command.split(" ", 1)[1] if " " in command else None
                if not group_name or group_name not in groups:
                    client_socket.send(b"Usage: /sendfile <group_name>")
                    continue
                client_socket.send(b"Send the file now.")
                file_name = f"received_{group_name}_{clients[client_socket]['nickname']}_{datetime.now().strftime('%Y%m%d%H%M%S')}.bin"
                with open(file_name, 'wb') as file:
                    while True:
                        chunk = client_socket.recv(BUFFER_SIZE)
                        if not chunk:
                            break
                        file.write(chunk)
                broadcast_to_group(group_name, f"File received: {file_name}".encode('utf-8'), sender=client_socket)
            elif command == "/help":
                help_message = (
                    "/join <group_name> - Join a group\n"
                    "/leave - Leave the current group\n"
                    "/sendfile <group_name> - Send a file to a group\n"
                    "/help - Show this help menu\n"
                )
                client_socket.send(help_message.encode('utf-8'))
            else:
                if current_group:
                    nickname = clients[client_socket].get("nickname", "Anonymous")
                    message = f"{nickname} says - {command}"
                    broadcast_to_group(current_group, message.encode('utf-8'), sender=client_socket)
                else:
                    client_socket.send(b"You are not in any group. Use /join to join a group.")
        except Exception as e:
            print(f"Error: {e}")
            break

    print(f"Client disconnected: {address}")
    if current_group and client_socket in groups.get(current_group, []):
        groups[current_group].remove(client_socket)
    client_socket.close()

# Server Setup
def start_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((HOST, PORT))
    server_socket.listen(5)
    print(f"Server started on {HOST}:{PORT}")

    while True:
        client_socket, address = server_socket.accept()
        threading.Thread(target=handle_client, args=(client_socket, address), daemon=True).start()

# Client-Side Functions
def client_menu(client_socket, nickname):
    while True:
        print("\nChoose an action:")
        print("1. Join a group")
        print("2. Leave a group")
        print("3. Send a message")
        print("4. Send a file")
        print("5. Help")
        print("6. Exit")
        
        choice = input("Enter your choice: ").strip()
        if choice == "1":
            group_name = input("Enter group name: ").strip()
            client_socket.send(f"/join {group_name}".encode('utf-8'))
        elif choice == "2":
            client_socket.send(b"/leave")
        elif choice == "3":
            message = input(f"Enter your message ({nickname}): ").strip()
            if message:
                client_socket.send(f"{nickname} says - {message}".encode('utf-8'))
        elif choice == "4":
            group_name = input("Enter group name for file: ").strip()
            send_file(client_socket, group_name)
        elif choice == "5":
            client_socket.send(b"/help")
        elif choice == "6":
            print("Exiting...")
            break
        else:
            print("Invalid choice. Try again.")

def send_file(client_socket, group_name):
    try:
        file_path = input("Enter the file path to send: ").strip()
        if not os.path.exists(file_path):
            print("File not found!")
            return

        with open(file_path, 'rb') as file:
            data = file.read()
            client_socket.send(f"/sendfile {group_name}".encode('utf-8'))
            client_socket.send(data)
            print(f"Sent file {file_path} to group {group_name}")
    except Exception as e:
        print(f"Error sending file: {e}")

def receive_messages(client_socket, nickname):
    while True:
        try:
            data = client_socket.recv(BUFFER_SIZE)
            if not data:
                break
            print(f"\n{data.decode('utf-8')}")
        except Exception as e:
            print(f"Error receiving messages: {e}")
            break

def join_server(host, port):
    try:
        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_socket.connect((host, port))
        nickname = input("Enter your nickname: ").strip()
        clients[client_socket] = {"nickname": nickname}
        threading.Thread(target=receive_messages, args=(client_socket, nickname), daemon=True).start()
        client_menu(client_socket, nickname)
    except Exception as e:
        print(f"Failed to connect to the server: {e}")

# Main Function
if __name__ == "__main__":
    choice = input("Would you like to (h)ost or (j)oin? ").strip().lower()

    if choice == "h":
        start_server()
    elif choice == "j":
        host = input("Enter the server IP address: ").strip()
        port = int(input("Enter the server port: ").strip())
        join_server(host, port)
    else:
        print("Invalid option.")