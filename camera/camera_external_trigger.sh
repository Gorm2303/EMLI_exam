#!/bin/bash

# Load the environment variables
source ../.env_secrets

# Path to take_photo.sh script
PHOTO_SCRIPT_PATH="./take_photo.sh"

# Function to handle received messages
handle_message() {
    echo "Trigger received: $1"
    # Call take_photo.sh with "External" trigger
    bash "$PHOTO_SCRIPT_PATH" "External"
}

# Subscribe to MQTT topic and handle each message
mosquitto_sub -h $MQTT_SERVER -p $MQTT_PORT -t $MQTT_TOPIC_TRIGGER -u $MQTT_USERNAME -P $MQTT_PASSWORD | while read -r line
do
    handle_message "$line"
done