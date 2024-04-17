#!/bin/bash

# MQTT Topic and Broker Settings
MQTT_SERVER="io.adafruit.com"
MQTT_PORT=1883
MQTT_TOPIC="YOUR_USERNAME/feeds/rain"
MQTT_USERNAME="YOUR_USERNAME"
MQTT_PASSWORD="YOUR_PASSWORD"

# Subscribe to MQTT topic and control servo based on the message
mosquitto_sub -h $MQTT_SERVER -p $MQTT_PORT -t $MQTT_TOPIC -u $MQTT_USERNAME -P $MQTT_PASSWORD | while read -r message; do
    echo "Received message: $message"
    if [[ "$message" == "Wipe lens" ]]; then
        echo "Activating servo to wipe lens..."
        python3 /path/to/control_servo.py 0
        sleep 1
        python3 /path/to/control_servo.py 180
        sleep 1
        python3 /path/to/control_servo.py 0
    fi
done
