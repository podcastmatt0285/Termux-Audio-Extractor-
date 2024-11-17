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

# Pull the latest changes from the repository
git pull

# Copy the updated scripts to the shortcuts directory
cp Extractor.sh ~/.shortcuts/
cp updaterX.sh ~/.shortcuts/
cp vidX.sh ~/.shortcuts/

# Ensure the scripts are executable
chmod +x ~/.shortcuts/Extractor.sh
chmod +x ~/.shortcuts/updaterX.sh
chmod +x ~/.shortcuts/vidX.sh
chmod +x Extractor.sh
chmod +x updaterX.sh
chmod +x vidX.sh

# Ensure storage permissions are granted 
cd ~/storage
termux-setup-storage
