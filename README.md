# EMLI Exam
This repository contains various scripts and programs used for a wildlife camera mini-project. It’s not however a mini version of a project, it’s a mini-project. The project includes components for camera control, drone control, and communication over MQTT.


## Structure
- `camera/`: Contains scripts for controlling the camera, including external triggering, looping, and motion detection.
- `camera/cgi-scripts`: Contains common gateway interface scripts.
- `drone/`: Contains scripts for controlling the drone and logging WiFi data.
- `esp8266_count_mqtt/`: Contains an Arduino program for an ESP8266 module that communicates over MQTT.
- `raspberry_pico/`: Contains an Arduino program for a Raspberry Pi Pico.
- `cloud_annotation.sh`: A script for annotating photos in cloud.
- `mqtt_to_servo.sh`: A script for controlling a servo over MQTT.
- `pico_serial_to_mqtt.sh`: A script for sending data from a Raspberry Pi Pico over MQTT.


## Setup
1. Clone the repository.
2. Install the necessary dependencies.
3. Configure the scripts and programs with your specific hardware and network settings.
4. Create a .env-secrets file and specify the following properties:


## Usage
Run the scripts or upload the Arduino programs to your hardware. See the individual scripts and programs for more detailed usage instructions.

## .env-secrets
MQTT_SERVER: The address of your MQTT server.  
MQTT_PORT: The port your MQTT server is running on.  
MQTT_TOPIC_TRIGGER: The MQTT topic for triggering the camera.  
MQTT_TOPIC_RAIN: The MQTT topic for the rain sensor.  
MQTT_USERNAME: The username for your MQTT server.  
MQTT_PASSWORD: The password for your MQTT server.  
SERIAL_PORT: The serial port for communication with the Raspberry Pi Pico.  
CAMERA_SSIDS: The SSIDs of the camera WiFi networks.  
WIFI_PASSWORD: The password for the WiFi networks.  
CAMERA_IP: The IP address of the camera.  
GITHUB_USERNAME: The username used for accessing GitHub.  
GITHUB_KEY: A personal access token that allows authentication and authorization with GitHub APIs.  
DB_USER: The username used for database access.  
DB_PASS: The password for the database user.  
DB_NAME: The name of the database to connect to.  
DB_HOST: The hostname or IP address of the database server.  
