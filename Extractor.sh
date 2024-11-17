#!/bin/bash

# Function to log messages
log() {
    if $VERBOSE; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
    fi
    termux-notification --title "Log Entry" --content "$1"
}

# Function to log failed files
log_failed() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $FAILED_LOG
    termux-notification --title "Failed Log Entry" --content "$1"
}

# Function to handle errors
handle_error() {
    log_failed "$1"
    log "Error encountered: $1"
    termux-notification --title "Error" --content "An error occurred: $1"
    exit 1
}

# Function to check if dependencies are installed
check_dependencies() {
    log "Updating and upgrading packages"
    pkg update && pkg upgrade -y
    log "Checking for required packages"
    for pkg in yt-dlp zip xargs; do
        if ! command -v $pkg &> /dev/null; then
            log "$pkg is not installed. Installing..."
            termux-notification --title "Installing Package" --content "Installing $pkg"
            pkg install $pkg -y || handle_error "Failed to install $pkg"
        else
            log "$pkg is already installed."
        fi
    done
}

# Function to clean up old logs and temporary files
cleanup() {
    log "Cleaning up old logs and temporary files"
    find . -name "*.log" -type f -mtime +30 -exec rm {} \;
    find . -name "*.mp3" -type f -exec rm {} \;
}

# Function to download audio
download_audio() {
    log "Starting audio download"
    yt-dlp -x --audio-format mp3 -N 4 -o "$FULL_PLAYLIST_DIR/%(title)s.%(ext)s" "$YOUTUBE_PLAYLIST_URL" \
        --exec "termux-notification --id 100 --title 'Downloading' --content 'Downloading: %(title)s'"
    log "Audio download completed"
}

# Main script execution
termux-notification --title "Script Started" --content "The download script has started."

# Variables
echo "Enter the base directory (default: /data/data/com.termux/files/home/storage/music/termux):"
read -r BASE_DIR
BASE_DIR=${BASE_DIR:-/data/data/com.termux/files/home/storage/music/termux}

echo "Enter the playlist directory name (default: Beat_That):"
read -r PLAYLIST_DIR
PLAYLIST_DIR=${PLAYLIST_DIR:-Beat_That}

echo "Enter the YouTube playlist URL (default: https://music.youtube.com/playlist?list=PLPHx1a3AKEWnVvtndzIUBtMfeiM6WCXds&si=kmenK0-ShrP6mT74):"
read -r YOUTUBE_PLAYLIST_URL
YOUTUBE_PLAYLIST_URL=${YOUTUBE_PLAYLIST_URL:-https://music.youtube.com/playlist?list=PLPHx1a3AKEWnVvtndzIUBtMfeiM6WCXds&si=kmenK0-ShrP6mT74}

# Ask user if they want to zip the files immediately after URL input
read -r -p "Do you want to zip the downloaded MP3 files (y/N)? " zip_answer

ZIPFILE="$PLAYLIST_DIR.zip"
LOGFILE="download.log"
FAILED_LOG="failed.log"
ERROR_SUMMARY="error_summary.log"
VERBOSE=true
FULL_PLAYLIST_DIR="$BASE_DIR/$PLAYLIST_DIR"

check_dependencies
download_audio

if [[ "$zip_answer" =~ ^([Yy])$ ]]; then
    if [ -f "$ZIPFILE" ]; then
        log "ZIP file $ZIPFILE already exists. Removing it."
        rm "$ZIPFILE"
    fi
    if ls "$FULL_PLAYLIST_DIR"/*.mp3 1> /dev/null 2>&1; then
        zip -r "$ZIPFILE" "$FULL_PLAYLIST_DIR"/*.mp3 || handle_error "Failed to create ZIP file"
        rm "$FULL_PLAYLIST_DIR"/*.mp3
        log "Zipped all MP3 files in $FULL_PLAYLIST_DIR into $ZIPFILE"
        termux-notification --title "Zipping Complete" --content "Zipped all MP
