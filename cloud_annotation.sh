#!/bin/bash

# Directory where images and JSON files are stored
IMAGE_DIR="/path/to/save/data"

# Navigate to the image directory
cd "$IMAGE_DIR"

# Function to annotate an image and update its JSON file
function annotate_image() {
    local image_file="$1"
    local json_file="${image_file%.jpg}.json"

    # Check if the image has already been annotated
    if jq -e '.Annotation' "$json_file" > /dev/null; then
        echo "Image already annotated: $image_file"
    else
        # Run Ollama to annotate the image
        echo "Annotating image: $image_file"
        local annotation_text=$(ollama run llava:7b "describe $image_file")
        
        # Check for successful annotation
        if [ -z "$annotation_text" ]; then
            echo "Failed to annotate image: $image_file"
        else
            # Update the JSON file with the annotation
            jq --arg text "$annotation_text" '. + {"Annotation": {"Source": "Ollama:7b", "Text": $text}}' "$json_file" > "${json_file}.tmp" && mv "${json_file}.tmp" "$json_file"
            echo "Annotation added to $json_file"
        fi
    fi
}

# Iterate over each JPG image in the directory
find . -type f -name '*.jpg' | while read -r image_path; do
    annotate_image "$image_path"
done

# Add and commit JSON metadata files
echo "Adding updated JSON files to git..."
git add *.json
git commit -m "Updated JSON metadata with annotations"
git push
echo "All changes have been pushed to the repository."
