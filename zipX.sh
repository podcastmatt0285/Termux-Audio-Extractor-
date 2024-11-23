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

# Function to list archive files in predefined directories
list_archive_files() {
    local directories=(
        "/data/data/com.termux/files/home/storage/movies/termux"
        "/data/data/com.termux/files/home/storage/music/termux"
    )
    local archive_files=()
    for dir in "${directories[@]}"; do
        if [ -d "$dir" ]; then
            archive_files+=($(find "$dir" -type f \( -name "*.zip" -o -name "*.tar.gz" -o -name "*.7z" \)))
        fi
    done
    echo "${archive_files[@]}"
}

# Function to list contents of an archive file
list_archive_contents() {
    local archive_file=$1
    case "$archive_file" in
        *.zip)
            unzip -Z1 "$archive_file" | sed '/^$/d' || handle_error "Unable to list contents of $archive_file" "$LOGFILE"
            ;;
        *.tar.gz)
            tar -tzf "$archive_file" || handle_error "Unable to list contents of $archive_file" "$LOGFILE"
            ;;
        *.7z)
            7z l "$archive_file" -ba | awk '{print $6}' || handle_error "Unable to list contents of $archive_file" "$LOGFILE"
            ;;
        *)
            handle_error "Unsupported file type: $archive_file" "$LOGFILE"
            ;;
    esac
}

# Function to extract files from an archive
extract_files() {
    local archive_file=$1
    local file_list=("${@:2}")
    case "$archive_file" in
        *.zip)
            unzip -j "$archive_file" "${file_list[@]}" -d "$selected_zip_dir" || handle_error "Failed to extract files from $archive_file" "$LOGFILE"
            ;;
        *.tar.gz)
            tar -xzf "$archive_file" -C "$selected_zip_dir" -- "${file_list[@]}" || handle_error "Failed to extract files from $archive_file" "$LOGFILE"
            ;;
        *.7z)
            7z e "$archive_file" -o"$selected_zip_dir" "${file_list[@]}" || handle_error "Failed to extract files from $archive_file" "$LOGFILE"
            ;;
        *)
            handle_error "Unsupported file type: $archive_file" "$LOGFILE"
            ;;
    esac
}

# Main script execution
echo "Searching for archive files in predefined directories..."
archive_files=($(list_archive_files))
if [ ${#archive_files[@]} -eq 0 ]; then
    echo "No archive files found."
    exit 0
fi

# Display the found archive files
echo "Select an archive file to list its contents:"
for i in "${!archive_files[@]}"; do
    echo "$((i+1)). $(basename "${archive_files[$i]}")"
done

# Get user selection
read -r -p "Enter the number of the archive file to select: " selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#archive_files[@]} ]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

selected_archive="${archive_files[$((selection-1))]}"
selected_archive_dir=$(dirname "$selected_archive")
LOGFILE="$selected_archive_dir/script.log"

log "Selected archive file: $selected_archive" "$LOGFILE"

# List contents of the selected archive file
echo "Contents of $(basename "$selected_archive"):"
archive_contents=()
while IFS= read -r file; do
    archive_contents+=("$file")
done < <(list_archive_contents "$selected_archive")

for i in "${!archive_contents[@]}"; do
    echo "$((i+1)). ${archive_contents[$i]}"
done

# Get user selection of files to extract
read -r -p "Enter the numbers of the files you want to extract (separated by spaces): " -a file_selections
if [ ${#file_selections[@]} -eq 0 ]; then
    handle_error "No files selected for extraction" "$LOGFILE"
fi

# Extract selected files
log "Starting extraction process..." "$LOGFILE"
extract_files "$selected_archive" "${archive_contents[@]:file_selections}"

log "Extraction completed successfully." "$LOGFILE"
echo "Selected files have been extracted to $selected_archive_dir."