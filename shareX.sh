#!/data/data/com.termux/files/usr/bin/bash

# Function: Start SSH server
function start_ssh_server() {
    echo "Starting SSH server..."
    sshd
    if [ $? -eq 0 ]; then
        echo "SSH server started successfully."
    else
        echo "Failed to start SSH server. Check your setup."
        exit 1
    fi
}

# Function: Display connection information
function display_connection_info() {
    IP=$(ifconfig wlan0 | grep 'inet ' | awk '{print $2}')
    PORT=$(cat $PREFIX/etc/ssh/sshd_config | grep '^Port ' | awk '{print $2}')
    USER=$(whoami)
    if [ -z "$IP" ]; then
        echo "Could not retrieve IP address. Ensure you're connected to Wi-Fi."
        exit 1
    fi
    echo "Your device is ready for SSH connections."
    echo "SSH Command: ssh -p $PORT $USER@$IP"
}

# Function: Set up shared directory
function setup_shared_directory() {
    echo "Enter the directory you want to share (default: ~/shared):"
    read -r SHARED_DIR
    SHARED_DIR=${SHARED_DIR:-~/shared}
    
    mkdir -p "$SHARED_DIR"
    chmod -R 755 "$SHARED_DIR"
    echo "Directory '$SHARED_DIR' is now shared via SSH."
}

# Function: Stop SSH server
function stop_ssh_server() {
    echo "Stopping SSH server..."
    pkill sshd
    if [ $? -eq 0 ]; then
        echo "SSH server stopped successfully."
    else
        echo "SSH server is not running."
    fi
}

# Main Execution Flow
echo "==== Termux File Sharing Script ===="
PS3="Select an option: "
options=("Start SSH server" "Display connection info" "Share a directory" "Stop SSH server" "Exit")
select opt in "${options[@]}"; do
    case $opt in
        "Start SSH server")
            start_ssh_server
            ;;
        "Display connection info")
            display_connection_info
            ;;
        "Share a directory")
            setup_shared_directory
            ;;
        "Stop SSH server")
            stop_ssh_server
            ;;
        "Exit")
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
