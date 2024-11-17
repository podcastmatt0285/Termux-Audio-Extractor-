#!/bin/bash

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