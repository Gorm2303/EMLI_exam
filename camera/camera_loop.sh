#!/bin/bash

# Path to the scripts
TAKE_PHOTO_SCRIPT="./take_photo.sh"
MOTION_DETECT_SCRIPT="./motion_detect.py"

# Second counter for time-triggered photos
second_counter=0

# Log file path
LOG_FILE="./logfile.log"

# Loop indefinitely
while true; do
    # Define directory based on the current date
    DIR=$(date +%F)
    mkdir -p "$DIR"

    # Take a photo every second with trigger "Motion"
    bash $TAKE_PHOTO_SCRIPT "Motion"

    # Find the latest jpg file in the current date directory
    current_file_path=$(find "$DIR" -type f -name '*.jpg' | sort | tail -n 1)
    
    # Every 5 minutes, take a photo with trigger "Time"
    if (( second_counter == 300 )); then  # 300 seconds equals 5 minutes
        bash $TAKE_PHOTO_SCRIPT "Time"
        echo "Photo taken with trigger 'Time' every 5 minutes."
        second_counter=0  # Reset counter after taking a time-triggered photo
    fi

    # Check for motion if there is a previous file to compare with
    if [[ -n $prev_file_path && -f $prev_file_path ]]; then
        # Run motion detection
        motion_detected=$(python3 $MOTION_DETECT_SCRIPT $prev_file_path $current_file_path)
        if [[ $motion_detected != *"Motion detected"* ]]; then
            # If no motion is detected, delete the photo unless it's a time-triggered photo
            json_path="${current_file_path%.jpg}.json"
            if [[ $(jq -r '.Trigger' "$json_path") != "Time" ]]; then
                rm $current_file_path
                rm $json_path
                echo "$(date) - No motion detected - Motion-triggered photo and metadata deleted: $current_file_path" | tee -a $LOG_FILE
            fi
        fi
    fi

    # Update the previous file path for motion detection
    prev_file_path=$current_file_path

    # Sleep for 1 second before taking the next photo
    sleep 1

    # Increment the second counter
    ((second_counter++))
done
