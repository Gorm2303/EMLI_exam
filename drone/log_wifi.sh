#!/bin/bash

# Load the environment variables
source ../.env_secrets

# IP address to ping
ip_address="${CAMERA_IP}"

# Function to log ping details
log_wifi_and_ping() {
    # Read the WiFi link quality and signal level from /proc/net/wireless
    read -r link_quality signal_level < <(awk 'NR==3 {print int($3 * 10/7), $4}' /proc/net/wireless)

    # Ping the IP address with a timeout of 1 second, sending only 1 packet
    ping_result=$(ping -c 1 -W 1 $ip_address)
    
    # Check if ping was successful
    if [ $? -eq 0 ]; then
        # Extract the time in milliseconds
        ping_time=$(echo "$ping_result" | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
        success_status="Success, Ping Time: $ping_time ms"
    else
        success_status="Ping Failed"
    fi
    
    # Get current epoch time
    epoch_time=$(date +%s)

    # Append the data to a log variable
    LOG_MESSAGE="$epoch_time, Link Quality: $link_quality%, Signal Level: $signal_level dBm, Ping Status: $success_status"

    # SQL Command to insert the log into the database
    SQL="INSERT INTO wifi_stats (epoch_time, link_quality, signal_level, success_status) VALUES ('$epoch_time', '$link_quality', '$signal_level', '$success_status');"

    # Execute SQL Command using MySQL
    if ! mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" "$DB_NAME" -e "$SQL"; then
        echo "Failed to insert data"
        exit 1
    else
        echo "Data logged successfully"
    fi
}


log_wifi_and_ping
