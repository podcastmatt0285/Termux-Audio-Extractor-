Termux Audio Extractor

A collection of Termux scripts for extracting and managing audio and video content from YouTube playlists efficiently.

Features

Audio Extraction: Download audio from YouTube playlists in MP3 format.

Video Download: Download entire videos from YouTube.

Automatic Updates: Keep your scripts and dependencies up-to-date.

File Management: Organize downloaded files into directories and optionally compress them into ZIP files.

Logs: Track successes and failures through detailed logs.


Files and Scripts

1. Extractor.sh

Main script for downloading audio files from YouTube playlists.

Converts videos into MP3 format and organizes them into directories.

Includes optional ZIP compression and automated cleanup.


2. updaterX.sh

Keeps the scripts and required dependencies updated.

Checks for new versions of packages and installs them as needed.


3. vidX.sh

Downloads full videos from YouTube playlists.

Organizes videos into directories.


4. zipX.sh

Compresses downloaded audio or video files into a ZIP archive.

Cleans up original files after successful zipping.


Prerequisites

Termux app installed on your Android device.

Storage permissions enabled for Termux.

An active internet connection.


Installation

1. Clone the repository:

git clone https://github.com/podcastmatt0285/Termux-Audio-Extractor-.git


2. Navigate to the repository folder:

cd Termux-Audio-Extractor-


3. Make the scripts executable:

chmod +x *.sh



Usage

Extractor.sh

Run the audio extraction script:

./Extractor.sh

Follow the prompts to:

Set the base directory for downloads.

Name the playlist directory.

Provide the YouTube playlist URL.

Decide whether to compress the files.


updaterX.sh

Run the updater script to ensure all dependencies and scripts are up to date:

./updaterX.sh

vidX.sh

Download full videos from YouTube:

./vidX.sh

zipX.sh

Manually compress downloaded files:

./zipX.sh

Logs

logs Directory: Created within your playlist folder.

Log Files:

download.log — General logs for downloads.

failed.log — Records of failed downloads.



Cleanup

Automatically deletes logs and temporary files older than 30 days during script execution.

Manually triggered cleanup available within some scripts.


License

This project is licensed under the MIT License.


---

Next Steps:

1. Ensure File Descriptions Are Accurate: Double-check if each script performs as described.


2. Check Dependencies: If specific scripts require additional tools or packages, include them in the README.


3. Add Examples (Optional): Include example outputs or use cases to guide users further.


4. Contributing Section (Optional): Encourage others to contribute, report issues, or suggest improvements.