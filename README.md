Termux Audio Extractor

Termux Audio Extractor is a versatile and user-friendly script designed for music enthusiasts who want to download and manage YouTube playlists directly on their Termux-enabled Android devices. This script utilizes the power of yt-dlp to extract audio, convert it to MP3, and organize the files efficiently. It's an ideal tool for building a local music library while embracing the simplicity of the Termux environment.


---

Table of Contents

1. Introduction


2. Features


3. Requirements


4. Usage

Beginner-Friendly Defaults

Running the Script



5. Advanced Features

UpdaterX Widget Setup

Video Downloader Script



6. Sample Logs


7. Notifications


8. Troubleshooting


9. Acknowledgments


10. License


11. Contact




---

Introduction

Termux Audio Extractor makes downloading YouTube playlists and converting them into high-quality MP3 files seamless. It is designed for Android devices running Termux and is perfect for music enthusiasts looking to curate their personal music libraries.


---

Features

Download Entire Playlists: Fetch and download entire YouTube playlists with ease.

MP3 Conversion: Automatically convert videos to MP3 format for convenient playback.

Customizable Settings: Input desired directories and playlist URLs for a personalized experience.

Progress Notifications: Termux notifications keep you informed about download progress and completion.

Error Handling: Logs failed downloads and provides notifications for troubleshooting.

Automatic Cleanup: Removes old logs and temporary files to keep your device organized.

ZIP Compression: Compress downloaded files into a ZIP archive for easy sharing and storage.



---

Requirements

Ensure the following tools are downloaded and installed:

F-Droid: Download F-Droid

Termux: Download Termux

Termux API: Download Termux API


Optional:

Termux Widget: Download Termux Widget for easy access to the script.



---

Usage

This script simplifies the process of downloading, converting, and organizing music from YouTube playlists.

Beginner-Friendly Defaults

If you are new to Termux, press Enter when asked to input parameters. The script will use the following defaults:

Base Directory: /data/data/com.termux/files/home/storage/music/termux

Playlist Directory Name: Beat_That

YouTube Playlist URL: https://www.example.com/playlist?list=XYZ


Running the Script

1. Install Git:

pkg install git


2. Clone the Repository:

git clone https://github.com/podcastmatt0285/Termux-Audio-Extractor-.git  
cd Termux-Audio-Extractor-


3. Make the Script Executable:

chmod +x Extractor.sh


4. Run the Script:

./Extractor.sh



Follow the prompts to specify directories and playlists or use the default settings.


---

Advanced Features

UpdaterX Widget Setup

The UpdaterX script ensures your Extractor.sh script stays updated and accessible via a home screen widget.

Steps:

1. Create a Shortcuts Folder:

mkdir -p ~/.shortcuts


2. Copy the Script to Shortcuts:

cp updaterX.sh ~/.shortcuts/


3. Add Termux Widget to Home Screen:

Long-press on your home screen.

Select "Widgets" and drag the Termux:Widget to your desired location.



4. Run the Script via Widget:
Tap the widget to update or execute the script directly from your home screen.




---

Video Downloader Script

This script downloads full videos from YouTube playlists.

Features:

Full Video Downloads: Downloads complete MP4 files.

Logging and Notifications: Provides logs and progress notifications.

ZIP Compression: Compresses video files into a ZIP archive.


Usage:

1. Make the Script Executable:

chmod +x vidX.sh


2. Run the Script:

./vidX.sh




---

Sample Logs

Here’s a sample download.log:

[2024-11-16 10:34:12] INFO: Download started for playlist: MyPlaylist
[2024-11-16 10:35:45] INFO: Download complete: Track01.mp3
[2024-11-16 10:36:02] ERROR: Failed to download Track02.mp3. Reason: Network timeout
[2024-11-16 10:36:10] INFO: ZIP archive created: MyPlaylist.zip


---

Notifications

Example Notifications

Standard Notification:

✅ Termux Audio Extractor  
Download Complete: MyPlaylist.zip

Error Notification:

⚠️ Termux Audio Extractor  
Error: Failed to download Track02.mp3


---

Troubleshooting

Ensure all required packages are installed:

yt-dlp, zip, xargs, termux-notification.


Check the logs (download.log and failed.log) for error details.

Use default directories if custom paths fail.



---

Acknowledgments

This project is powered by the following:

yt-dlp

Termux and its robust ecosystem.


Special thanks to contributors and testers who helped improve the script.


---

License

This project is licensed under the MIT License.


---

Contact

For questions or support, email: podcastmatt0285@gmail.com

