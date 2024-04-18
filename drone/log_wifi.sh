#!/bin/bash

# Load the environment variables
source ./.env_secrets

# File to store the log data
logfile="./wifi.log"

# IP address to ping
ip_address="${CAMERA_IP}"

# Function to log ping details
log_ping_details() {
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

    # Append the data to a logfile
    echo "$epoch_time, Ping Status: $success_status" >> $logfile
}

log_ping_details
