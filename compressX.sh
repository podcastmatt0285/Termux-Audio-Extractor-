#!/bin/bash

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
    for tool in zip tar 7z; do
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
    done < <(find ~/storage/music/termux ~/storage/movies/termux -type d -print0)

    echo "Select a directory to compress:"
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

# Decompress existing compressed files if necessary
decompress_if_needed() {
    local compressed_file
    compressed_file=$(find "$SELECTED_DIR" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.tar.gz" -o -name "*.7z" \) | head -n 1)
    if [ -n "$compressed_file" ]; then
        log "Found existing compressed file: $compressed_file. Decompressing..."
        case "$compressed_file" in
            *.zip) unzip "$compressed_file" -d "$SELECTED_DIR" || handle_error "Failed to decompress $compressed_file" ;;
            *.tar.gz) tar -xzf "$compressed_file" -C "$SELECTED_DIR" || handle_error "Failed to decompress $compressed_file" ;;
            *.7z) 7z x "$compressed_file" -o"$SELECTED_DIR" || handle_error "Failed to decompress $compressed_file" ;;
            *) handle_error "Unsupported compression format for $compressed_file" ;;
        esac
        rm "$compressed_file" || handle_error "Failed to remove $compressed_file after decompression"
        log "Decompression completed."
    else
        log "No existing compressed file found in $SELECTED_DIR."
    fi
}

# Perform compression
compress_directory() {
    read -rp "Choose compression format (zip/tar.gz/7z): " format
    read -rp "Choose compression level (low/medium/high): " level

    case "$format" in
        zip) compression_command=("zip" "-r") ;;
        tar.gz) compression_command=("tar" "-czf") ;;
        7z) compression_command=("7z" "a") ;;
        *) handle_error "Invalid format: $format" ;;
    esac

    case "$level" in
        low)
            compression_args=("-mx=1") # For 7z, low level compression
            ;;
        medium)
            compression_args=("-mx=5") # For 7z, medium level compression
            ;;
        high)
            compression_args=("-mx=9") # For 7z, high level compression
            ;;
        *)
            handle_error "Invalid compression level: $level"
            ;;
    esac

    OUTPUT_FILE="$SELECTED_DIR.$format"
    LOGFILE="$SELECTED_DIR/compressX.log"
    log "Compressing $SELECTED_DIR into $OUTPUT_FILE with $format format and $level compression level..."

    if [ "$format" = "tar.gz" ]; then
        tar -czf "$OUTPUT_FILE" "$SELECTED_DIR" || handle_error "Failed to compress directory"
    elif [ "$format" = "7z" ]; then
        "${compression_command[@]}" "$OUTPUT_FILE" "${compression_args[@]}" "$SELECTED_DIR" || handle_error "Failed to compress directory"
    else
        "${compression_command[@]}" "$OUTPUT_FILE" "${compression_args[@]}" "$SELECTED_DIR" || handle_error "Failed to compress directory"
    fi

    log "Compression completed successfully. File saved as $OUTPUT_FILE"
}

# Main script execution
main() {
    LOGFILE="~/compressX.log"

    log "Starting compression script..."
    check_dependencies
    select_directory
    decompress_if_needed
    compress_directory

    log "Script completed successfully."
}

main "$@"