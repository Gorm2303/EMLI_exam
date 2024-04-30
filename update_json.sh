#!/bin/bash

# Define the Content-Type
echo "Content-Type: text/plain"
echo ""

# Read POST data from stdin
POST_DATA=$(cat)

# Extract the filename from the query string
FILENAME=$(echo "$QUERY_STRING" | sed 's/^.*file=\([^&]*\).*$/\1/')

# Define the path to the file
FILE_PATH="/var/www/html/${FILENAME}"

# Check if the file exists
if [[ ! -f "$FILE_PATH" ]]; then
    echo "Error: File does not exist"
    exit 1
fi

# Merge the POST data with the existing data in the JSON file
jq '. + input' "$FILE_PATH" <(echo "$POST_DATA") > "$FILE_PATH.tmp" && mv "$FILE_PATH.tmp" "$FILE_PATH"

if [[ $? -eq 0 ]]; then
    echo "File updated successfully"
else
    echo "Failed to update file"
    exit 1
fi