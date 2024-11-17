Installation and Setup Guide for Termux Audio Extractor

1. Install Required Apps

Install Termux, Termux:API, and Termux:Widget from F-Droid or your app store.


2. Grant Termux Permissions

To allow Termux access to your device's storage, open Termux and run:

termux-setup-storage

This step is essential for saving downloaded files to your device.

3. Clone the Repository

Install Git and download the repository:

pkg install git
git clone https://github.com/podcastmatt0285/Termux-Audio-Extractor-
cd Termux-Audio-Extractor-

4. Execute the Updater Script

Make the updater script executable and run it:

chmod +x updaterX.sh
bash updaterX.sh

This script will install dependencies (e.g., yt-dlp, ffmpeg, and termux-api) and automatically set up the Termux Widget for easy access.

5. Test the Widget

Add a Termux Widget to your home screen:

1. Long-press on your home screen and select "Widgets."


2. Locate Termux:Widget and drag it to your desired location.



Test the widget:

1. Tap the widget and select updaterX.sh to ensure dependencies are correctly installed.




6. Run the Extractor Script

From the widget, run Extractor.sh:

1. Enter the required inputs as prompted:

Base Directory: Save location for MP3 files. Defaults to /storage/music/termux.

Playlist Directory Name: Subfolder for organization. Defaults to Beat_That.

YouTube Playlist URL: Paste your playlist URL here.

Zip Option: Enter y to compress files into a .zip.



2. The script will handle downloading, converting, and organizing the files.



7. Enjoy Your Audio

Access the audio files in the specified directory.

