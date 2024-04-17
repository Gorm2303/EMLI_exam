#!/bin/bash

# MQTT server settings
MQTT_SERVER="io.adafruit.com"
MQTT_PORT=1883
MQTT_TOPIC="YOUR_USERNAME/feeds/trigger"
MQTT_USERNAME="YOUR_USERNAME"
MQTT_PASSWORD="YOUR_PASSWORD"

# Path to take_photo.sh script
PHOTO_SCRIPT_PATH="./take_photo.sh"

# Function to handle received messages
handle_message() {
    echo "Trigger received: $1"
    # Call take_photo.sh with "External" trigger
    bash "$PHOTO_SCRIPT_PATH" "External"
}

# Subscribe to MQTT topic and handle each message
mosquitto_sub -h $MQTT_SERVER -p $MQTT_PORT -t $MQTT_TOPIC -u $MQTT_USERNAME -P $MQTT_PASSWORD | while read -r line
do
    handle_message "$line"
done
