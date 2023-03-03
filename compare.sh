#!/bin/bash

# Set the names and paths of the apk files using positional parameters
first_apk="$1"
second_apk="$2"

# Set the name and path of the log file with a timestamp
log_file="apk_diff_$(date +%Y-%m-%d_%H-%M-%S).log"

# Check if both files exist
if [ -f "$first_apk" ] && [ -f "$second_apk" ]; then
    # Check if apktool and diff tool are available
    if command -v apktool >/dev/null 2>&1 && command -v diff >/dev/null 2>&1; then
        # Decode the apk files using apktool
        echo "Decompiling both APK files..."
        apktool d -f -o first_apk "$first_apk" >/dev/null 2>&1
        apktool d -f -o second_apk "$second_apk" >/dev/null 2>&1

        # Ask the user which changes they want to compare
        echo -e "\033[38;5;208mWhich changes do you want to compare?\033[0m"
        echo "1. Resources"
        echo "2. Smali"
        echo "3. Everything"
        read -p "Enter your choice: " choice

        # Display only those changes based on user input
        if [ $choice -eq 1 ]; then
            output=$(diff --color=always -r first_apk/res second_apk/res)
            if [ -z "$output" ]; then
                echo -e "\033[38;5;208mNo changes were found in resources.\033[0m"
            else
                echo "$output" | tee resources_changes_$log_file
                echo -e "\033[38;5;208mLogs have been saved!!\033[0m"
            fi
        elif [ $choice -eq 2 ]; then
            output=$(diff --color=always -r first_apk/smali second_apk/smali)
            if [ -z "$output" ]; then
                echo -e "\033[38;5;208mNo changes were found in smali.\033[0m"
            else
                echo "$output" | tee smali_changes_$log_file
                echo -e "\033[38;5;208mLogs have been saved!!\033[0m"
            fi
        elif [ $choice -eq 3 ]; then
            output=$(diff --color=always -r first_apk second_apk)
            if [ -z "$output" ]; then
                echo -e "\033[38;5;208mNo changes were found.\033[0m"
            else
                echo "$output" | tee every_changes_$log_file
                echo -e "\033[38;5;208mLogs have been saved!!\033[0m"
            fi
        else
            echo "Invalid input."
        fi

        # Delete the decoded folders
        rm -rf first_apk second_apk

    else
        # Echo a message if one or both tools are not available
        echo -e "\033[31;1mApktool or diff tool not found. Please make sure you have both tools in your system.\033[0m"
    fi
else
    # Echo a message if one or both files do not exist
    echo "One or both apk files do not exist."
fi
