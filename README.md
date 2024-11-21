# Termux Audio Extractor

A collection of powerful Termux scripts for downloading and managing audio and video content from YouTube. The scripts provide efficient tools for extracting media, compressing files, and keeping everything organized.

---

## Features

- **Audio Extraction:** Download audio in MP3 format from YouTube playlists.
- **Video Download:** Fetch entire videos from YouTube.
- **Auto-Updating:** Keep scripts and required dependencies up-to-date.
- **File Compression:** Zip downloaded media files for easy sharing.
- **Organized Logs:** Track successes and failures with detailed logs.
- **Automated Cleanup:** Remove old logs and temporary files to save space.

---

## Files in the Repository

### Extractor.sh
Downloads audio files from a YouTube playlist in MP3 format, organizes them into directories, and optionally compresses the files into a ZIP archive. It leverages Termux notifications for real-time user feedback and maintains detailed logs.

**Features:**
1. **Audio Download:**
   - Extracts MP3 audio from a given YouTube playlist using yt-dlp.
   - Ensures efficient downloads with parallel connections (up to 4 at a time).

2. **File Compression:**
   - Prompts the user to zip the downloaded MP3 files into a single archive.
   - Deletes original MP3 files after successful compression to conserve storage.

3. **Dependency Management:**
   - Verifies required dependencies (yt-dlp, python, ffmpeg, zip, etc.).
   - Automatically installs missing tools.

4. **Logs and Notifications:**
   - Logs successful operations, errors, and failures in separate log files (download.log, failed.log).
   - Sends real-time Termux notifications for progress, errors, and task completion.

5. **Customizable Directories:**
   - Allows users to specify base and playlist directories.
   - Automatically creates missing directories during execution.

6. **File Cleanup:**
   - Removes logs older than 30 days and unused temporary files.

**Usage:**
1. Run the script:
   ```sh
   ./Extractor.sh
   ```
2. Enter the following details:
   - Base directory (default: `/data/data/com.termux/files/home/storage/music/termux`)
   - Playlist directory name (default: `Beat_That`)
   - YouTube playlist URL (default: provided example URL)

3. Choose whether to compress downloaded MP3 files.

4. The script will:
   - Download MP3 files into the specified playlist directory.
   - Zip the files if prompted.

**Dependencies:**
The script installs and checks for the following tools:
- yt-dlp
- python and pip
- ffmpeg
- zip
- termux-api

**Logs:**
Log Directory: Located in the playlist folder under logs/.
Log Files:
- `download.log:` Tracks all script operations.
- `failed.log:` Logs any failed downloads or tasks.
- `error_summary.log:` Summarizes critical errors for review.

**Termux Notifications:**
- Real-Time Updates: Notifications during downloads, errors, and file compression.
- Interactive Buttons: Quick actions like viewing logs or dismissing notifications.

### updaterX.sh
Ensures that Git is installed and up-to-date on your Termux environment, retrieves the latest changes from the Termux-Audio-Extractor- repository, and updates local scripts for immediate use. It also sets up the Termux Shortcuts directory for quick script execution.

**Features:**
1. **Git Installation and Update:**
   - Checks if Git is installed.
   - Installs Git if missing.
   - Updates Git to the latest version.

2. **Repository Management:**
   - Pulls the latest changes from the Termux-Audio-Extractor- repository.
   - Discards any local changes to specific scripts (Extractor.sh, updaterX.sh, vidX.sh, zipX.sh) to ensure compatibility with the repository.

3. **Shortcuts Setup:**
   - Copies updated scripts to the `~/.shortcuts/` directory.
   - Makes all scripts in the shortcuts directory executable.

4. **Storage Permissions:**
   - Ensures Termux has proper storage permissions to manage files.

**Usage:**
1. Run the script:
   ```sh
   ./updaterX.sh
   ```
2. The script performs the following tasks:
   - Installs or updates Git.
   - Verifies the Git version.
   - Navigates to the Termux-Audio-Extractor- repository directory.
   - Retrieves the latest updates from the repository.
   - Copies scripts to the Termux Shortcuts directory.
   - Ensures all scripts are executable.

3. **Storage Setup:** If not already configured, grants Termux storage access using `termux-setup-storage`.

**Key Directories and Files:**
1. **Repository Directory:** `~/Termux-Audio-Extractor-`
   - This is the local clone of the GitHub repository.

2. **Shortcuts Directory:** `~/.shortcuts/`
   - Contains the updated scripts for quick access via Termux shortcuts.

3. **Scripts Updated:**
   - Extractor.sh
   - updaterX.sh
   - vidX.sh
   - zipX.sh

**Dependencies:**
- Git: Used to pull the latest repository changes.

**Permissions:**
- Grants storage access via Termux for managing files in shared directories.
- Ensures all scripts are executable for direct usage.

### vidX.sh
Downloads videos from a specified YouTube playlist in MP4 format, organizes them into directories, and optionally compresses the files into a ZIP archive. It includes detailed logging and Termux notifications for seamless user interaction.

**Features:**
1. **Video Download:**
   - Downloads videos in MP4 format using yt-dlp.
   - Supports parallel downloads for improved speed.

2. **Optional File Compression:**
   - Prompts the user to ZIP the downloaded MP4 files.
   - Deletes original MP4 files after successful compression to save space.

3. **Detailed Logging:**
   - Logs all actions, including successful downloads, errors, and zipping, in timestamped log files.
   - Maintains separate logs for general events (download.log) and failed operations (failed.log).

4. **Termux Notifications:**
   - Sends real-time notifications for progress updates, errors, and completion of tasks.
   - Includes interactive buttons for quick actions, such as viewing logs or dismissing notifications.

5. **Automatic Dependency Management:**
   - Checks for and installs required packages (e.g., yt-dlp, python, ffmpeg, zip).
   - Installs yt-dlp via pip or downloads it directly from GitHub if needed.

6. **Customizable Directories:**
   - Allows users to specify base and playlist directories during setup.
   - Creates directories automatically if they do not exist.

7. **File Cleanup:**
   - Automatically removes logs older than 30 days and unused temporary files.

**Usage:**
1. Run the script:
   ```sh
   ./vidX.sh
   ```
2. Enter the following when prompted:
   - Base directory for storing videos (default: `/data/data/com.termux/files/home/storage/movies/termux`)
   - Playlist directory name (default: `Beat_That`)
   - YouTube playlist URL (default: a sample playlist URL)

3. Choose whether to compress downloaded MP4 files into a ZIP archive.

**Dependencies:**
The script installs and checks for the following tools:
- yt-dlp
- python and pip
- ffmpeg
- zip
- termux-api

**Logs:**
Logs are saved in a `logs` subdirectory within the playlist folder:
- `download.log:` Tracks all script activities.
- `failed.log:` Records any failed downloads or tasks.

**Termux Notifications:**
Notifications highlight critical events like downloads, errors, and file compression.
Notifications include interactive buttons for quick log access or dismissal.

### zipX.sh
Provides a tool for managing and extracting files from ZIP archives in predefined directories.

**Features:**
- Search for ZIP Files: Automatically scans specified directories for ZIP archives.
- List ZIP Contents: Displays the contents of selected ZIP files for review.
- Selective Extraction: Allows users to extract specific files from a ZIP archive into the same directory.
- Logging: Records actions, including successful and failed operations, in a log file located in the same directory as the selected ZIP file.

**Usage:**
1. Run the script:
   ```sh
   ./zipX.sh
   ```
2. Select a ZIP file from the list displayed.
3. View the contents of the selected ZIP file.
4. Choose specific files to extract by entering their corresponding numbers.
5. Extracted files will be saved in the same directory as the ZIP archive.

**Predefined Directories:**
- `/data/data/com.termux/files/home/storage/movies/termux`
- `/data/data/com.termux/files/home/storage/music/termux`

---

## Prerequisites

- **Termux:** Installed on your Android device.
- **Permissions:** Storage permissions enabled for Termux.
- **Internet Connection:** Required for downloading media and dependencies.

---

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/podcastmatt0285/Termux-Audio-Extractor-.git
   ```

2. Navigate to the folder:
   ```sh
   cd Termux-Audio-Extractor-
   ```

3. Make all scripts executable:
   ```sh
   chmod +x *.sh
   ```

---

## Usage Instructions

### Run Audio Extraction
Use `Extractor.sh` to download audio files from YouTube playlists:
```sh
./Extractor.sh
```
Follow the prompts to:
- Set the base directory for downloads.
- Name the playlist folder.
- Provide the YouTube playlist URL.
- Optionally zip the audio files after downloading.

---

### Update Scripts and Dependencies
Keep scripts and packages up to date with `updaterX.sh`:
```sh
./updaterX.sh
```

### Download Videos
Use `vidX.sh` to download videos from YouTube playlists:
```sh
./vidX.sh
```

### Compress Files
Use `zipX.sh` to compress downloaded media into a ZIP file:
```sh
./zipX.sh
```

---

## Logs and Cleanup

### Logs
Logs are saved in the `logs` directory within your chosen playlist folder:
- `download.log:` Records successful downloads.
- `failed.log:` Logs failed downloads.

### Cleanup
Automatically deletes old logs and temporary files (older than 30 days) during script execution.
Manual cleanup can be performed by running the appropriate functions in the scripts.

---

## License

This project is licensed under the MIT License.
