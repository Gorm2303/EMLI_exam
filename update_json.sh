#!/bin/bash

# Define the Content-Type
echo "Content-Type: text/plain"
echo ""

# Read POST data from stdin
read POST_DATA

# Extract the filename from the query string
FILENAME=$(echo "$QUERY_STRING" | sed 's/^.*file=\([^&]*\).*$/\1/')

# Define the path to the file
FILE_PATH="/usr/local/apache2/htdocs/camera/camera/${FILENAME}"

# Check if the file exists
if [[ ! -f "$FILE_PATH" ]]; then
    echo "Error: File does not exist"
    exit 1
fi

# Merge the POST data with the existing data in the JSON file
jq -s '.[0] * .[1]' "$FILE_PATH" <(echo "$POST_DATA") > "$FILE_PATH.tmp" && mv "$FILE_PATH.tmp" "$FILE_PATH"

if [[ $? -eq 0 ]]; then
    echo "File updated successfully"
else
    echo "Failed to update file"
    exit 1
fi