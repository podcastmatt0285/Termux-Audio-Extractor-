import socket
import threading

# Constants
BUFFER_SIZE = 1024
PORT = 12345
clients = {}
groups = {}

# Server Functions
def broadcast_to_group(group_name, message, sender=None):
    for client_socket in groups.get(group_name, []):
        if client_socket != sender:
            try:
                client_socket.send(message.encode('utf-8'))
            except:
                clients.pop(client_socket, None)
                groups[group_name].remove(client_socket)

def handle_client(client_socket):
    nickname = client_socket.recv(BUFFER_SIZE).decode('utf-8')
    clients[client_socket] = nickname

    while True:
        try:
            data = client_socket.recv(BUFFER_SIZE).decode('utf-8')
            if data:
                if data.startswith("/join"):
                    group_name = data.split(" ", 1)[1]
                    if group_name not in groups:
                        groups[group_name] = []
                    groups[group_name].append(client_socket)
                    broadcast_to_group(group_name, f"{nickname} has joined the group.")
                elif data.startswith("/leave"):
                    group_name = data.split(" ", 1)[1]
                    if group_name in groups and client_socket in groups[group_name]:
                        groups[group_name].remove(client_socket)
                        broadcast_to_group(group_name, f"{nickname} has left the group.")
                else:
                    group_name, message = data.split(" ", 1)
                    broadcast_to_group(group_name, f"{nickname}: {message}")
        except:
            client_socket.close()
            clients.pop(client_socket, None)
            break

def start_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('0.0.0.0', PORT))
    server_socket.listen(5)
    print(f"Server started on port {PORT}")

    while True:
        client_socket, _ = server_socket.accept()
        threading.Thread(target=handle_client, args=(client_socket,)).start()

def receive_messages(client_socket):
    while True:
        try:
            data = client_socket.recv(BUFFER_SIZE).decode('utf-8')
            if data:
                print(data)
        except:
            break

def start_client(server_ip, nickname):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((server_ip, PORT))
    client_socket.send(nickname.encode('utf-8'))

    threading.Thread(target=receive_messages, args=(client_socket,), daemon=True).start()

    while True:
        command = input()
        if command:
            client_socket.send(command.encode('utf-8'))

if __name__ == "__main__":
    choice = input("Enter (s) to start a server or (j) to join a server: ").strip().lower()

    if choice == "s":
        start_server()
    elif choice == "j":
        server_ip = input("Enter server IP: ").strip()
        nickname = input("Enter your nickname: ").strip()
        start_client(server_ip, nickname)
    else:
        print("Invalid choice")