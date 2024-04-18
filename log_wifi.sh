#!/bin/bash

# File to store the log data
logfile="./wifi_logfile.log"

# Function to log WiFi details
log_wifi_details() {
    # Read the second line (skipping the header) from /proc/net/wireless which contains the data
    # awk is used to extract the Link Quality and Signal Level
    read -r link_quality signal_level < <(awk 'NR==3 {print int($3 * 10/7), $4}' /proc/net/wireless)
    
    # Get current epoch time
    epoch_time=$(date +%s)

    # Append the data to a logfile
    echo "$epoch_time, Link Quality: $link_quality%, Signal Level: $signal_level dBm" >> $logfile
}

# Main execution loop
while true; do
    log_wifi_details
    # Delay for a certain interval, e.g., every 30 seconds
    sleep 1
done

