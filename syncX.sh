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

# Function to log failed attempts
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

# Function to check dependencies
check_dependencies() {
    log "Checking and installing dependencies"
    for pkg in python python-pip jq zip unzip termux-api; do
        if ! command -v $pkg &> /dev/null; then
            log "$pkg is not installed. Installing..."
            pkg install $pkg -y || handle_error "Failed to install $pkg"
        else
            log "$pkg is already installed."
        fi
    done

    log "Upgrading pip and installing yt-dlp"
    python -m pip install --upgrade pip
    python -m pip install -U yt-dlp || {
        log "Failed to install yt-dlp via pip. Attempting direct download."
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o yt-dlp
        chmod +x yt-dlp
        mv yt-dlp $PREFIX/bin/ || handle_error "Failed to install yt-dlp"
    }
}

# Function to extract ZIP file if present
extract_zip_if_present() {
    ZIPFILE="$PLAYLIST_DIR/$PLAYLIST_NAME.zip"

    if [ -f "$ZIPFILE" ]; then
        log "Found ZIP file: $ZIPFILE. Extracting contents for comparison."
        TEMP_DIR="$PLAYLIST_DIR/temp_extracted"
        mkdir -p "$TEMP_DIR"
        unzip -o "$ZIPFILE" -d "$TEMP_DIR" || handle_error "Failed to extract ZIP file"
        log "ZIP file extracted to $TEMP_DIR"
    else
        log "No ZIP file found. Continuing with current directory contents."
    fi
}

# Function to compare and synchronize playlist
sync_playlist() {
    log "Starting playlist synchronization"

    # Temporary files for playlists
    local_playlist="$PLAYLIST_DIR/local_playlist.txt"
    online_playlist="$PLAYLIST_DIR/online_playlist.txt"

    # Generate list of local MP3 files (from ZIP if extracted, or directly from directory)
    log "Generating local playlist"
    if [ -d "$TEMP_DIR" ]; then
        find "$TEMP_DIR" -type f -name "*.mp3" -exec basename {} \; > "$local_playlist"
    else
        find "$PLAYLIST_DIR" -type f -name "*.mp3" -exec basename {} \; > "$local_playlist"
    fi

    # Fetch online playlist
    log "Fetching online playlist"
    yt-dlp -j --flat-playlist "$YOUTUBE_PLAYLIST_URL" 2> /dev/null | jq -r '.title' > "$online_playlist" || {
        log "Retrying playlist fetch with fallback method"
        yt-dlp --get-title "$YOUTUBE_PLAYLIST_URL" > "$online_playlist" || handle_error "Failed to fetch playlist from YouTube"
    }

    # Remove files no longer in the YouTube playlist
    log "Removing files not in the online playlist"
    while IFS= read -r track; do
        if ! grep -qxF "$track" "$online_playlist"; then
            if [ -d "$TEMP_DIR" ]; then
                rm "$TEMP_DIR/$track" && log "Removed $track from extracted files" || log "Failed to remove $track"
            else
                rm "$PLAYLIST_DIR/$track" && log "Removed $track from playlist directory" || log "Failed to remove $track"
            fi
        fi
    done < "$local_playlist"

    # Download new tracks
    log "Downloading new tracks"
    yt-dlp -x --audio-format mp3 -N 4 -o "$PLAYLIST_DIR/%(title)s.%(ext)s" "$YOUTUBE_PLAYLIST_URL" \
        --exec "termux-notification --title 'Downloading' --content 'Downloading: %(title)s'" || handle_error "Failed to download new tracks"

    # Update ZIP file with the synchronized playlist
    log "Updating ZIP file"
    rm -f "$ZIPFILE" || handle_error "Failed to remove old ZIP file"
    zip -r "$ZIPFILE" "$PLAYLIST_DIR"/*.mp3 || handle_error "Failed to create new ZIP file"
    log "ZIP file updated successfully"
}

# Main script execution
log "Starting playlistSyncX.sh"

# Variables
echo "Enter the base directory (default: /data/data/com.termux/files/home/storage/music/termux):"
read -r BASE_DIR
BASE_DIR=${BASE_DIR:-/data/data/com.termux/files/home/storage/music/termux}

echo "Enter the playlist directory name (default: Beat_That):"
read -r PLAYLIST_NAME
PLAYLIST_NAME=${PLAYLIST_NAME:-Beat_That}

echo "Enter the YouTube playlist URL:"
read -r YOUTUBE_PLAYLIST_URL

PLAYLIST_DIR="$BASE_DIR/$PLAYLIST_NAME"
LOGFILE="$PLAYLIST_DIR/logs/sync.log"
FAILED_LOG="$PLAYLIST_DIR/logs/failed.log"
VERBOSE=true
TEMP_DIR=""

# Ensure playlist directory exists
mkdir -p "$PLAYLIST_DIR/logs" || handle_error "Failed to create directory $PLAYLIST_DIR/logs"

# Check dependencies, extract ZIP if present, and synchronize playlist
check_dependencies
extract_zip_if_present
sync_playlist

# Clean up temporary extraction directory if used
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR" || log "Failed to clean up temporary directory"
    log "Temporary extraction directory cleaned up"
fi

log "playlistSyncX.sh completed successfully"