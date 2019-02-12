#!/usr/bin/python
# import RPi.GPIO as GPIO
import pigpio
import time
import threading
import random
import optparse
from enum import Enum

class Color(Enum):
    RED    = 1
    ORANGE = 2
    YELLOW = 3
    GREEN  = 4
    CYAN   = 5
    BLUE   = 6
    PURPLE = 7
    WHITE  = 8

class Threshold(int):
    WHITE_HOT  = 110
    RED_HOT    = 90
    ORANGE     = 75
    YELLOW     = 65
    GREEN      = 50
    CYAN       = 32
    BLUE       = 15
    PURPLE     = 0
    WHITE_COLD = -10
    RED_COLD   = -20

class RedDC(int):
    RED   = 255
    GREEN = 0
    BLUE  = 0

class OrangeDC(int):
    RED   = 255
    GREEN = 50
    BLUE  = 0

class YellowDC(int):
    RED   = 255
    GREEN = 255
    BLUE  = 0
    
class GreenDC(int):
    RED   = 0
    GREEN = 255
    BLUE  = 0

class CyanDC(int):
    RED   = 0
    GREEN = 255
    BLUE  = 255

class BlueDC(int):
    RED   = 0
    GREEN = 0
    BLUE  = 255

class PurpleDC(int):
    RED   = 128
    GREEN = 0
    BLUE  = 128

class WhiteDC(int):
    RED   = 255
    GREEN = 255
    BLUE  = 255

parser = optparse.OptionParser()

parser.add_option('-c', '--color', dest="color",
                  help="set color", default="white")
parser.add_option('-s', '--state', dest="state",
                  help="set state", default="")
parser.add_option('-t', '--temp_color', dest="temp_color",
                  help="set color from temp", default=-100)

options, args = parser.parse_args()

RED_GPIO=26
GREEN_GPIO=16
BLUE_GPIO=13

pi = pigpio.pi()

def gpio_init(gpio_pin):
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)
    GPIO.setup(gpio_pin,GPIO.OUT)

def gpio_setup():
    gpio_init(RED_GPIO)
    gpio_init(GREEN_GPIO)
    gpio_init(BLUE_GPIO)

def led_on(gpio_pin):
    GPIO.output(gpio_pin,GPIO.HIGH)

def led_off(gpio_pin):
    GPIO.output(gpio_pin,GPIO.LOW)

def blink(delay, gpio_pin):
    # print "LED on, delay %d", delay
    led_on(gpio_pin)
    time.sleep(delay)
    # print "LED off"
    led_off(gpio_pin)
    time.sleep(delay)

def slow_to_fast_blink(gpio_pin):
    delay = 0.5
    for i in range(50):
        blink(delay, gpio_pin)
        if (delay > .3):
            delay -= 0.05
        elif (delay > .20):
            delay -= 0.025
        elif (delay > .10):
            delay -= 0.01

def fast_to_slow_blink(gpio_pin):
    delay = 0.09
    for i in range(25):
        blink(delay, gpio_pin)
        if (delay < .20):
            delay += 0.01
        elif (delay < .3):
            delay += 0.025
        elif (delay < .5):
            delay += 0.05

def run_gpio(gpio_pin, option):
    if (option == 0):
        while 1:
            slow_to_fast_blink(gpio_pin)
            fast_to_slow_blink(gpio_pin)
    elif (option == 1):
        while 1:
            fast_to_slow_blink(gpio_pin)
            slow_to_fast_blink(gpio_pin)
        
def run():
    t = threading.Thread(target=run_gpio, args=(RED_GPIO,0))
    t2 = threading.Thread(target=run_gpio, args=(ORANGE_GPIO,1))
    t.start()
    t2.start()

def get_color_dc(led_color, set_color):
    if (set_color == Color.RED):
        if (led_color == Color.RED):
            return RedDC.RED
        if (led_color == Color.GREEN):
            return RedDC.GREEN
        if (led_color == Color.BLUE):
            return RedDC.BLUE
    if (set_color == Color.ORANGE):
        if (led_color == Color.RED):
            return OrangeDC.RED
        if (led_color == Color.GREEN):
            return OrangeDC.GREEN
        if (led_color == Color.BLUE):
            return OrangeDC.BLUE
    if (set_color == Color.YELLOW):
        if (led_color == Color.RED):
            return YellowDC.RED
        if (led_color == Color.GREEN):
            return YellowDC.GREEN
        if (led_color == Color.BLUE):
            return YellowDC.BLUE
    if (set_color == Color.GREEN):
        if (led_color == Color.RED):
            return GreenDC.RED
        if (led_color == Color.GREEN):
            return GreenDC.GREEN
        if (led_color == Color.BLUE):
            return GreenDC.BLUE
    if (set_color == Color.CYAN):
        if (led_color == Color.RED):
            return CyanDC.RED
        if (led_color == Color.GREEN):
            return CyanDC.GREEN
        if (led_color == Color.BLUE):
            return CyanDC.BLUE
    if (set_color == Color.BLUE):
        if (led_color == Color.RED):
            return BlueDC.RED
        if (led_color == Color.GREEN):
            return BlueDC.GREEN
        if (led_color == Color.BLUE):
            return BlueDC.BLUE
    if (set_color == Color.PURPLE):
        if (led_color == Color.RED):
            return PurpleDC.RED
        if (led_color == Color.GREEN):
            return PurpleDC.GREEN
        if (led_color == Color.BLUE):
            return PurpleDC.BLUE
    if (set_color == Color.WHITE):
        if (led_color == Color.RED):
            return WhiteDC.RED
        if (led_color == Color.GREEN):
            return WhiteDC.GREEN
        if (led_color == Color.BLUE):
            return WhiteDC.BLUE
    
def color_merge(color1, weight1, color2, weight2):
    red_dc1 = get_color_dc(Color.RED, color1)
    red_dc2 = get_color_dc(Color.RED, color2)
    pi.set_PWM_dutycycle(RED_GPIO,int((red_dc1*weight1+red_dc2*weight2)/(weight1+weight2)))
    green_dc1 = get_color_dc(Color.GREEN, color1)
    green_dc2 = get_color_dc(Color.GREEN, color2)
    pi.set_PWM_dutycycle(GREEN_GPIO,int((green_dc1*weight1+green_dc2*weight2)/(weight1+weight2)))
    blue_dc1 = get_color_dc(Color.BLUE, color1)
    blue_dc2 = get_color_dc(Color.BLUE, color2)
    pi.set_PWM_dutycycle(BLUE_GPIO,int((blue_dc1*weight1+blue_dc2*weight2)/(weight1+weight2)))

def set_color_from_temp(tmp):
    temp = int(tmp)
    if (temp >=Threshold.WHITE_HOT):
        white()
    elif (temp >= Threshold.RED_HOT):
        color_merge(Color.WHITE,  (temp-Threshold.RED_HOT),    Color.RED,    (Threshold.WHITE_HOT-temp))
    elif (temp >= Threshold.ORANGE):
        color_merge(Color.RED,    (temp-Threshold.ORANGE),     Color.ORANGE, (Threshold.RED_HOT-temp))
    elif (temp >= Threshold.YELLOW):
        color_merge(Color.ORANGE, (temp-Threshold.YELLOW),     Color.YELLOW, (Threshold.ORANGE-temp))
    elif (temp >= Threshold.GREEN):
        color_merge(Color.YELLOW, (temp-Threshold.GREEN),      Color.GREEN,  (Threshold.YELLOW-temp))
    elif (temp >= Threshold.BLUE):
        color_merge(Color.GREEN,  (temp-Threshold.BLUE),       Color.BLUE,   (Threshold.GREEN-temp))
    elif (temp >= Threshold.PURPLE):
        color_merge(Color.BLUE,   (temp-Threshold.PURPLE),     Color.PURPLE, (Threshold.BLUE-temp))
    elif (temp >= Threshold.WHITE_COLD):
        color_merge(Color.PURPLE, (temp-Threshold.WHITE_COLD), Color.WHITE,  (Threshold.PURPLE-temp))
    elif (temp >= Threshold.RED_COLD):
        color_merge(Color.WHITE,  (temp-Threshold.RED_COLD),   Color.RED,    (Threshold.WHITE_COLD-temp))
    else:
        red()

def red():
    pi.set_PWM_dutycycle(RED_GPIO,   255)
    pi.set_PWM_dutycycle(GREEN_GPIO, 0)
    pi.set_PWM_dutycycle(BLUE_GPIO,  0)

def orange():
    pi.set_PWM_dutycycle(RED_GPIO,   255)
    pi.set_PWM_dutycycle(GREEN_GPIO, 50)
    pi.set_PWM_dutycycle(BLUE_GPIO,  00)
    
def yellow():
    pi.set_PWM_dutycycle(RED_GPIO,   255)
    pi.set_PWM_dutycycle(GREEN_GPIO, 255)
    pi.set_PWM_dutycycle(BLUE_GPIO,  0)

def green():
    pi.set_PWM_dutycycle(RED_GPIO,   0)
    pi.set_PWM_dutycycle(GREEN_GPIO, 255)
    pi.set_PWM_dutycycle(BLUE_GPIO,  0)

def cyan():
    pi.set_PWM_dutycycle(RED_GPIO,   0)
    pi.set_PWM_dutycycle(GREEN_GPIO, 255)
    pi.set_PWM_dutycycle(BLUE_GPIO,  255)

def blue():
    pi.set_PWM_dutycycle(RED_GPIO,   0)
    pi.set_PWM_dutycycle(GREEN_GPIO, 0)
    pi.set_PWM_dutycycle(BLUE_GPIO,  255)

def purple():
    pi.set_PWM_dutycycle(RED_GPIO,   128)
    pi.set_PWM_dutycycle(GREEN_GPIO, 0)
    pi.set_PWM_dutycycle(BLUE_GPIO,  128)

def white():
    pi.set_PWM_dutycycle(RED_GPIO,   255)
    pi.set_PWM_dutycycle(GREEN_GPIO, 255)
    pi.set_PWM_dutycycle(BLUE_GPIO,  255)

def random_color():
    pi.set_PWM_dutycycle(RED_GPIO,   random.randint(0,255))
    pi.set_PWM_dutycycle(GREEN_GPIO, random.randint(0,255))
    pi.set_PWM_dutycycle(BLUE_GPIO,  random.randint(0,255))

def leds_off():
    pi.set_PWM_dutycycle(RED_GPIO,   0)
    pi.set_PWM_dutycycle(GREEN_GPIO, 0)
    pi.set_PWM_dutycycle(BLUE_GPIO,  0)
    
#main
# gpio_setup()
if (options.temp_color != -100):
    set_color_from_temp(options.temp_color)
elif (options.color == "red"):
    red()
elif (options.color == "orange"):
    orange()
elif (options.color == "yellow"):
    yellow()
elif (options.color == "green"):
    green()
elif (options.color == "blue"):
    blue()
elif (options.color == "cyan"):
    cyan()
elif (options.color == "purple"):
    purple()
elif (options.color == "white"):
    white()

if (options.state == "off"):
    leds_off()
elif (options.state == "on"):
    white()

pi.stop()
