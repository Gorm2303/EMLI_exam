#!/bin/bash

# Print HTTP header
echo "Content-Type: text/plain"
echo ""

# Read POST data from stdin
read POST_DATA

# Extract the directory from the POST data
DIRECTORY=$(echo "$POST_DATA" | sed 's/^.*directory=\([^&]*\).*$/\1/')

# Specify the base directory
BASE_DIRECTORY="/var/www/html"

# Combine the base directory with the directory from the POST data
FULL_DIRECTORY="${BASE_DIRECTORY}/${DIRECTORY}"

# Check if directory exists
if [ -d "$FULL_DIRECTORY" ]; then
    # List files in the directory
    ls -1p $FULL_DIRECTORY
else
    echo "Directory not found."
fi
# curl -X POST "http://192.168.100.17:8080/cgi-bin/list_files.sh" -d 'directory=subfolder1'