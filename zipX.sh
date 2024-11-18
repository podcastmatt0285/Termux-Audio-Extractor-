#!/bin/bash

cd ~/Termux-Audio-Extractor-

# Function to log messages
log() {
    if $VERBOSE; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
    fi
}

# Function to handle errors
handle_error() {
    log "Error encountered: $1"
    echo "An error occurred: $1"
    exit 1
}

# Function to list zip files in a directory
list_zip_files() {
    local dir=$1
    if [ -d "$dir" ]; then
        find "$dir" -name "*.zip"
    else
        handle_error "Directory $dir does not exist"
    fi
}

# Variables
LOGFILE="list_zip_files.log"
VERBOSE=true
zip_files=()

# List zip files in the specified directories
zip_files+=( $(list_zip_files "/data/data/com.termux/files/home/storage/movies/termux") )
zip_files+=( $(list_zip_files "/data/data/com.termux/files/home/storage/music/termux") )

# Check if there are any zip files
if [ ${#zip_files[@]} -eq 0 ]; then
    echo "No zip files found."
    exit 0
fi

# Display zip files as numbered options
echo "Select a zip file to list its contents:"
for i in "${!zip_files[@]}"; do
    filename=$(basename "${zip_files[$i]}")
    echo "$((i+1)). $filename"
done

# Get user selection
read -r -p "Enter the number of the zip file you want to list: " selection

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#zip_files[@]} ]; then
    handle_error "Invalid selection"
fi

selected_zip="${zip_files[$((selection-1))]}"

# List contents of the selected zip file
echo "Contents of $(basename "$selected_zip"):"
unzip -l "$selected_zip"

# Get user selection of files to extract
read -r -p "Enter the numbers of the files you want to extract (separated by spaces): " -a file_selections

# Extract selected files
echo "Extracting selected files..."
for file_index in "${file_selections[@]}"; do
    file_path=$(unzip -Z1 "$selected_zip" | sed -n "${file_index}p")
    if [ -n "$file_path" ]; then
        unzip -j "$selected_zip" "$file_path" -d "./extracted_files"
        log "Extracted: $file_path"
    else
        handle_error "Invalid file selection: $file_index"
    fi
done

log "Script completed"
echo "Selected files have been extracted."
echo "Zip file listing script has completed."