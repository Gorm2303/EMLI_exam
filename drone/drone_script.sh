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
    curl -X POST -d "time=$drone_time" http://$CAMERA_IP/cgi-bin/sync_time.py
    echo "Camera time set to drone time: $drone_time"
}

# Function to offload data
function offload_data() {
    local ssid=$1
    local camera_ip="http://$CAMERA_IP/camera/camera"  # Adjust if necessary

    # Download directory listing
    for folder in $(curl -s "$camera_ip" | grep -Po '(?<=href=")[^"]*'); do
        [[ "$folder" =~ /$ ]] || continue  # Skip non-directory entries
        
        # Check and download each file in the folder
        for file in $(curl -s "$camera_ip/$folder" | grep -Po '(?<=href=")[^"]*'); do
            if [[ "$file" =~ \.json$ ]]; then
                # Check if this file has already been copied
                if ! grep -q '"Drone Copy":' "./pictures/$folder$file"; then
                    # Update JSON file on camera server before downloading
                    local epoch_time=$(date +%s)
                    curl -X POST "$camera_ip/$folder$file" -d '{"Drone Copy": {"Drone ID": "WILDDRONE-001", "Seconds Epoch": '"$epoch_time"'}}'
                    
                    # Now download the photo and JSON file
                    wget -P ./pictures/$folder "$camera_ip/$folder${file%json}jpg"
                    wget -P ./pictures/$folder "$camera_ip/$folder$file"
                fi
            fi
        done
    done
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
