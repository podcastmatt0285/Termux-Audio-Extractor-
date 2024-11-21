Termux Audio Extractor

A collection of powerful Termux scripts for downloading and managing audio and video content from YouTube. The scripts provide efficient tools for extracting media, compressing files, and keeping everything organized.


---

Features

Audio Extraction: Download audio in MP3 format from YouTube playlists.

Video Download: Fetch entire videos from YouTube.

Auto-Updating: Keep scripts and required dependencies up-to-date.

File Compression: Zip downloaded media files for easy sharing.

Organized Logs: Track successes and failures with detailed logs.

Automated Cleanup: Remove old logs and temporary files to save space.



---

Files in the Repository

Extractor.sh

Main script for downloading audio files from YouTube playlists.

Features include:

MP3 extraction with metadata.

Directory-based file organization.

Optional ZIP compression and automated cleanup.



updaterX.sh

Handles updates for scripts and dependencies.

Ensures required packages and tools are up-to-date.


vidX.sh

Script for downloading full video files from YouTube playlists.

Saves videos in organized directories for easy access.


zipX.sh

Compresses downloaded files into a ZIP archive.

Cleans up original files after successful zipping to save space.



---

Prerequisites

Termux: Installed on your Android device.

Permissions: Storage permissions enabled for Termux.

Internet Connection: Required for downloading media and dependencies.



---

Installation

1. Clone the repository:

git clone https://github.com/podcastmatt0285/Termux-Audio-Extractor-.git


2. Navigate to the folder:

cd Termux-Audio-Extractor-


3. Make all scripts executable:

chmod +x *.sh




---

Usage Instructions

Run Audio Extraction

Use Extractor.sh to download audio files from YouTube playlists:

./Extractor.sh

Follow the prompts to:

Set the base directory for downloads.

Name the playlist folder.

Provide the YouTube playlist URL.

Optionally zip the audio files after downloading.


Update Scripts and Dependencies

Keep scripts and packages up to date with updaterX.sh:

./updaterX.sh

Download Videos

Use vidX.sh to download videos from YouTube playlists:

./vidX.sh

Compress Files

Use zipX.sh to compress downloaded media into a ZIP file:

./zipX.sh


---

Logs and Cleanup

Logs

Logs are saved in the logs directory within your chosen playlist folder:

download.log: Records successful downloads.

failed.log: Logs failed downloads.



Cleanup

Automatically deletes old logs and temporary files (older than 30 days) during script execution.

Manual cleanup can be performed by running the appropriate functions in the scripts.



---

License

This project is licensed under the MIT License.


