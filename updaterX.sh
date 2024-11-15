#!/bin/bash

# Navigate to the Extractor directory
cd ~/Termux-Audio-Extractor-

# Discard any local changes to Extractor.sh
git checkout -- Extractor.sh

# Pull the latest changes from the repository
git pull

# Copy the updated scripts to the shortcuts directory
cp Extractor.sh ~/.shortcuts/
cp updaterX ~/.shortcuts/
cp vidX.sh ~/.shortcuts/

# Ensure the script in the shortcuts directory is executable
chmod +x ~/.shortcuts/Extractor.sh

echo "Extractor.sh has been updated and copied to ~/.shortcuts/"
