import socket
import threading
import sys

def handle_client(client_socket):
    """Handles communication with a connected client."""
    try:
        while True:
            message = client_socket.recv(1024).decode('utf-8')
            if not message:
                break
            print(f"Client: {message}")
            reply = input("Reply: ")
            client_socket.send(reply.encode('utf-8'))
    except ConnectionResetError:
        print("Client disconnected.")
    finally:
        client_socket.close()

def start_server():
    """Starts the server to listen for incoming connections."""
    try:
        port = int(input("Enter port to run the server on (default: 5555): ") or 5555)
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.bind(('0.0.0.0', port))
        server.listen(5)
        print(f"Server started on port {port}, waiting for connections...")
        
        def shutdown_server():
            """Gracefully shuts down the server."""
            print("\nShutting down the server...")
            server.close()
            sys.exit(0)

        threading.Thread(target=lambda: input("\nPress Enter to stop the server.\n") or shutdown_server(), daemon=True).start()

        while True:
            try:
                client_socket, addr = server.accept()
                print(f"Connection from {addr}")
                threading.Thread(target=handle_client, args=(client_socket,)).start()
            except OSError:
                break
    except Exception as e:
        print(f"Server error: {e}")

def start_client():
    """Connects to the server as a client."""
    try:
        server_ip = input("Enter server IP (default: 127.0.0.1): ") or "127.0.0.1"
        port = int(input("Enter server port (default: 5555): ") or 5555)
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client.connect((server_ip, port))
        print("Connected to the server.")
        
        def receive_messages():
            """Receives messages from the server."""
            try:
                while True:
                    message = client.recv(1024).decode('utf-8')
                    if not message:
                        break
                    print(f"Server: {message}")
            except ConnectionResetError:
                print("Server disconnected.")
            finally:
                client.close()

        threading.Thread(target=receive_messages, daemon=True).start()

        while True:
            message = input("You: ")
            if not message:
                break
            client.send(message.encode('utf-8'))
        client.close()
    except Exception as e:
        print(f"Client error: {e}")

if __name__ == "__main__":
    print("Choose mode:")
    print("1. Server")
    print("2. Client")
    choice = input("Enter choice: ")

    if choice == "1":
        start_server()
    elif choice == "2":
        start_client()
    else:
        print("Invalid choice. Exiting.")