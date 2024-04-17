import RPi.GPIO as GPIO
import time
import sys

# sudo pip3 install paho-mqtt RPi.GPIO

SERVO_PIN = 15  # GPIO pin where the servo is connected

GPIO.setmode(GPIO.BCM)
GPIO.setup(SERVO_PIN, GPIO.OUT)

# Set up PWM on the pin
pwm = GPIO.PWM(SERVO_PIN, 50)  # Set PWM to 50Hz
pwm.start(0)

def set_angle(angle):
    duty_cycle = angle / 18 + 2
    pwm.ChangeDutyCycle(duty_cycle)
    time.sleep(0.8)
    pwm.ChangeDutyCycle(0)  # Stop sending a signal

if __name__ == '__main__':
    angle = int(sys.argv[1])
    set_angle(angle)
    pwm.stop()
    GPIO.cleanup()
