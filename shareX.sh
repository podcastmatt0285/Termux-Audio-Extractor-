#!/bin/bash

SHARED_DIR=~/storage/shared/termux
PORT=8022
USERNAME="u0_a"
PASSWORD="YourSecurePassword"

# Function to check and install dependencies
check_and_install_dependencies() {
    pkg update
    pkg install openssh termux-api jq nmap -y
}

# Function to initialize shared directory
initialize_shared_dir() {
    if [ ! -d "$SHARED_DIR" ]; then
        mkdir -p "$SHARED_DIR"
        echo "Created shared directory: $SHARED_DIR"
    else
        echo "Using existing shared directory: $SHARED_DIR"
    fi
}

# Function to start SSH server
start_ssh_server() {
    sshd
    HOST_IP=$(termux-wifi-connectioninfo | jq -r '.ip')
    if [ -z "$HOST_IP" ]; then
        echo "Failed to get IP address. Please ensure Wi-Fi is enabled."
        exit 1
    fi
    echo "SSH server started. Connect using 'ssh $USERNAME@$HOST_IP -p $PORT'"
    echo "Host IP: $HOST_IP"
}

# Function to set up SSH key-based authentication on the host
setup_host_ssh_keys() {
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
    fi
    mkdir -p ~/.ssh
    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    echo "SSH key-based authentication set up on host."
}

# Function to set password for SSH user
set_ssh_password() {
    echo -e "$PASSWORD\n$PASSWORD" | passwd
}

# Function to host a shareable directory
host_directory() {
    initialize_shared_dir
    start_ssh_server
    setup_host_ssh_keys
    set_ssh_password
    HOST_IP=$(termux-wifi-connectioninfo | jq -r '.ip')
    if [ -z "$HOST_IP" ]; then
        echo "Failed to get IP address. Please ensure Wi-Fi is enabled."
        exit 1
    fi
    echo "Hosting shareable directory. Other users can join using IP: $HOST_IP"
    echo "Connect with username '$USERNAME' and password '$PASSWORD'"
}

# Function to discover available hosts
discover_hosts() {
    echo "Checking for available hosts using nmap..."
    NETWORK_SUBNET=$(termux-wifi-connectioninfo | jq -r '.ip' | cut -d'.' -f1-3).0/24
    HOSTS=($(nmap -p 8022 --open -oG - $NETWORK_SUBNET | awk '/Ports: 8022\/open/ {print $2}'))

    if [ ${#HOSTS[@]} -gt 0 ]; then
        echo "Available hosts:"
        for i in "${!HOSTS[@]}"; do
            echo "$((i + 1)). ${HOSTS[$i]}"
        done
    else
        echo "No available hosts found."
    fi
}

# Function to join a host's shareable directory
join_host() {
    discover_hosts
    if [ ${#HOSTS[@]} -gt 0 ]; then
        echo "Enter the number of the host you want to join:"
        read -r SELECTION
        if [[ "$SELECTION" -ge 1 && "$SELECTION" -le ${#HOSTS[@]} ]]; then
            HOST_IP="${HOSTS[$((SELECTION - 1))]}"
            echo "Joined host $HOST_IP. You can now access their shareable directory via SSH."

            # Ensure SSH key-based authentication
            setup_joiner_ssh_keys
            ssh-copy-id -p $PORT $USERNAME@$HOST_IP
        else
            echo "Invalid selection. Exiting."
            exit 1
        fi
    else
        echo "No available hosts to join. Exiting."
        exit 1
    fi
}

# Function to search for compressed files
search_files() {
    echo "Searching for compressed files in movies and music directories..."
    SEARCH_DIRS=("$HOME/storage/movies/termux" "$HOME/storage/music/termux")
    FILES=()
    for dir in "${SEARCH_DIRS[@]}"; do
        echo "Checking directory: $dir"
        if [ -d "$dir" ]; then
            while IFS= read -r -d '' file; do
                FILES+=("$file")
            done < <(find "$dir" -type f \( -name "*.zip" -o -name "*.tar.gz" -o -name "*.7z" \) -print0)
        else
            echo "Directory $dir does not exist."
        fi
    done
    echo "Files found: ${FILES[@]}"
}

# Function to upload a file
upload_file() {
    search_files
    if [ ${#FILES[@]} -eq 0 ]; then
        echo "No compressed files found in the specified directories."
        return
    fi
    echo "Found the following files:"
    for i in "${!FILES[@]}"; do
        echo "$((i + 1)). ${FILES[$i]}"
    done

    echo "Enter the number of the file you want to upload:"
    read -r SELECTION
    if [[ "$SELECTION" -ge 1 && "$SELECTION" -le ${#FILES[@]} ]]; then
        SELECTED_FILE="${FILES[$((SELECTION - 1))]}"
        scp -P $PORT "$SELECTED_FILE" "$USERNAME@$HOST_IP:$SHARED_DIR"
        if [ $? -eq 0 ]; then
            echo "File uploaded to shared directory: $SHARED_DIR"
        else
            echo "Failed to upload file. Ensure SSH server is running and accessible."
        fi
    else
        echo "Invalid selection. Exiting."
        exit 1
    fi
}

# Function to list and download files
download_file() {
    ssh -p $PORT "$USERNAME@$HOST_IP" "ls $SHARED_DIR"
    echo "Files available for download:"
    FILES=($(ssh -p $PORT "$USERNAME@$HOST_IP" "ls $SHARED_DIR"))
    if [ ${#FILES[@]} -eq 0 ]; then
        echo "No files available for download."
        return
    fi
    for i in "${!FILES[@]}"; do
        FILE_NAME=$(basename "${FILES[$i]}")
        echo "$((i + 1)). $FILE_NAME"
    done

    echo "Enter the number of the file you want to download:"
    read -r SELECTION
    if [[ "$SELECTION" -ge 1 && "$SELECTION" -le ${#FILES[@]} ]]; then
        SELECTED_FILE="${FILES[$((SELECTION - 1))]}"
        scp -P $PORT "$USERNAME@$HOST_IP:$SHARED_DIR/$SELECTED_FILE" .
        if [ $? -eq 0 ]; then
            echo "File downloaded to current directory: $(pwd)"
        else
            echo "Failed to download file. Ensure SSH server is running and accessible."
        fi
    else
        echo "Invalid selection. Exiting."
        exit 1
    fi
}

# Main Execution Loop
check_and_install_dependencies
while true; do
    echo "Would you like to host or join a host? (host/join)"
    read -r HOST_ACTION
    case "$HOST_ACTION" in
        host)
            host_directory
            ;;
        join)
            join_host
            ;;
        *)
            echo "Invalid option. Please enter 'host' or 'join'."
            continue
            ;;
    esac

    echo "Would you like to upload or download a file? (upload/download/exit)"
    read -r ACTION
    case "$ACTION" in
        upload)
            upload_file
            ;;
        download)
            download_file
            ;;
        exit)
            echo "Exiting script. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please enter 'upload', 'download', or 'exit'."
            ;;
    esac
done