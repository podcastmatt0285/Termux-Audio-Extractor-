#!/bin/bash

SHARED_DIR=~/storage/shared/termux
HOST_FILE=~/termux_hosts.txt
CURRENT_HOST=""

# Function to initialize shared directory
initialize_shared_dir() {
    if [ ! -d "$SHARED_DIR" ]; then
        mkdir -p "$SHARED_DIR"
        echo "Created shared directory: $SHARED_DIR"
    else
        echo "Using existing shared directory: $SHARED_DIR"
    fi
}

# Function to host a shareable directory
host_directory() {
    initialize_shared_dir
    HOST_IP=$(termux-wifi-connectioninfo | jq -r .ip)
    CURRENT_HOST="$HOST_IP"
    echo "$HOST_IP:$SHARED_DIR" >> "$HOST_FILE"
    echo "Hosting shareable directory. Other users can join using IP: $HOST_IP"
}

# Function to list available hosts
list_hosts() {
    if [ -f "$HOST_FILE" ]; then
        echo "Available hosts:"
        while IFS= read -r line; do
            echo "$line"
        done < "$HOST_FILE"
    else
        echo "No hosts currently available."
    fi
}

# Function to join a host's shareable directory
join_host() {
    list_hosts
    echo "Enter the IP of the host you want to join:"
    read -r HOST_IP
    CURRENT_HOST="$HOST_IP"
    echo "Joined host $HOST_IP. You can now access their shareable directory."
}

# Function to search for compressed files
search_files() {
    echo "Searching for compressed files in movies and music directories..."
    SEARCH_DIRS=("$HOME/storage/movies/termux" "$HOME/storage/music/termux")
    FILES=()
    for dir in "${SEARCH_DIRS[@]}"; do
        echo "Checking directory: $dir"  # Debug line
        if [ -d "$dir" ]; then
            while IFS= read -r -d '' file; do
                echo "Found file: $file"  # Debug line
                FILES+=("$file")
            done < <(find "$dir" -type f \( -name "*.zip" -o -name "*.tar.gz" -o -name "*.7z" \) -print0)
        else
            echo "Directory $dir does not exist."  # Debug line
        fi
    done
    echo "Files found: ${FILES[@]}"  # Debug line
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
        cp "$SELECTED_FILE" "$SHARED_DIR"
        echo "File uploaded to shared directory: $SHARED_DIR"
    else
        echo "Invalid selection. Exiting."
        exit 1
    fi
}

# Function to list and download files
download_file() {
    echo "Files available for download:"
    FILES=("$SHARED_DIR"/*)
    if [ ${#FILES[@]} -eq 0 ]; then
        echo "No files available for download."
        return
    fi
    for i in "${!FILES[@]}"; do
        echo "$((i + 1)). ${FILES[$i]}"
    done

    echo "Enter the number of the file you want to download:"
    read -r SELECTION
    if [[ "$SELECTION" -ge 1 && "$SELECTION" -le ${#FILES[@]} ]]; then
        SELECTED_FILE="${FILES[$((SELECTION - 1))]}"
        cp "$SELECTED_FILE" .
        echo "File downloaded to current directory: $(pwd)"
    else
        echo "Invalid selection. Exiting."
        exit 1
    fi
}

# Main Execution Loop
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