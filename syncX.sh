#!/bin/bash

# Function to log messages
log() {
    if $VERBOSE; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
    fi
}

# Function to handle errors
handle_error() {
    log "ERROR: $1"
    termux-notification --title "Error in playlistSyncX.sh" --content "$1"
    exit 1
}

# Function to check dependencies
check_dependencies() {
    log "Checking for required packages"
    for pkg in python python-pip yt-dlp; do
        if ! command -v $pkg &> /dev/null; then
            log "$pkg is not installed. Installing..."
            pkg install $pkg -y || handle_error "Failed to install $pkg"
        else
            log "$pkg is already installed."
        fi
    done

    log "Ensuring yt-dlp is up-to-date"
    python -m pip install --upgrade pip
    python -m pip install -U yt-dlp || handle_error "Failed to upgrade yt-dlp"
}

# Function to download and sync playlist
sync_playlist() {
    log "Starting playlist sync"
    
    # Temporary file for current playlist tracks
    local_playlist="$PLAYLIST_DIR/local_playlist.txt"
    online_playlist="$PLAYLIST_DIR/online_playlist.txt"
    
    # Generate list of local MP3 files
    find "$PLAYLIST_DIR" -type f -name "*.mp3" -exec basename {} \; > "$local_playlist"

    # Fetch online playlist and save track names
    yt-dlp -j --flat-playlist "$YOUTUBE_PLAYLIST_URL" | jq -r '.title' > "$online_playlist" || handle_error "Failed to fetch playlist from YouTube"

    # Remove files no longer in the YouTube playlist
    log "Removing files no longer in the online playlist"
    while IFS= read -r track; do
        if ! grep -qxF "$track" "$online_playlist"; then
            rm "$PLAYLIST_DIR/$track" && log "Removed $track" || log "Failed to remove $track"
        fi
    done < "$local_playlist"

    # Download new tracks
    log "Downloading new tracks"
    yt-dlp -x --audio-format mp3 -N 4 -o "$PLAYLIST_DIR/%(title)s.%(ext)s" "$YOUTUBE_PLAYLIST_URL" \
        --exec "termux-notification --title 'Downloading' --content 'Downloading: %(title)s'" || handle_error "Failed to download new tracks"

    log "Playlist sync completed successfully"
}

# Main script execution
termux-notification --title "playlistSyncX.sh Started" --content "Syncing playlist..." --priority "high"

# Variables
echo "Enter the base directory (default: /data/data/com.termux/files/home/storage/music/termux):"
read -r BASE_DIR
BASE_DIR=${BASE_DIR:-/data/data/com.termux/files/home/storage/music/termux}

echo "Enter the playlist directory name (default: Beat_That):"
read -r PLAYLIST_DIR
PLAYLIST_DIR=${PLAYLIST_DIR:-Beat_That}
FULL_PLAYLIST_DIR="$BASE_DIR/$PLAYLIST_DIR"

echo "Enter the YouTube playlist URL:"
read -r YOUTUBE_PLAYLIST_URL

# Create log directory
mkdir -p "$FULL_PLAYLIST_DIR/logs"
LOGFILE="$FULL_PLAYLIST_DIR/logs/sync.log"
VERBOSE=true

# Ensure playlist directory exists
mkdir -p "$FULL_PLAYLIST_DIR" || handle_error "Failed to create directory $FULL_PLAYLIST_DIR"

check_dependencies
sync_playlist

# Notify user of completion
termux-notification --title "playlistSyncX.sh Completed" --content "Playlist synced successfully."