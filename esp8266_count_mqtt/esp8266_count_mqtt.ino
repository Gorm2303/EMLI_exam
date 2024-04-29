#include <ESP8266WiFiMulti.h>
#include <ESP8266HTTPClient.h>
#include <PubSubClient.h>

// Wi-Fi and MQTT Clients
ESP8266WiFiMulti WiFiMulti;
WiFiClient espClient;
PubSubClient mqttClient(espClient);

// MQTT Server settings
const char* mqtt_server = "MQTT_SERVER";
const int mqtt_port = MQTT_SERVERPORT;
const char* mqtt_username = "MQTT_USERNAME";
const char* mqtt_password = "MQTT_KEY";
const char* mqtt_topic = "MQTT_TOPIC";

// GPIO pin for the interrupt
#define GPIO_INTERRUPT_PIN 4
volatile bool publish_flag = false;
volatile unsigned long count = 0;

// ISR for handling button press
ICACHE_RAM_ATTR void count_isr() {
  publish_flag = true;
  count++;
}

// Setup configuration
void setup() {
  Serial.begin(115200);
  pinMode(GPIO_INTERRUPT_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(GPIO_INTERRUPT_PIN), count_isr, FALLING);

  WiFi.persistent(false);
  WiFi.mode(WIFI_STA);
  WiFiMulti.addAP(WIFI_SSID, WIFI_PASSWORD);

  mqttClient.setServer(mqtt_server, mqtt_port);
  connectToWiFiAndMQTT();
}

// Main program loop
void loop() {
  if (WiFiMulti.run() != WL_CONNECTED || !mqttClient.connected()) {
    connectToWiFiAndMQTT();
  }

  if (publish_flag && mqttClient.connected()) {
    publishData();
    publish_flag = false;  // Reset the flag after attempting to publish
  }
}

// Function to handle data publishing
void publishData() {
  char payload[10];
  sprintf(payload, "%lu", count);
  if (mqttClient.publish(mqtt_topic, payload)) {
    Serial.println("Data published successfully");
    count = 0;  // Reset count after publishing
  } else {
    Serial.println("Failed to publish data");
  }
}

// Function to ensure WiFi and MQTT are connected
void connectToWiFiAndMQTT() {
  // Check WiFi connection
  if (WiFiMulti.run() != WL_CONNECTED) {
    Serial.println("Connecting to WiFi...");
    delay(1000); // Short delay to allow WiFi to establish
  }

  // Check MQTT connection
  if (!mqttClient.connected()) {
    Serial.println("Connecting to MQTT...");
    mqttClient.connect("mqttClientID", mqtt_username, mqtt_password); // Use a unique client ID
    while (!mqttClient.connected()) {
      Serial.print("MQTT connect failed, rc=");
      Serial.print(mqttClient.state());
      Serial.println("; try again in 5 seconds");
      delay(5000);  // wait 5 seconds before retrying
      mqttClient.connect("mqttClientID", mqtt_username, mqtt_password);
    }
    Serial.println("MQTT Connected!");
  }
}
