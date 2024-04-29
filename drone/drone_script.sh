#!/bin/bash

# Load the environment variables
source ../.env_secrets

# Function to scan for WiFi networks and connect to camera SSIDs
function search_and_connect() {
    echo "Scanning for camera WiFi networks..."
    available_ssids=$(nmcli dev wifi | awk '{print $2}' | tail -n +2)  # List available SSIDs

    for ssid in "${CAMERA_SSIDS[@]}"; do
        if echo "$available_ssids" | grep -wq "$ssid"; then
            echo "Found camera network: $ssid"
            echo "Attempting to connect..."
            nmcli dev wifi connect "$ssid" password "${WIFI_PASSWORD[@]}"  # Connect with password
            if [ $? -eq 0 ]; then
                echo "Connected successfully to $ssid"
                
                # Set camera's time to drone's system time
                set_camera_time
                
                # Offload data
                echo "Offloading data..."
                offload_data "$ssid"
                
                echo "Data offloading completed for $ssid."
            else
                echo "Failed to connect to $ssid"
            fi
            echo "Disconnecting from $ssid..."
            nmcli con down "$ssid"
            echo "Disconnected."
        else
            echo "Camera network $ssid not found."
        fi
    done
}

# Function to set camera's time to the drone's system time
function set_camera_time() {
    local drone_time=$(date +"%Y-%m-%d %T")
    # This assumes the camera server accepts a POST request to set time
    curl -X POST -d "time=$drone_time" http://$CAMERA_IP/cgi-bin/sync_time.sh
    echo "Camera time set to drone time: $drone_time"
}

# Function to offload data
function offload_data() {
    local ssid=$1
    local camera_base="http://$CAMERA_IP/camera/camera"  # Base URL for the camera
    echo "Debug: Starting offload for camera at $camera_base"

    # Download directory listing and parse for directories
    echo "Debug: Fetching directories from $camera_base"
    local directories=$(curl -s "$camera_base" | grep -Po '(?<=href=")[^"]*')
    
    for path in $directories; do
        # Ensure path ends with '/' to confirm it's a directory
        if [[ "$path" =~ /$ ]]; then
            local folder="${camera_base}/${path}"
            # Remove double slashes except for protocol part
            folder=$(echo $folder | sed 's#//\([^/]\)#/\1#g')

            echo "Debug: Found directory $path"
            echo "Debug: Processing folder $folder"

            # Check and download each file in the folder
            echo "Debug: Fetching files from $folder"
            local files=$(curl -s "$folder" | grep -Po '(?<=href=")[^"]*')
            
            for file in $files; do
                echo "Debug: Found file $file"
                if [[ "$file" =~ \.json$ ]]; then
                    echo "Debug: Found JSON file $file"

                    # Check if this file has already been copied
                    if ! grep -q '"Drone Copy":' "./pictures/$folder$file"; then
                        echo "Debug: File $file has not been copied yet"

                        # Update JSON file on camera server before downloading
                        local epoch_time=$(date +%s)
                        echo "Debug: Posting update to $folder$file"
                        curl -X POST "$folder$file" -d '{"Drone Copy": {"Drone ID": "WILDDRONE-001", "Seconds Epoch": '"$epoch_time"'}}'

                        # Now download the photo and JSON file
                        echo "Debug: Downloading JSON and corresponding JPEG for $file"
                        wget -P ./pictures/$folder "$folder${file%json}jpg"
                        wget -P ./pictures/$folder "$folder$file"
                    else
                        echo "Debug: File $file has already been copied, skipping"
                    fi
                fi
            done
        fi
    done
    echo "Debug: Offload complete for camera at $camera_base"
}

# Main execution loop
while true; do
    echo "Connected successfully to wifi"
                
    # Set camera's time to drone's system time
    set_camera_time
                
    # Offload data
    echo "Offloading data..."
    offload_data "wifi"
                
    echo "Data offloading completed for wifi."
    echo "Waiting for next flight cycle..."
    sleep 5  # Wait for 5 seconds before the next cycle
done
