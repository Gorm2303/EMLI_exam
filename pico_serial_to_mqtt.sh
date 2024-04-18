#!/bin/bash

# Load the environment variables
source ./.env_secrets

# Configure stty for serial communication
stty -F $SERIAL_PORT cs8 115200 ignbrk -brkint -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke noflsh -ixon -crtscts

# Open the serial port for reading
exec 3<$SERIAL_PORT

# Read from the serial port
while read -r line <&3; do
    if [[ "$line" == *"{\"wiper_angle\": 0, \"rain_detect\": 1}"* ]]; then
        # Publish to MQTT when rain is detected
        mosquitto_pub -h $MQTT_SERVER -p $MQTT_PORT -t $MQTT_TOPIC_RAIN -u $MQTT_USERNAME -P $MQTT_PASSWORD -m "Wipe lens"
        echo "Rain detected, message sent to wipe lens"
    fi
done