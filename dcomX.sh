#!/bin/bash

# Base directory for your files
BASE_DIR="$HOME/storage/music/termux"

# Function to log messages
log() {
    if [ -z "$LOGFILE" ]; then
        echo "ERROR: LOGFILE variable is not set."
        exit 1
    fi
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOGFILE"
}

# Error handler
handle_error() {
    log "ERROR: $1"
    exit 1
}

# Check dependencies
check_dependencies() {
    log "Checking for required dependencies..."
    for tool in unzip tar 7z; do
        if ! command -v "$tool" &>/dev/null; then
            log "$tool is not installed. Installing..."
            case "$tool" in
                7z)
                    pkg install p7zip -y || handle_error "Failed to install $tool (use 'pkg install p7zip-full' if necessary)."
                    ;;
                *)
                    pkg install "$tool" -y || handle_error "Failed to install $tool"
                    ;;
            esac
        else
            log "$tool is already installed."
        fi
    done
}

# Display directories for user selection
select_directory() {
    log "Listing available directories..."
    local dirs=()
    while IFS= read -r -d '' dir; do
        dirs+=("$dir")
    done < <(find "$BASE_DIR" -type d -print0)

    echo "Select a directory to decompress:"
    for i in "${!dirs[@]}"; do
        echo "$((i + 1))) ${dirs[i]}"
    done

    read -rp "Enter the number of your choice: " choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#dirs[@]})); then
        handle_error "Invalid selection. Please run the script again."
    fi

    SELECTED_DIR="${dirs[$((choice - 1))]}"
    log "Selected directory: $SELECTED_DIR"
}

# Decompress files in the selected directory and subdirectories
decompress_files() {
    log "Searching for compressed files in $SELECTED_DIR and subdirectories..."

    find "$SELECTED_DIR" -type f \( -name "*.zip" -o -name "*.tar.gz" -o -name "*.7z" \) | while read -r file; do
        log "Found compressed file: $file. Decompressing..."
        case "$file" in
            *.zip)
                unzip "$file" -d "$(dirname "$file")" || handle_error "Failed to decompress $file"
                ;;
            *.tar.gz)
                tar -xzf "$file" -C "$(dirname "$file")" || handle_error "Failed to decompress $file"
                ;;
            *.7z)
                7z x "$file" -o"$(dirname "$file")" || handle_error "Failed to decompress $file"
                ;;
            *)
                handle_error "Unsupported compression format for $file"
                ;;
        esac
        rm "$file" || handle_error "Failed to remove $file after decompression"
        log "Decompression of $file completed."
    done
}

# Main script execution
main() {
    LOGFILE="$BASE_DIR/decompressX.log"

    log "Starting decompression script..."
    check_dependencies
    select_directory
    decompress_files

    log "Script completed successfully."
}

main "$@"