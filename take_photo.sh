#!/bin/bash

# sudo apt install libimage-exiftool-perl jq

# Directory based on current date
DIR=$(date +%F)
mkdir -p "$DIR"

# Filename based on the current time
FILENAME=$(date +%H%M%S_%3N).jpg
FILEPATH="$DIR/$FILENAME"

# Take a photo
raspistill -o $FILEPATH

# Log Photo captured
echo "$(date) - Photo captured" >> /path/to/logfile.log


# Extract metadata from the photo
EXIF_ISO=$(exiftool -ISO $FILEPATH | awk -F': ' '{print $2}')
EXIF_EXPOSURE_TIME=$(exiftool -ExposureTime $FILEPATH | awk -F': ' '{print $2}')
EXIF_SUBJECT_DISTANCE=$(exiftool -SubjectDistance $FILEPATH | awk -F': ' '{print $2}')

# Creation date with timezone and milliseconds
CREATE_DATE=$(date '+%Y-%m-%d %H:%M:%S.%3N+02:00')

# Epoch time in milliseconds
EPOCH_MILLIS=$(date +%s%3N)

# Prepare JSON metadata
JSON_FMT='{
  "File Name": "%s",
  "Create Date": "%s",
  "Create Seconds Epoch": %d,
  "Trigger": "Time",
  "Subject Distance": "%s m",
  "Exposure Time": "%s",
  "ISO": %d
}'
printf "$JSON_FMT" "$FILENAME" "$CREATE_DATE" "$EPOCH_MILLIS" "$EXIF_SUBJECT_DISTANCE" "$EXIF_EXPOSURE_TIME" "$EXIF_ISO" | jq . > "$DIR/$(basename $FILEPATH .jpg).json"

echo "Photo and metadata saved to $DIR"
