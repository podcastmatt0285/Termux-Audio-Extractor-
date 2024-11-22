#!/bin/bash

# Function to log messages
log() {
    if $VERBOSE; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
    fi
    termux-notification --title "Log Entry" --content "$1" --button1 "View Log" --button1-action "less $LOGFILE" \
        --button2 "❌ Dismiss" --button2-action "termux-notification-remove %i" --priority "max"
}

# Function to log failed files
log_failed() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $FAILED_LOG
    termux-notification --title "⚠️ Failed Log Entry" --content "$1" --priority "high"
}

# Function to handle errors
handle_error() {
    log_failed "$1"
    log "Error encountered: $1"
    termux-notification --title "Error" --content "An error occurred: $1" --priority "max"
    exit 1
}

# Function to check if dependencies are installed
check_dependencies() {
    log "Updating and upgrading packages"
    pkg update && pkg upgrade -y
    log "Checking for required packages"
    for pkg in python python-pip zip xargs ffmpeg termux-api; do
        if ! command -v $pkg &> /dev/null; then
            log "$pkg is not installed. Installing..."
            termux-notification --title "Installing Package" --content "Installing $pkg" \
                --priority "high"
            pkg install $pkg -y || handle_error "Failed to install $pkg"
        else
            log "$pkg is already installed."
        fi
    done

    # Install yt-dlp via pip
    log "Upgrading pip and installing yt-dlp"
    python -m pip install --upgrade pip
    python -m pip install -U yt-dlp || {
        # If pip installation fails, download yt-dlp directly
        log "Failed to install yt-dlp via pip. Downloading directly from GitHub."
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o yt-dlp
        chmod +x yt-dlp
        mv yt-dlp $PREFIX/bin/
    }
}

# Function to clean up old logs and temporary files
cleanup() {
    log "Cleaning up old logs and temporary files"
    find . -name "*.log" -type f -mtime +30 -exec rm {} \;
    find . -name "*.mp4" -type f -exec rm {} \;
}

# Function to download videos
download_videos() {
    log "⬇️ Starting video download"
    yt-dlp -f mp4 -N 4 -o "$FULL_PLAYLIST_DIR/%(title)s.%(ext)s" "$YOUTUBE_PLAYLIST_URL" \
        --exec "termux-notification --id 100 --title '⬇️ Downloading' --content 'Downloading: %(title)s' --priority 'high'"
    log "✅ Video download completed"
}

# Main script execution
termux-notification --title "Script Started" --content "The download script has started." --priority "high"

# Variables
echo "Enter the base directory (default: /data/data/com.termux/files/home/storage/movies/termux):"
read -r BASE_DIR
BASE_DIR=${BASE_DIR:-/data/data/com.termux/files/home/storage/movies/termux}

echo "Enter the playlist directory name (default: Beat_That):"
read -r PLAYLIST_DIR
PLAYLIST_DIR=${PLAYLIST_DIR:-Beat_That}

echo "Enter the YouTube playlist URL (default: https://music.youtube.com/playlist?list=PLPHx1a3AKEWnVvtndzIUBtMfeiM6WCXds&si=kmenK0-ShrP6mT74):"
read -r YOUTUBE_PLAYLIST_URL
YOUTUBE_PLAYLIST_URL=${YOUTUBE_PLAYLIST_URL:-https://music.youtube.com/playlist?list=PLPHx1a3AKEWnVvtndzIUBtMfeiM6WCXds&si=kmenK0-ShrP6mT74}

read -r -p "Do you want to zip the downloaded MP4 files (y/N)? " zip_answer

mkdir -p "$FULL_PLAYLIST_DIR/logs"
LOGFILE="$FULL_PLAYLIST_DIR/logs/download.log"
FAILED_LOG="$FULL_PLAYLIST_DIR/logs/failed.log"
ERROR_SUMMARY="$FULL_PLAYLIST_DIR/logs/error_summary.log"
VERBOSE=true
FULL_PLAYLIST_DIR="$BASE_DIR/$PLAYLIST_DIR"

# Ensure the base directory and playlist directory exist
mkdir -p "$FULL_PLAYLIST_DIR" || handle_error "Failed to create directory $FULL_PLAYLIST_DIR"

check_dependencies
download_videos

# Handle zipping based on user input
if [[ "$zip_answer" =~ ^([Yy])$ ]]; then
    if [ -f "$ZIPFILE" ]; then
        log "ZIP file $ZIPFILE already exists. Removing it."
        rm "$ZIPFILE"
    fi
    if ls "$FULL_PLAYLIST_DIR"/*.mp4 1> /dev/null 2>&1; then
        zip -r "$ZIPFILE" "$FULL_PLAYLIST_DIR"/*.mp4 || handle_error "Failed to create ZIP file"
        rm "$FULL_PLAYLIST_DIR"/*.mp4
        log "Zipped all MP4 files in $FULL_PLAYLIST_DIR into $ZIPFILE"
        termux-notification --title "Zipping Complete" --content "Zipped all MP4 files."
    fi
fi

# Cleanup old logs and temporary files
cleanup
