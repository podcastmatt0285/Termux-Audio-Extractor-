#!/bin/bash

# Function to log messages
log() {
    if $VERBOSE; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
    fi
    termux-notification --title "📜 Log Entry" --content "$1" --button1 "📄 View Log" --button1-action "less $LOGFILE" \
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
    termux-notification --title "🚨 Error" --content "An error occurred: $1" --priority "max"
    exit 1
}

# Function to check if dependencies are installed
check_dependencies() {
    log "🔄 Updating and upgrading packages"
    pkg update && pkg upgrade -y
    log "🔍 Checking for required packages"
    for pkg in yt-dlp zip xargs; do
        if ! command -v $pkg &> /dev/null; then
            log "$pkg is not installed. Installing..."
            termux-notification --title "📦 Installing Package" --content "Installing $pkg" \
                --priority "high"
            pkg install $pkg -y || handle_error "Failed to install $pkg"
        else
            log "$pkg is already installed."
        fi
    done
}

# Function to clean up old logs and temporary files
cleanup() {
    log "🧹 Cleaning up old logs and temporary files"
    find . -name "*.log" -type f -mtime +30 -exec rm {} \;
    find . -name "*.mp3" -type f -exec rm {} \;
}

# Function to download videos
download_videos() {
    log "⬇️ Starting video download"
    yt-dlp -f mp4 -N 4 -o "$FULL_PLAYLIST_DIR/%(title)s.%(ext)s" "$YOUTUBE_PLAYLIST_URL" \
        --exec "termux-notification --id 100 --title '⬇️ Downloading' --content 'Downloading: %(title)s' --priority 'high'"
    log "✅ Video download completed"
}

# Main script execution
termux-notification --title "🚀 Script Started" --content "The download script has started." --priority "high"

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

ZIPFILE="$PLAYLIST_DIR.zip"
LOGFILE="download.log"
FAILED_LOG="failed.log"
ERROR_SUMMARY="error_summary.log"
VERBOSE=true
FULL_PLAYLIST_DIR="$BASE_DIR/$PLAYLIST_DIR"

check_dependencies
download_videos
if [ -f "$ZIPFILE" ]; then
    log "🗂 ZIP file $ZIPFILE already exists. Removing it."
    rm "$ZIPFILE"
fi
if ls "$FULL_PLAYLIST_DIR"/*.mp4 1> /dev/null 2>&1; then
    zip -r "$ZIPFILE" "$FULL_PLAYLIST_DIR"/*.mp4 || handle_error "Failed to create ZIP file"
    rm "$FULL_PLAYLIST_DIR"/*.mp4
    log "📦 Zipped all MP4 files in $FULL_PLAYLIST_DIR into $ZIPFILE"
    termux-notification --title "✅ Zipping Complete" --content "Zipped all MP4 files in $FULL_PLAYLIST_DIR into $ZIPFILE" \
        --priority "high"
else
    handle_error "No MP4 files found to zip"
fi
mv "$ZIPFILE" "$FULL_PLAYLIST_DIR/$ZIPFILE" || handle_error "Failed to move ZIP file to $FULL_PLAYLIST_DIR"
if [ -s "$ERROR_SUMMARY" ]; then
    termux-notification --title "⚠️ Errors Encountered" --content "Check $ERROR_SUMMARY for details." --priority "high"
fi
cleanup

# Final notification with buttons
termux-notification --title "🎉 Script Completed" --content "The script has completed successfully." \
    --button1 "🔄 Run Again" --button1-action "bash /data/data/com.termux/files/home/scripts/notification_buttons/playlist_rerun" \
    --button2 "🗑 Delete ZIP" --button2-action "bash /data/data/com.termux/files/home/scripts/notification_buttons/delete_zip" \
    --button3 "🚪 Exit Termux" --button3-action "bash /data/data/com.termux/files/home/scripts/notification_buttons/exit" \
    --priority "high"