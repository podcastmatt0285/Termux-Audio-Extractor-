#!/bin/bash

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
    termux-notification --title "Log Entry" --content "$1"
}

# Function to handle errors
handle_error() {
    log "ERROR: $1"
    termux-notification --title "Error" --content "$1"
    exit 1
}

# Function to check dependencies
check_dependencies() {
    log "Checking for required dependencies"
    for pkg in python python-pip zip ffmpeg termux-api; do
        if ! command -v "$pkg" &> /dev/null; then
            log "Installing missing package: $pkg"
            pkg install "$pkg" -y || handle_error "Failed to install $pkg"
        else
            log "$pkg is already installed."
        fi
    done

    log "Ensuring yt-dlp is up-to-date"
    python -m pip install --upgrade pip
    python -m pip install -U yt-dlp || handle_error "Failed to update yt-dlp"
}

# Function to extract a ZIP file if it exists
extract_zip() {
    if [ -f "${PLAYLIST_DIR}.zip" ]; then
        log "Found ZIP file in playlist directory. Extracting contents..."
        TEMP_DIR=$(mktemp -d)
        unzip -oq "${PLAYLIST_DIR}.zip" -d "$TEMP_DIR" || handle_error "Failed to extract ZIP file"
        log "Extraction complete. Temporary directory: $TEMP_DIR"
    else
        log "No ZIP file found. Continuing without extraction."
        TEMP_DIR=""
    fi
}

# Function to compare and synchronize playlists
sync_playlists() {
    log "Downloading online playlist to $online_playlist"
    yt-dlp --flat-playlist --print "%(title)s.%(ext)s" "$YOUTUBE_PLAYLIST_URL" > "$online_playlist" || handle_error "Failed to fetch playlist from YouTube"

    log "Building local playlist from $PLAYLIST_DIR"
    find "$PLAYLIST_DIR" -maxdepth 1 -type f -name "*.mp3" -exec basename {} \; > "$local_playlist"

    if [ -n "$TEMP_DIR" ]; then
        log "Adding extracted ZIP contents to local playlist comparison"
        find "$TEMP_DIR" -maxdepth 1 -type f -name "*.mp3" -exec basename {} \; >> "$local_playlist"
    fi

    log "Comparing playlists and identifying differences"
    comm -23 "$online_playlist" "$local_playlist" > "$tracks_to_download"
    comm -13 "$online_playlist" "$local_playlist" > "$tracks_to_remove"
}

# Function to download new tracks
download_new_tracks() {
    if [ -s "$tracks_to_download" ]; then
        log "Downloading new tracks from YouTube"
        while IFS= read -r track; do
            yt-dlp -x --audio-format mp3 -o "$PLAYLIST_DIR/%(title)s.%(ext)s" "$YOUTUBE_PLAYLIST_URL" \
                --match-title "^$track$" || handle_error "Failed to download track: $track"
            log "Downloaded track: $track"
        done < "$tracks_to_download"
    else
        log "No new tracks to download."
    fi
}

# Function to remove outdated tracks
remove_outdated_tracks() {
    if [ -s "$tracks_to_remove" ]; then
        log "Removing outdated tracks"
        while IFS= read -r track; do
            local_path_temp="$TEMP_DIR/$track"
            local_path_playlist="$PLAYLIST_DIR/$track"

            if [ -f "$local_path_temp" ]; then
                rm "$local_path_temp" && log "Removed $track from extracted files" || log "Failed to remove $track from TEMP_DIR"
            elif [ -f "$local_path_playlist" ]; then
                rm "$local_path_playlist" && log "Removed $track from playlist directory" || log "Failed to remove $track from PLAYLIST_DIR"
            else
                log "File $track not found in TEMP_DIR or PLAYLIST_DIR. Skipping."
            fi
        done < "$tracks_to_remove"
    else
        log "No outdated tracks to remove."
    fi
}

# Main script execution
log "Starting playlistSyncX script"

# User inputs
echo "Enter the playlist directory (default: ~/storage/music/termux):"
read -r PLAYLIST_DIR
PLAYLIST_DIR=${PLAYLIST_DIR:-~/storage/music/termux}

echo "Enter the YouTube playlist URL:"
read -r YOUTUBE_PLAYLIST_URL

# Ensure directories and files exist
mkdir -p "$PLAYLIST_DIR"
LOGFILE="$PLAYLIST_DIR/sync.log"
online_playlist="$PLAYLIST_DIR/online_playlist.txt"
local_playlist="$PLAYLIST_DIR/local_playlist.txt"
tracks_to_download="$PLAYLIST_DIR/tracks_to_download.txt"
tracks_to_remove="$PLAYLIST_DIR/tracks_to_remove.txt"

# Run script logic
check_dependencies
extract_zip
sync_playlists
download_new_tracks
remove_outdated_tracks

# Cleanup
log "Cleaning up temporary files"
rm -f "$online_playlist" "$local_playlist" "$tracks_to_download" "$tracks_to_remove"
[ -n "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"

log "playlistSyncX script completed successfully"
termux-notification --title "Sync Complete" --content "Playlist synchronization complete."