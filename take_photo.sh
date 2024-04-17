#!/bin/bash

# Required packages: sudo apt install libimage-exiftool-perl jq

# Base directory and logfile
BASE_DIR="/path/to/photos"
LOG_FILE="/path/to/logfile.log"
mkdir -p $BASE_DIR

# Initialize previous image path and time
previous_image_path=""
last_save_time=0

# Main loop to take photos and check for motion
while true; do
    current_time=$(date +%s) # Current time in seconds since UNIX epoch
    DIR=$(date +%F) # Current date
    mkdir -p "$BASE_DIR/$DIR"

    # Filename based on current time with milliseconds
    FILENAME=$(date +%H%M%S_%3N).jpg
    FILEPATH="$BASE_DIR/$DIR/$FILENAME"

    # Take the photo
    raspistill -o $FILEPATH
    echo "$(date) - Photo captured" >> $LOG_FILE

    # Check for motion if there is a previous image
    if [[ -n "$previous_image_path" ]]; then
        # Assuming motion_detect.py is properly set to output "Motion detected" or "No motion"
        if python3 /path/to/motion_detect.py $previous_image_path $FILEPATH | grep -q "Motion detected"; then
            TRIGGER_TYPE="Motion"
            echo "$(date) - Motion detected. Saving photo with metadata." >> $LOG_FILE
            # Save the metadata for the motion-detected photo
            save_metadata "$FILEPATH" "$TRIGGER_TYPE"
        fi
    fi

    # Save a photo with metadata every 5 minutes
    if ((current_time >= last_save_time + 300)); then
        last_save_time=$current_time
        TRIGGER_TYPE="Time"
        echo "$(date) - Time-based photo save." >> $LOG_FILE
        save_metadata "$FILEPATH" "$TRIGGER_TYPE"
    fi

    # Update the previous image path
    previous_image_path=$FILEPATH
    sleep 1
done

# Function to save metadata
save_metadata() {
    local filepath=$1
    local trigger=$2
    local filename=$(basename $filepath)
    local create_date=$(date -r $filepath '+%Y-%m-%d %H:%M:%S.%3N+02:00')
    local epoch_millis=$(date +%s%3N)

    # Extract metadata using exiftool
    local iso=$(exiftool -ISO $filepath | awk -F': ' '{print $2}')
    local exposure_time=$(exiftool -ExposureTime $filepath | awk -F': ' '{print $2}')
    local subject_distance=$(exiftool -SubjectDistance $filepath | awk -F': ' '{print $2}')

    # Create JSON metadata
    local json_fmt='{
      "File Name": "%s",
      "Create Date": "%s",
      "Create Seconds Epoch": %d,
      "Trigger": "%s",
      "Subject Distance": "%s m",
      "Exposure Time": "%s",
      "ISO": %d
    }'
    printf "$json_fmt" "$filename" "$create_date" "$epoch_millis" "$trigger" "$subject_distance" "$exposure_time" "$iso" | jq . > "${filepath%.jpg}.json"

    echo "Metadata saved for $filename with Trigger: $trigger"
}
