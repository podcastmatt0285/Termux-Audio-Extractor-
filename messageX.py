import socket
import threading
import os
from datetime import datetime

# Constants
BUFFER_SIZE = 4096
DEFAULT_PORT = 12345

# Groups and Clients
groups = {}
clients = {}

# Server Functions
def broadcast_to_group(group_name, message, sender=None):
    for client in groups.get(group_name, []):
        if client != sender:
            try:
                client.send(message)
            except:
                print(f"Client {clients.get(client)} disconnected.")
                groups[group_name].remove(client)

def handle_client(client_socket, address):
    print(f"Client connected: {address}")
    clients[client_socket] = f"{address[0]}:{address[1]}"
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
                file_name = f"received_{group_name}_{clients[client_socket]}_{datetime.now().strftime('%Y%m%d%H%M%S')}.bin"
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
                    broadcast_to_group(current_group, f"{clients[client_socket]}: {command}".encode('utf-8'), sender=client_socket)
                else:
                    client_socket.send(b"You are not in any group. Use /join to join a group.")
        except Exception as e:
            print(f"Error: {e}")
            break

    print(f"Client disconnected: {address}")
    if current_group and client_socket in groups.get(current_group, []):
        groups[current_group].remove(client_socket)
    client_socket.close()

def start_server(port):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('', port))
    server_socket.listen(5)
    print(f"Server started on port {port}. Waiting for connections...")

    while True:
        client_socket, address = server_socket.accept()
        threading.Thread(target=handle_client, args=(client_socket, address)).start()

# Client Functions
def send_file(client_socket, group_name):
    file_path = input("Enter the path of the file to send: ").strip()
    if not os.path.exists(file_path):
        print("File not found.")
        return
    client_socket.send(f"/sendfile {group_name}".encode('utf-8'))
    response = client_socket.recv(BUFFER_SIZE)
    if b"Send the file now" in response:
        with open(file_path, 'rb') as file:
            while chunk := file.read(BUFFER_SIZE):
                client_socket.send(chunk)
        print("File sent successfully.")

def client_menu(client_socket):
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
            message = input("Enter your message: ").strip()
            client_socket.send(message.encode('utf-8'))
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

def join_server(host, port):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((host, port))
    threading.Thread(target=receive_messages, args=(client_socket,), daemon=True).start()
    client_menu(client_socket)

def receive_messages(client_socket):
    while True:
        try:
            data = client_socket.recv(BUFFER_SIZE)
            if not data:
                break
            print(data.decode('utf-8'))
        except:
            break

# Main Function
def main():
    print("Welcome to Termux Messenger!")
    print("1. Host a server")
    print("2. Join a server")
    choice = input("Enter your choice: ").strip()

    if choice == "1":
        port = input(f"Enter port (default {DEFAULT_PORT}): ").strip()
        port = int(port) if port else DEFAULT_PORT
        start_server(port)
    elif choice == "2":
        host = input("Enter server IP: ").strip()
        port = input(f"Enter server port (default {DEFAULT_PORT}): ").strip()
        port = int(port) if port else DEFAULT_PORT
        join_server(host, port)
    else:
        print("Invalid choice. Exiting.")

if __name__ == "__main__":
    main()