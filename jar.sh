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

# Show jar Files Comparison in the center
clear
echo ""
COLUMNS=$(tput cols)
title="jar Files Comparison"
printf "${PURPLE}%*s\n${NC}" $(((${#title} + $COLUMNS) / 2)) "$title"
echo ""

# Set the names and paths of the jar files using positional parameters.
first_jar="$1"
second_jar="$2"

# pwd variable
dir=$(pwd)

# Check if there are jar files in the current directory
if ls *.jar >/dev/null 2>&1; then # This command will list all the jar files and redirect the output to /dev/null
    # Ask the user to select the first jar file
    echo -e "${ORANGE}Please select the first jar file:${NC}"
    select first_jar in *.jar; do
        if [ -f "$first_jar" ]; then
            echo ""
            echo -e "${normal_red}You selected: $first_jar${NC}"
            echo ""
            sleep 2
            break
        else
            echo -e "${PEACH}Invalid selection! Enter the right choice again:${NC}"
            echo ""
        fi
    done

    # Ask the user to select the second jar file
    echo -e "${ORANGE}Please select the second jar file:${NC}"
    select second_jar in *.jar; do
        if [ -f "$second_jar" ]; then
            echo ""
            echo -e "${normal_green}You selected: $second_jar${NC}"
            echo ""
            sleep 2
            break
        else
            echo -e "${PEACH}Invalid selection! Enter the right choice again:${NC}"
            echo ""
        fi
    done

    # Set the name and path of the log file with a timestamp
    log_file="$(date +%Y-%m-%d_%H-%M-%S).log"

    # Check if both files exist
    if [ -f "$first_jar" ] && [ -f "$second_jar" ]; then
        # Check if apktool and diff tool are available
        if command -v apktool >/dev/null 2>&1 && command -v diff >/dev/null 2>&1; then
            # Decode the jar files using apktool
            echo -e "${GREEN}Decompiling both jar files...${NC}"
            echo ""
            apktool d -f -o first_jar "$first_jar" >/dev/null 2>&1
            apktool d -f -o second_jar "$second_jar" >/dev/null 2>&1

            echo -e "${PEACH}Here is the comparison result:${NC}"
            output=$(diff --color=always -r first_jar second_jar)
            if [ -z "$output" ]; then
                echo ""
                echo -e "${BLUE}No changes were found.${NC}"
                echo ""
            else
                echo ""
                echo "$output" | tee jar_changes_$log_file
                echo ""
                echo -e "${GREEN}The comparison result's logs are saved. You can find them here:${NC}"
                echo "$dir"
                echo ""
            fi

            # Delete the decoded folders
            rm -rf first_jar second_jar

        else
            # Echo a message if one or both tools are not available
            echo -e "${PEACH}Apktool or diff tool not found. Please make sure you have both tools in your system.${NC}"
        fi
    else
        # Echo a message if one or both files do not exist
        echo -e "${PEACH}One or both jar files do not exist.${NC}"
    fi

else # This is the else block for the ls command above. It will execute if there are no jar files in the current directory.
    # Echo a message to inform the user to keep both jar files in the current directory.
    echo -e "${PEACH}No jar files found in the current directory. Please keep both jar files in the directory:${NC}"
    echo "$dir"
fi
