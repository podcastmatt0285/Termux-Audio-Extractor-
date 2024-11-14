# Termux Audio Extractor

**Termux Audio Extractor** is a versatile and user-friendly script designed for music enthusiasts who want to download and manage YouTube playlists directly on their Termux-enabled Android devices. This script utilizes the power of `yt-dlp` to extract audio from YouTube playlists and organizes the files efficiently, making it an ideal tool for building a local music library.

## Features

- **Download Entire Playlists**: Fetch and download entire YouTube playlists with ease.
- **MP3 Conversion**: Automatically convert videos to MP3 format for convenient playback.
- **Customizable**: Prompt users to input their desired directories and playlist URLs for a personalized experience.
- **Notifications**: Utilize Termux notifications to keep track of download progress and completion status.
- **Error Handling**: Robust error handling to ensure smooth execution and log any failed downloads.
- **Cleanup**: Automatically clean up old logs and temporary files to keep your device organized.
- **Zipping**: Compress downloaded files into a ZIP archive for easy sharing and storage.

## Requirements
###### You must download each of the following:

- F-Droid

  https://f-droid.org/F-Droid.apk

- Termux

   https://f-droid.org/en/packages/com.termux
- termux-api

   https://f-droid.org/en/packages/com.termux.api

## Usage

Upon running the script, you will be prompted to input your desired base directory, playlist directory name, and YouTube playlist URL. The script will handle the download, conversion, and organization of the audio files.

### Steps:

1. **Enter Base Directory**: Provide the base directory where you want the music to be stored. Default is `/data/data/com.termux/files/home/storage/music/termux`.
2. **Enter Playlist Directory Name**: Specify the directory name for the playlist. Default is `Beat_That`.
3. **Enter YouTube Playlist URL**: Provide the URL of the YouTube playlist you want to download.

The script will then proceed to download, convert, and zip the audio files, notifying you of the progress and any errors encountered.

## Running the Script

### Steps:

1. **Install Git**:
   ```sh
   pkg install git

3. **Clone the Repository**:
   ```sh
   git clone https://github.com/podcastmatt0285/Termux-Audio-Extractor-.git
   cd Termux-Audio-Extractor-

4. **Make the Script Executable**:
   ```sh
   chmod +x Extractor.sh

6. **Run the Script**:
   ```sh
   ./Extractor.sh

## Updating the Script

To make sure you're running the latest version of the Termux Audio Extractor script, follow these steps:

1. **Navigate to the Repository Directory**:
   ```sh
   cd ~/Termux-Audio-Extractor-
   ```

2. **Fetch the Latest Changes from the GitHub Repository**:
   ```sh
   git checkout --Extractor.sh
   git pull
   ```

By regularly updating the repository, you can ensure that you have the latest features and improvements.

## Contributing

Feel free to fork this repository, open issues, and submit pull requests to improve the script. Contributions are welcome and appreciated!

## License

This project is licensed under the MIT License.

## Contact

For any questions or support, please reach out to podcastmatt0285@gmail.com
