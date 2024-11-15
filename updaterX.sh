#!/bin/bash

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

# Ensure the script in the shortcuts directory is executable
chmod +x ~/.shortcuts/Extractor.sh
chmod +x ~/.shortcuts/updaterX.sh
chmod +x ~/.shortcuts/vidX.sh

echo "Extractor, updaterX, vidX have been updated and copied to ~/.shortcuts/"
