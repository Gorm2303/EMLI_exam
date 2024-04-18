#!/bin/bash

# Load the environment variables
source ./.env_secrets

# Function to scan for WiFi networks and connect to camera SSIDs
function search_and_connect() {
    echo "Scanning for camera WiFi networks..."
    available_ssids=$(nmcli dev wifi | awk '{print $2}' | tail -n +2)  # List available SSIDs

    for ssid in "${CAMERA_SSIDS[@]}"; do
        if echo "$available_ssids" | grep -wq "$ssid"; then
            echo "Found camera network: $ssid"
            echo "Attempting to connect..."
            nmcli dev wifi connect "$ssid" password "${WIFI_PASSWORD[@]}"  # Replace 'camera_password' with actual password
            if [ $? -eq 0 ]; then
                echo "Connected successfully to $ssid"
                echo "Offloading data..."
                # Simulate data offloading process
                # Add commands here to fetch and store data from the camera
                sleep 5  # Simulate some processing time
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

# Main execution loop
while true; do
    search_and_connect
    echo "Waiting for next flight cycle..."
    sleep 1  # Wait for 60 seconds before the next cycle
done
