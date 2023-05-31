#!/bin/bash

# Define some color variables
GREEN='\033[1m\033[32m'
ORANGE='\033[1m\033[38;5;214m'
PURPLE='\033[1m\033[38;5;140m'
PEACH='\e[1;38;2;255;204;153m'
BLUE='\e[1;1;34m'
normal_red='\033[31m'
normal_green='\033[32m'
NC='\033[0m' # No Color

# Check if user is using termux
if [ -d "$PREFIX" ]; then
    # Check if tput is installed in Termux
    if ! dpkg -s ncurses-utils >/dev/null 2>&1; then
        # Install ncurses-utils if not installed
        pkg install ncurses-utils
    fi
fi

# Show APK Compare Tool text in center
clear
echo ""
COLUMNS=$(tput cols)
title="APK Compare Tool"
printf "${PURPLE}%*s\n${NC}" $(((${#title} + $COLUMNS) / 2)) "$title"
echo ""

# ask user what option they want to compare
echo -e "${ORANGE}Select Your Choice:${NC}"
echo "1. Compare Two APK Files"
echo "2. Compare Two jar Files"
read -p "Enter your choice: " choice

if [ $choice -eq 1 ]; then
    chmod +x apk.sh
    output=$(./apk.sh 2>&1)
    if [[ $output == *"Permission denied"* ]]; then
        bash apk.sh # Run it with bash instead
    else
        ./apk.sh
    fi
elif [ $choice -eq 2 ]; then
    chmod +x jar.sh
    output=$(./jar.sh 2>&1)
    if [[ $output == *"Permission denied"* ]]; then
        bash jar.sh # Run it with bash instead
    else
        ./jar.sh
    fi
fi