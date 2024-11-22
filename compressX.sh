#!/bin/bash

# Function to log messages
log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOGFILE"
}

handle_error() {
    log "ERROR: $1"
    exit 1
}

# Function to check dependencies
check_dependencies() {
    log "Checking for required dependencies..."
    for tool in zip tar 7z; do
        if ! command -v "$tool" &>/dev/null; then
            log "$tool is not installed. Installing..."
            pkg install "$tool" -y || handle_error "Failed to install $tool"
        else
            log "$tool is already installed."
        fi
    done
}

# Function to display directories and allow selection
select_directory() {
    local dirs=()
    local index=1

    log "Searching for directories in ~/storage/music/termux and ~/storage/movies/termux..."
    while IFS= read -r -d $'\0' dir; do
        dirs+=("$dir")
    done < <(find ~/storage/{music/movies}/termux -type d -print0)

    if [ "${#dirs[@]}" -eq 0 ]; then
        handle_error "No directories found to compress."
    fi

    echo "Select a directory to compress:"
    for dir in "${dirs[@]}"; do
        echo "$index) $dir"
        ((index++))
    done

    read -r selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#dirs[@]}" ]; then
        echo "${dirs[$((selection - 1))]}"
    else
        handle_error "Invalid selection."
    fi
}

# Function to decompress if necessary
decompress_if_needed() {
    local path="$1"
    if [[ "$path" =~ \.(zip|tar\.gz|7z)$ ]]; then
        log "Decompressing $path..."
        case "$path" in
            *.zip) unzip "$path" -d "${path%.*}" || handle_error "Failed to decompress $path" ;;
            *.tar.gz) tar -xzf "$path" -C "${path%.*}" || handle_error "Failed to decompress $path" ;;
            *.7z) 7z x "$path" -o"${path%.*}" || handle_error "Failed to decompress $path" ;;
            *) handle_error "Unsupported compression format for decompression: $path" ;;
        esac
        echo "${path%.*}"  # Return the decompressed directory
    else
        echo "$path"  # Return the original directory if no decompression was needed
    fi
}

# Function to compress a directory
compress() {
    local input_path="$1"
    local format="$2"
    local level="$3"

    LOGFILE="$input_path/compressX.log"  # Log file in the same directory as the compressed file
    local output_file

    case "$format" in
        zip)
            output_file="$input_path.zip"
            case "$level" in
                low) zip -1 -r "$output_file" "$input_path" ;;
                medium) zip -5 -r "$output_file" "$input_path" ;;
                high) zip -9 -r "$output_file" "$input_path" ;;
                *) handle_error "Invalid compression level: $level" ;;
            esac
            ;;
        tar.gz)
            output_file="$input_path.tar.gz"
            case "$level" in
                low) tar -czf "$output_file" --fast "$input_path" ;;
                medium) tar -czf "$output_file" "$input_path" ;;
                high) tar -czf "$output_file" --best "$input_path" ;;
                *) handle_error "Invalid compression level: $level" ;;
            esac
            ;;
        7z)
            output_file="$input_path.7z"
            case "$level" in
                low) 7z a -mx=1 "$output_file" "$input_path" ;;
                medium) 7z a -mx=5 "$output_file" "$input_path" ;;
                high) 7z a -mx=9 "$output_file" "$input_path" ;;
                *) handle_error "Invalid compression level: $level" ;;
            esac
            ;;
        *)
            handle_error "Unsupported format: $format"
            ;;
    esac

    log "Compression completed: $output_file"
    echo "Compressed file saved as: $output_file"
}

# Main script execution
main() {
    check_dependencies

    local selected_path
    selected_path=$(select_directory)  # User selects a directory or compressed file

    # Decompress if necessary
    selected_path=$(decompress_if_needed "$selected_path")

    echo "Choose compression format (zip, tar.gz, 7z):"
    read -r format
    case "$format" in
        zip|tar.gz|7z) ;;
        *) handle_error "Invalid format: $format" ;;
    esac

    echo "Choose compression level (low, medium, high):"
    read -r level
    case "$level" in
        low|medium|high) ;;
        *) handle_error "Invalid level: $level" ;;
    esac

    compress "$selected_path" "$format" "$level"
}

main "$@"