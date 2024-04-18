#!/bin/bash

# Load the environment variables
source ./.env_secrets

# Serial Port connected to Pico
SERIAL_PORT="/dev/ttyACM0"

# Open serial port for writing
exec 3>$SERIAL_PORT

# Subscribe to MQTT topic and forward JSON messages to the Pico via serial
mosquitto_sub -h $MQTT_SERVER -p $MQTT_PORT -t $MQTT_TOPIC_RAIN -u $MQTT_USERNAME -P $MQTT_PASSWORD | while read -r message; do
    echo "Received MQTT message: $message"
    if [[ "$message" == "Wipe lens" ]]; then
        echo "Activating servo to wipe lens..."
        
        # Send JSON for angle 0
        json_message_0="{\"wiper_angle\": 0}"
        echo "$json_message_0" >&3
        echo "Sent to Pico: $json_message_0"
        sleep 1  # Sleep to give time for the servo to move

        # Send JSON for angle 180
        json_message_180="{\"wiper_angle\": 180}"
        echo "$json_message_180" >&3
        echo "Sent to Pico: $json_message_180"
        sleep 1  # Sleep to give time for the servo to move

        # Send JSON for angle 0
        json_message_0_back="{\"wiper_angle\": 0}"
        echo "$json_message_0_back" >&3
        echo "Sent to Pico: $json_message_0_back"
    fi
done