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




Installation and Setup Guide for vidX.sh

1. Install Required Apps

Download Termux, Termux:API, and Termux:Widget from F-Droid or your app store.


2. Grant Termux Permissions

Run the following command in Termux to enable storage access:

termux-setup-storage

3. Clone the Repository

Install Git and download the project files:

pkg install git
git clone https://github.com/podcastmatt0285/Termux-Audio-Extractor-
cd Termux-Audio-Extractor-

4. Run the Updater Script

Make the updater script executable and run it:

chmod +x updaterX.sh
bash updaterX.sh

This installs necessary dependencies and configures the environment.

5. Test the Widget

Add the Termux Widget to your home screen.

Test the widget by running updaterX.sh from it to confirm setup.

6. Run vidX.sh

From the Termux Widget, execute vidX.sh and follow the prompts:

1. Enter the Base Directory where videos will be stored. Default: /storage/videos/termux.


2. Specify the Playlist Directory Name to organize downloads.


3. Provide the YouTube Playlist URL for the videos you wish to download.


4. Choose whether to compress the downloaded files into a ZIP archive (enter y for yes or n for no).



7. Access Your Videos

Downloaded (and optionally zipped) video files will be organized in the specified directory.



Installation and Usage Guide for updaterX.sh

1. Run the Script

To update and sync the latest changes for the Termux scripts, run:

bash updaterX.sh

2. What the Script Does

Ensures the ~/.shortcuts/ directory exists for Termux Widget scripts.

Resets local changes to Extractor.sh, updaterX.sh, and vidX.sh.

Pulls the latest changes from the repository.

Copies updated scripts into the ~/.shortcuts/ directory.

Sets the scripts as executable for Termux Widget.


3. Verify the Update

Ensure the latest versions of the scripts are present in the ~/.shortcuts/ directory and accessible from the Termux Widget.
