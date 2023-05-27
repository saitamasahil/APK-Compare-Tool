#!/bin/bash

# Define some color variables
GREEN='\033[1m\033[32m'
ORANGE='\033[1m\033[38;5;214m'
PURPLE='\033[1m\033[38;5;140m'
PEACH='\e[1;38;2;255;204;153m'
BLUE='\e[1;1;34m'
normal_red="\033[31m"
normal_green="\033[32m"
NC='\033[0m' # No Color

# Show APK Compare Tool text in middle
clear
echo ""
COLUMNS=$(tput cols)
title="APK Compare Tool"
printf "${PURPLE}%*s\n${NC}" $(((${#title} + $COLUMNS) / 2)) "$title"
echo ""

# Set the names and paths of the apk files using positional parameters
first_apk="$1"
second_apk="$2"

# pwd variable
dir=$(pwd)

# Check if there are any apk files in the current directory
if ls *.apk >/dev/null 2>&1; then # This command will list all the apk files and redirect the output to /dev/null
    # Ask the user to select the first apk file
    echo -e "${ORANGE}Please select the first apk file:${NC}"
    select first_apk in *.apk; do
        if [ -f "$first_apk" ]; then
            echo ""
            echo -e "${normal_red}You selected: $first_apk${NC}"
            echo ""
            sleep 2
            break
        else
            echo -e "${PEACH}Invalid selection!${NC}"
            echo ""
        fi
    done

    # Ask the user to select the second apk file
    echo -e "${ORANGE}Please select the second apk file:${NC}"
    select second_apk in *.apk; do
        if [ -f "$second_apk" ]; then
            echo ""
            echo -e "${normal_green}You selected: $second_apk${NC}"
            echo ""
            sleep 2
            break
        else
            echo -e "${PEACH}Invalid selection!${NC}"
            echo ""
        fi
    done

    # Set the name and path of the log file with a timestamp
    log_file="$(date +%Y-%m-%d_%H-%M-%S).log"

    # Check if both files exist
    if [ -f "$first_apk" ] && [ -f "$second_apk" ]; then
        # Check if apktool and diff tool are available
        if command -v apktool >/dev/null 2>&1 && command -v diff >/dev/null 2>&1; then
            # Decode the apk files using apktool
            echo -e "${GREEN}Decompiling both APK files...${NC}"
            echo ""
            apktool d -f -o first_apk "$first_apk" >/dev/null 2>&1
            apktool d -f -o second_apk "$second_apk" >/dev/null 2>&1

            # Ask the user which changes they want to compare
            echo -e "${ORANGE}Which changes do you want to compare?${NC}"
            echo "1. Resources"
            echo "2. Smali"
            echo "3. Everything"
            read -p "Enter your choice: " choice
            echo ""
            echo -e "${PEACH}Here is the comparison result:${NC}"

            # Display only those changes based on user input
            if [ $choice -eq 1 ]; then
                output=$(diff --color=always -r first_apk/res second_apk/res)
                if [ -z "$output" ]; then
                    echo ""
                    echo -e "${BLUE}No changes were found in resources.${NC}"
                    echo ""
                else
                    echo "$output" | tee resources_changes_$log_file
                    echo ""
                    echo -e "${GREEN}The comparison result's logs are saved. You can find them here:${NC}"
                    echo "$dir"
                    echo ""
                fi
            elif [ $choice -eq 2 ]; then
                output=$(diff --color=always -r first_apk/smali second_apk/smali)
                if [ -z "$output" ]; then
                    echo ""
                    echo -e "${BLUE}No changes were found in smali.${NC}"
                    echo ""
                else
                    echo "$output" | tee smali_changes_$log_file
                    echo ""
                    echo -e "${GREEN}The comparison result's logs are saved. You can find them here:${NC}"
                    echo "$dir"
                    echo ""
                fi
            elif [ $choice -eq 3 ]; then
                output=$(diff --color=always -r first_apk second_apk)
                if [ -z "$output" ]; then
                    echo ""
                    echo -e "${BLUE}No changes were found.${NC}"
                    echo ""
                else
                    echo "$output" | tee every_changes_$log_file
                    echo ""
                    echo -e "${GREEN}The comparison result's logs are saved. You can find them here:${NC}"
                    echo "$dir"
                    echo ""
                fi
            else
                echo "Invalid input."
            fi

            # Delete the decoded folders
            rm -rf first_apk second_apk

        else
            # Echo a message if one or both tools are not available
            echo -e "${PEACH}Apktool or diff tool not found. Please make sure you have both tools in your system.${NC}"
        fi
    else
        # Echo a message if one or both files do not exist
        echo -e "${PEACH}One or both apk files do not exist.${NC}"
    fi

else # This is the else block for the ls command above. It will execute if there are no apk files in the current directory.
    # Echo a message to inform the user to keep both apk files in the current directory.
    echo -e "${PEACH}No apk files found in the current directory. Please keep both apk files in directory:${NC}"
    echo "$dir"
fi
