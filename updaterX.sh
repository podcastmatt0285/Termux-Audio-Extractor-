#!/bin/bash

pkg update -y && pkg upgrade -y

# Function to check if Git is installed
function check_git() {
    if command -v git &> /dev/null; then
        echo "Git is installed."
    else
        echo "Git is not installed. Installing Git..."
        pkg update -y
        pkg install git -y
    fi
}

# Function to update Git
function update_git() {
    echo "Updating Git..."
    pkg update -y
    pkg upgrade git -y
}

# Main script
check_git
update_git

# Verify Git installation
echo "Git version:"
git --version

# Ensure ~/.shortcuts/ dir exists 
mkdir ~/.shortcuts/

# Navigate to the Extractor directory
cd ~/Termux-Audio-Extractor-

# Discard any local changes to Extractor.sh
git checkout -- Extractor.sh
git checkout -- updaterX.sh
git checkout -- vidX.sh
git checkout -- zipX.sh
git checkout -- syncX.sh
git checkout -- compressX.sh
git checkout -- dcomX.sh
git checkout -- shareX.sh
git checkout -- messageX.py

# Pull the latest changes from the repository
git pull

# Copy the updated scripts to the shortcuts directory
cp Extractor.sh ~/.shortcuts/
cp updaterX.sh ~/.shortcuts/
cp vidX.sh ~/.shortcuts/
cp zipX.sh ~/.shortcuts/
cp syncX.sh ~/.shortcuts/
cp compressX.sh ~/.shortcuts/
cp dcomX.sh ~/.shortcuts/
cp shareX.sh ~/.shortcuts/
cp messageX.py ~/.shortcuts

# Ensure the scripts are executable
chmod +x ~/.shortcuts/Extractor.sh
chmod +x ~/.shortcuts/updaterX.sh
chmod +x ~/.shortcuts/vidX.sh
chmod +x ~/.shortcuts/zipX.sh
chmod +x ~/.shortcuts/syncX.sh
chmod +x ~/.shortcuts/compressX.sh
chmod +x ~/.shortcuts/dcomX.sh
chmod +x ~/.shortcuts/shareX.sh
chmod +x ~/.shortcuts/messageX.py
chmod +x Extractor.sh
chmod +x updaterX.sh
chmod +x vidX.sh
chmod +x zipX.sh
chmod +x syncX.sh
chmod +x compressx.sh
chmod +x dcomx.sh
chmod +x shareX.sh
chmod +x messageX.py

# Ensure storage permissions are granted 
cd ~/storage
termux-setup-storage