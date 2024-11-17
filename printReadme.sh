#!/bin/bash

# Function to print a colorful divider
print_divider() {
  local color_code="$1"
  
  echo -e "\n\033[${color_code}m--------------------------------------------------------------------\033[0m"
}

# Function to print a message with a specific color
print_colored() {
  local color_code="$1"
  local message="$2"
  
  echo -e "\033[${color_code}m$message\033[0m"
}

# Set color codes
GREEN_COLOR="\033[32m"
YELLOW_COLOR="\033[33m"
RESET_COLOR="\033[0m"

cd Termux-Audio-Extractor-  # Assuming the directory name is correct

# Check if README.md exists
if [ -f "README.md" ]; then
  print_divider $GREEN_COLOR
  print_colored $YELLOW_COLOR  "Welcome to the Termux-Audio-Extractor README!"
  print_divider $GREEN_COLOR
  
  # Use 'cat' to display the file contents
  cat README.md
  
  print_divider $GREEN_COLOR
  
else
  echo "README.md not found."
fi
