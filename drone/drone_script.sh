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

    # Get list of directories and iterate
    local directories=$(curl -s -X POST "http://$CAMERA_IP/cgi-bin/list_files.sh" -d "directory=camera/camera")
    echo "Debug: Found these: $directories"
    for path in $directories; do
        if [[ "$path" =~ /$ ]]; then
            echo "Debug: Found directory $path"
            local files=$(curl -s -X POST "http://$CAMERA_IP/cgi-bin/list_files.sh" -d "directory=camera/camera/$path")

            for file in $files; do
                if [[ "$file" =~ \.json$ ]]; then
                    echo "Debug: Found JSON file $file"
                    local json_file_path="${path}${file}"
                    local jpg_file="${path}${file%json}jpg"
		    echo "Debug: this photo will be downloaded: $jpg_file"

                    # Check and update JSON file if not already marked
                    if ! grep -q '"Drone Copy":' "./pictures/$json_file_path"; then
                        echo "Debug: File $file has not been copied yet"
                        local epoch_time=$(date +%s)
                        curl -X POST "http://$CAMERA_IP/cgi-bin/update_json.sh?file=$json_file_path" -d '{"Drone Copy": {"Drone ID": "WILDDRONE-001", "Seconds Epoch": '"$epoch_time"'}}'

                        # Download JSON and corresponding JPEG file
                        echo "Debug: Downloading JSON and corresponding JPEG for $file"
                        wget -P ./pictures/$path "$camera_base/$jpg_file"
                        wget -P ./pictures/$path "$camera_base/$json_file_path"
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
