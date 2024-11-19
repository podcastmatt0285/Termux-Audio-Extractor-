#!/bin/bash

# Function to log messages
log() {
    local msg=$1
    local log_file=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $msg" | tee -a "$log_file"
}

# Function to handle errors
handle_error() {
    local error_msg=$1
    local log_file=$2
    log "ERROR: $error_msg" "$log_file"
    echo "An error occurred: $error_msg"
    exit 1
}

# Function to list ZIP files in predefined directories
list_zip_files() {
    local directories=(
        "/data/data/com.termux/files/home/storage/movies/termux"
        "/data/data/com.termux/files/home/storage/music/termux"
    )
    local zip_files=()
    for dir in "${directories[@]}"; do
        if [ -d "$dir" ]; then
            zip_files+=($(find "$dir" -maxdepth 1 -name "*.zip"))
        fi
    done
    echo "${zip_files[@]}"
}

# Function to list contents of a ZIP file
list_zip_contents() {
    local zip_file=$1
    unzip -Z1 "$zip_file" || handle_error "Unable to list contents of $zip_file" "$LOGFILE"
}

# Main script execution
echo "Searching for ZIP files in predefined directories..."
zip_files=($(list_zip_files))
if [ ${#zip_files[@]} -eq 0 ]; then
    echo "No ZIP files found."
    exit 0
fi

# Display the found ZIP files
echo "Select a ZIP file to list its contents:"
for i in "${!zip_files[@]}"; do
    echo "$((i+1)). $(basename "${zip_files[$i]}")"
done

# Get user selection
read -r -p "Enter the number of the ZIP file to select: " selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#zip_files[@]} ]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

selected_zip="${zip_files[$((selection-1))]}"
selected_zip_dir=$(dirname "$selected_zip")
LOGFILE="$selected_zip_dir/script.log"

log "Selected ZIP file: $selected_zip" "$LOGFILE"

# List contents of the selected ZIP file
echo "Contents of $(basename "$selected_zip"):"
zip_contents=($(list_zip_contents "$selected_zip"))
for i in "${!zip_contents[@]}"; do
    echo "$((i+1)). ${zip_contents[$i]}"
done

# Get user selection of files to extract
read -r -p "Enter the numbers of the files you want to extract (separated by spaces): " -a file_selections
if [ ${#file_selections[@]} -eq 0 ]; then
    handle_error "No files selected for extraction" "$LOGFILE"
fi

# Extract selected files
log "Starting extraction process..." "$LOGFILE"
for file_index in "${file_selections[@]}"; do
    if [[ "$file_index" =~ ^[0-9]+$ ]] && [ "$file_index" -ge 1 ] && [ "$file_index" -le ${#zip_contents[@]} ]; then
        file_path="${zip_contents[$((file_index-1))]}"
        unzip -j "$selected_zip" "$file_path" -d "$selected_zip_dir" && \
            log "Extracted: $file_path to $selected_zip_dir" "$LOGFILE" || \
            log "Failed to extract: $file_path" "$LOGFILE"
    else
        log "Invalid file selection: $file_index" "$LOGFILE"
    fi
done

log "Extraction completed successfully." "$LOGFILE"
echo "Selected files have been extracted to $selected_zip_dir."