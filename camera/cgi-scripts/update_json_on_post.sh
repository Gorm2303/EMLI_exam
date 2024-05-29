#!/bin/bash
#located at /usr/lib/cgi-bin/
echo "Content-type: application/json"
echo ""

# Read the POST data
read -n $CONTENT_LENGTH POST_DATA

# Get the path to the JSON file
FILE_PATH="/path/to/your/json/file.json"

# Decode the JSON data and merge it with the existing data in the file
MERGED_DATA=$(echo "$POST_DATA" | jq --slurpfile file $FILE_PATH '.[0] * $file[0]')

# Write the merged data back to the file
echo $MERGED_DATA | jq . > $FILE_PATH