#!/bin/bash

# Base directories for searching
BASE_DIRS=("$HOME/storage/music/termux" "$HOME/storage/movies/termux")

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

# Display compressed files for user selection
select_compressed_file() {
    log "Listing available compressed files..."
    local files=()
    for base_dir in "${BASE_DIRS[@]}"; do
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find "$base_dir" -type f \( -name "*.zip" -o -name "*.tar.gz" -o -name "*.7z" \) -print0)
    done

    echo "Select a file to decompress:"
    for i in "${!files[@]}"; do
        echo "$((i + 1))) ${files[i]}"
    done

    read -rp "Enter the number of your choice: " choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#files[@]})); then
        handle_error "Invalid selection. Please run the script again."
    fi

    SELECTED_FILE="${files[$((choice - 1))]}"
    log "Selected file: $SELECTED_FILE"
}

# Decompress the selected file
decompress_file() {
    log "Decompressing $SELECTED_FILE..."

    case "$SELECTED_FILE" in
        *.zip)
            unzip "$SELECTED_FILE" -d "$(dirname "$SELECTED_FILE")" || handle_error "Failed to decompress $SELECTED_FILE"
            ;;
        *.tar.gz)
            tar -xzf "$SELECTED_FILE" -C "$(dirname "$SELECTED_FILE")" || handle_error "Failed to decompress $SELECTED_FILE"
            ;;
        *.7z)
            7z x "$SELECTED_FILE" -o"$(dirname "$SELECTED_FILE")" || handle_error "Failed to decompress $SELECTED_FILE"
            ;;
        *)
            handle_error "Unsupported compression format for $SELECTED_FILE"
            ;;
    esac

    rm "$SELECTED_FILE" || handle_error "Failed to remove $SELECTED_FILE after decompression"
    log "Decompression of $SELECTED_FILE completed."
}

# Main script execution
main() {
    LOGFILE="$HOME/decompressX.log"

    log "Starting decompression script..."
    check_dependencies
    select_compressed_file
    decompress_file

    log "Script completed successfully."
}

main "$@"