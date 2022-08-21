#!/usr/bin/python3
import concurrent.futures
import threading
from threading import Lock
from guizero import App, Drawing, PushButton, Window, Text
import random
import math
from PIL import Image, ImageOps
import os
import sys
from os import listdir
from os.path import isfile, join
import time
import logging
import pytz
from datetime import datetime
from dateutil import parser
import subprocess
from subprocess import PIPE, run
import requests
from bs4 import BeautifulSoup
import json

# Globals
_app_height = 480
_app_width = 320
_log_path = '/tmp/pi_gui.log'
_email_loop_delay = 180000
_dt_loop_delay = 50
_date_loop_delay = 30000
_loading_loop_delay = 1000
_weather_text_loop_delay = 60000
_weather_image_loop_delay = 50
_script_dir = os.path.dirname(os.path.realpath(__file__))
_img_dir = _script_dir + '/../images'
_photo_dir = _script_dir + '/../run/symlinks_for_today/photos'
_text_dir = _script_dir + '/../run/symlinks_for_today/messages'
_sender_dir = _script_dir + '/../run/symlinks_for_today/senders'
_date_dir = _script_dir + '/../run/symlinks_for_today/dates'
_progress_path = _script_dir + '/../run/read_email_progress.txt'
_tiny_text_size = 12
_small_text_size = 15
_large_text_size = 70
_weather_img_w = 100
_weather_img_h = 100
_weather_img_x_mov = 1
_weather_img_x1 = -_weather_img_w
_weather_img_x2 = _app_width / 3
_weather_img_y_offset = 100
_weather_img_y_range = 10
_dt_x = _app_width / 2
_dt_x_mov = -3
_drawing_images = []
_email_drawings = []
_dt_drawings = []
_date_drawings = []
_weather_text_drawings = []
_weather_image_drawings = []
_loading_drawings = []
_selected_email = -1
_num_emails = -1
_dt = ''
_date = ''
_weather_image1 = None
_weather_image2 = None
_email_mutex = Lock()
_date_mutex = Lock()
_weather_text_mutex = Lock()
_weather_image_mutex = Lock()
_email_initialized = 0
_date_initialized = 0
_weather_text_initialized = 0
_text_fg_color = 'white'
_text_bg_color = 'black'

def setup():
    global _dayofweek
    global _group_location
    global _group_timezone
    global _group_sunset
    global _dt_sender
    global _dt
    global _cloud_img
    global _cloud_cloud_img
    global _cloud_cloud_rain_img
    global _cloud_hail_img
    global _cloud_sun_img
    global _sun_img
    global _moon_img
    global _cloud_snow_img
    global _cloud_rain3_img
    global _cloud_rain5_img
    global _cloud_haze_img
    global _cloud_lightning_img

    # Set up logging
    logging.basicConfig(filename=_log_path,level=logging.INFO)
    
    # Get date/time info
    _dayofweek = datetime.now().strftime("%a")
    logging.info('****************************************')
    logging.info('gui.py started at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')


    command = ['{}/get_location.py'.format(_script_dir)]
    result = run(command, stdout=PIPE, stderr=PIPE)
    _group_location = result.stdout.decode().rstrip('\n')
    logging.info('group_location: {}'.format(_group_location))

    command = ['{}/get_timezone.py'.format(_script_dir)]
    result = run(command, stdout=PIPE, stderr=PIPE)
    _group_timezone = result.stdout.decode().rstrip('\n')
    logging.info('group_timezone: {}'.format(_group_timezone))

    command = ['{}/get_sunset_time.py'.format(_script_dir)]
    result = run(command, stdout=PIPE, stderr=PIPE)
    _group_sunset = result.stdout.decode().rstrip('\n')
    logging.info('group_sunset: {}'.format(_group_sunset))


    try:
        _cloud_img = Image.open('{}/cloud.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _cloud_cloud_img = Image.open('{}/cloud_cloud.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _cloud_cloud_rain_img = Image.open('{}/cloud_cloud_rain.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _cloud_hail_img = Image.open('{}/cloud_hail.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _cloud_sun_img = Image.open('{}/cloud_sun.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _sun_img = Image.open('{}/sun.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _moon_img = Image.open('{}/moon.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _cloud_snow_img = Image.open('{}/cloud_snow.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _cloud_rain3_img = Image.open('{}/cloud_rain3.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _cloud_rain5_img = Image.open('{}/cloud_rain5.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _cloud_haze_img = Image.open('{}/cloud_haze.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
        _cloud_lightning_img = Image.open('{}/cloud_lightning.png'.format(_img_dir)).resize((_weather_img_w, _weather_img_h))
    except:
        loggin.error('Failed opening one or more images!')
        logging.error('{}'.format(sys.exc_info()[0]))
        sys.exit(1)

def text_display(x, y, text, size, drawing_ids, fg_color, bg_color):
    for xoff in range(-2, 3):
        for yoff in range(-2, 3):
            if xoff == 0 and yoff == 0: continue
            drawing_ids.append(_drawing_w.text(x+xoff, y+yoff, text, size=size,
                                               color=bg_color, font='courier'))
    drawing_ids.append(_drawing_w.text(x, y, text, size=size, color=fg_color,
                                       font='courier'))

def simple_text_display(x, y, text, size, drawing_ids, color):
    drawing_ids.append(_drawing_w.text(x, y, text, size=size, color=color,
                                       font='helvetica'))

def loading_progress_callback():
    read_progress()
    display_progress()

def read_email():
    _email_mutex.acquire()
    try:
        rc = subprocess.call('{}/read_email.py'.format(_script_dir))
    finally:
        _email_mutex.release()

    logging.info('(re)read email finished with rc {}'.format(rc))
    return rc

def read_date():
    global _date

    _date_mutex.acquire()
    try:
        my_date = datetime.now(pytz.timezone(_group_timezone))
        _date = my_date.strftime('%A %b %d %l:%M%p')
    finally:
        _date_mutex.release()

    logging.info('Date: {}'.format(_date))

def read_weather_text():
    global _temp
    global _weather_text
    global _windchill
    global _weather_image1
    global _weather_image2

    logging.info('Updating weather for {}'.format(_group_location))
    _weather_text_mutex.acquire()
    try:
        r = requests.get('https://w1.weather.gov/xml/current_obs/display.php?stid={}'.format(_group_location))
        weather_data = BeautifulSoup(r.content, 'html.parser')
    except:
        _weather_text_mutex.release()
        return

    _temp = int(float(weather_data.temp_f.string))
    logging.info('_temp: {}'.format(_temp))
    weather = weather_data.weather.string
    wind_dir = weather_data.wind_dir.string
    wind_mph = weather_data.wind_mph.string
    humidity = weather_data.relative_humidity.string
    try:
        _windchill = int(float(weather_data.windchill_f.string))
    except:
        _windchill = None

    _weather_text = '{}'.format(weather)
    _weather_text += '\nHumidity {}'.format(humidity)
    _weather_text += '\nWind {} @ {}MPH'.format(wind_dir, wind_mph) 
    logging.info('_weather_text: {}'.format(_weather_text))

    _weather_text_mutex.release()

    now = datetime.now().strftime("%H:%M")
    cmp_now = datetime.strptime(now, '%H:%M')
    try:
        cmp_sunset = datetime.strptime(_group_sunset, '%H:%M')
        if (cmp_now < cmp_sunset):
            is_day = 1
        else:
            is_day = 0
    except:
        logging.warning('Sunset conversion exception!')
        is_day = 0

    _weather_image_mutex.acquire()
    if 'Sunny' in weather:
        if 'Partly' in weather:
            _weather_image1 = _cloud_sun_img
            _weather_image2 = _cloud_img
        elif 'Mostly' in weather:
            _weather_image1 = _sun_img
            _weather_image2 = _cloud_img
        else:
            _weather_image1 = _sun_img
            _weather_image2 = _sun_img
    elif 'Cloud' in weather:
        if 'A Few' in weather:
            if is_day:
                _weather_image1 = _sun_img
                _weather_image2 = _cloud_img
            else:
                _weather_image1 = _moon_img
                _weather_image2 = _cloud_img
        elif 'Partly' in weather:
            if is_day:
                _weather_image1 = _cloud_sun_img
                _weather_image2 = _cloud_img
            else:
                _weather_image1 = _moon_img
                _weather_image2 = _cloud_img
        elif 'Mostly' in weather:
            if is_day:
                _weather_image1 = _cloud_cloud_img
                _weather_image2 = _cloud_cloud_img
            else:
                _weather_image1 = _moon_img
                _weather_image2 = _cloud_cloud_img
        else:
            if is_day:
                _weather_image1 = _cloud_img
                _weather_image2 = _cloud_cloud_img
            else:
                _weather_image1 = _moon_img
                _weather_image2 = _cloud_cloud_img
    elif 'Overcast' in weather:
        _weather_image1 = _cloud_haze_img
        _weather_image2 = _cloud_haze_img
    elif 'Snow' in weather:
        _weather_image1 = _cloud_snow_img
        _weather_image2 = _cloud_snow_img
    elif 'Fair' in weather or 'Clear' in weather:
        if is_day:
            _weather_image1 = _sun_img
            _weather_image2 = _sun_img
        else:
            _weather_image1 = _moon_img
            _weather_image2 = _moon_img
    elif 'Rain' in weather:
        if 'Light' in weather:
            _weather_image1 = _cloud_img
            _weather_image2 = _cloud_rain3_img
        elif 'Heavy' in weather:
            _weather_image1 = _cloud_rain5_img
            _weather_image2 = _cloud_rain5_img
        else:
            _weather_image1 = _cloud_rain3_img
            _weather_image2 = _cloud_rain5_img
    elif 'Thunderstorm' in weather:
        _weather_image1 = _cloud_lightning_img
        _weather_image2 = _cloud_lightning_img
    elif 'Fog' in weather:
        _weather_image1 = _cloud_haze_img
        _weather_image2 = _cloud_haze_img
    _weather_image_mutex.release()
    logging.info('Weather updated')
    
def read_progress():
    global _progress
    fh = open(_progress_path, 'r')
    _progress = fh.read().rstrip('\n')
    fh.close()

def find_email():
    global _dt_sender
    global _dt
    global _dt_date
    global _dp
    global _num_emails

    # get most recent email
    files = [f for f in listdir(_sender_dir) if isfile(join(_sender_dir, f))]
    files.sort()
    _num_emails = len(files)
    
    try:
        filename = files[_selected_email]
    except:
        logging.info('find email called too soon')
        return
        
    try:
        fh = open(join(_sender_dir, filename), 'r')
        _dt_sender = fh.read().rstrip('\n')
        fh.close()
    except:
        logging.error('Failed to open {}'.format(join(_sender_dir, filename)))

    logging.info('uid: {}'.format(filename))
    logging.info('_dt_sender: {}'.format(_dt_sender))

    try:
        fh = open(join(_text_dir, filename), 'r')
        _dt = fh.read().rstrip('\n')
        fh.close()
    except:
        logging.error('Failed to open {}'.format(join(_text_dir, filename)))
        
    logging.info('_dt: {}'.format(_dt))

    try:
        fh = open(join(_date_dir, filename), 'r')
        file_date = fh.read().rstrip('\n')
        fh.close()
    except:
        logging.error('Failed to open {}'.format(join(_date_dir, filename)))

    _dt_date = datetime.strptime(file_date, '%a, %d %b %Y %H:%M:%S %z').strftime('%m/%d/%y %l%p')
    logging.info('_dt_date: {}'.format(_dt_date))

    try:
        im1 = Image.open(join(_photo_dir, filename))
    except:
        logging.error('Failed to open {}'.format(join(_photo_dir, filename)))

    try:
        im1 = ImageOps.exif_transpose(im1)
        extra_width = im1.width - _app_width
        _dp = im1.crop((extra_width / 2, 0, _app_width+(extra_width/2),
                        _app_height+20))
    except:
        logging.error('Failed to crop {}'.format(filename))
            

def display_email():
    clear_email_drawings()
    find_email()
    _email_drawings.append(_drawing_w.image(0, 0, _dp))
    if len(_dt) > 0:
        _email_drawings.append(_drawing_w.rectangle(0, _app_height-40,
                                                    _app_width,
                                                    _app_height-20))
    text_display(10, _app_height-18, 'From {} on {}'.format(_dt_sender,
                                                            _dt_date),
                 _tiny_text_size, _email_drawings, _text_fg_color,
                 _text_bg_color)

def display_dt():
    global _dt_x

    clear_dt_drawings()
    if _dt_x > (len(_dt)*_small_text_size*-1):
        _dt_x += _dt_x_mov
    else:
        _dt_x = _app_width
    simple_text_display(_dt_x, _app_height-42, _dt, _small_text_size,
                        _dt_drawings, 'white')

def display_date():
    clear_date_drawings()
    text_display(10, 2, _date, _small_text_size, _date_drawings, _text_fg_color,
                 _text_bg_color)

def display_progress():
    clear_loading_drawings()
    text_display(50, _app_height/2-30, 'Loading:',
                 _small_text_size, _loading_drawings, _text_fg_color,
                 _text_bg_color)
    text_display(50, _app_height/2, str(_progress),
                 _large_text_size, _loading_drawings, _text_fg_color,
                 _text_bg_color)
    logging.info('progress: {}'.format(str(_progress)))


def get_color(temperature):
    if temperature >= 110:
        return 'white'
    elif temperature >= 100:
        return 'pink'
    elif temperature >= 90:
        return 'red'
    elif temperature >= 80:
        return 'orange'
    elif temperature >= 70:
        return 'yellow'
    elif temperature >= 60:
        return 'green'
    elif temperature >= 30:
        return 'blue'
    elif temperature >= 0:
        return 'purple'
    elif temperature >= -20:
        return 'pink'
    else:
        return 'white'

def display_weather_text():
    clear_weather_text_drawings()
    temp_color = get_color(_temp)
    text_display(100, _app_height/2, _temp, _large_text_size,
                 _weather_text_drawings, temp_color, _text_bg_color)
    text_display(10, 22, _weather_text, _small_text_size,
                 _weather_text_drawings, _text_fg_color,
                 _text_bg_color)

    if _windchill != _temp and _windchill != None and _windchill <= 40:
        windchill_text1 = 'windchill: '
        windchill_text2 = '{}ºF'.format(_windchill)
        windchill_color = get_color(_windchill)
        logging.info('windchill_text: {}{}'.format(windchill_text1,
                                                   windchill_text2))
        text_display(60, 310, windchill_text1, _small_text_size,
                    _weather_text_drawings, _text_fg_color, _text_bg_color)
        text_display(190, 310, windchill_text2, _small_text_size,
                    _weather_text_drawings, windchill_color, _text_bg_color)


def display_weather_image():
    global _weather_img_x1
    global _weather_img_x2
    global _weather_img_y1
    global _weather_img_y2

    if _weather_image1 == None or _weather_image2 == None:
        return
    clear_weather_image_drawings()

    if _weather_img_x1 < _app_width:
        _weather_img_x1 += _weather_img_x_mov
    else:
        _weather_img_x1 = -_weather_img_w

    if _weather_img_x2 < _app_width:
        _weather_img_x2 += _weather_img_x_mov
    else:
        _weather_img_x2 = -_weather_img_w

    _weather_img_y1 = _weather_img_y_range * math.sin(_weather_img_x1 / 20) + \
      _weather_img_y_offset
    _weather_img_y2 = _weather_img_y_range * math.sin(_weather_img_x2 / 20) + \
      _weather_img_y_offset

    _weather_image_drawings.append(_drawing_w.image(_weather_img_x1,
                                                    _weather_img_y1,
                                                    _weather_image1))
    _weather_image_drawings.append(_drawing_w.image(_weather_img_x2,
                                                    _weather_img_y2,
                                                    _weather_image2))

def clear_email_drawings():
    for drawing in _email_drawings:
        _drawing_w.delete(drawing)
    _email_drawings.clear()

def clear_dt_drawings():
    for drawing in _dt_drawings:
        _drawing_w.delete(drawing)
    _dt_drawings.clear()

def clear_date_drawings():
    for drawing in _date_drawings:
        _drawing_w.delete(drawing)
    _date_drawings.clear()

def clear_weather_text_drawings():
    for drawing in _weather_text_drawings:
        _drawing_w.delete(drawing)
    _weather_text_drawings.clear()

def clear_weather_image_drawings():
    for drawing in _weather_image_drawings:
        _drawing_w.delete(drawing)
    _weather_image_drawings.clear()

def clear_loading_drawings():
    for drawing in _loading_drawings:
        _drawing_w.delete(drawing)
    _loading_drawings.clear()

def update_button_enables():
    if _selected_email <= (-1*_num_emails):
        _prev_button.disable()
        _next_button.enable()
        _latest_button.enable()
        _rand_button.enable()
    elif _selected_email >= -1:
        _prev_button.enable()
        _next_button.disable()
        _latest_button.disable()
        _rand_button.enable()
    else:
        _next_button.enable()
        _prev_button.enable()
        _latest_button.enable()
        _rand_button.enable()

def prev_button_push():
    global _selected_email
    logging.info('prev button push: _selected_email: {}'.format(_selected_email))

    if _selected_email <= (-1*_num_emails):
        return
    else:
        _selected_email -= 1
        logging.info('_selected_email now {}'.format(_selected_email))
        update_button_enables()
        quick_refresh()
 
def next_button_push():
    global _selected_email
    logging.info('next button push: _selected_email: {}'.format(_selected_email))

    if _selected_email >= -1:
        return
    else:
        _selected_email += 1
        logging.info('_selected_email now {}'.format(_selected_email))
        update_button_enables()
        quick_refresh()

def rand_button_push():
    global _selected_email

    logging.info('rand button push')
    _selected_email = random.randrange((-1*_num_emails), -1, 1)
    logging.info('rand: {}'.format(_selected_email))
    update_button_enables()
    quick_refresh()

def latest_button_push():
    global _selected_email

    logging.info('latest button push')
    _selected_email = -1
    update_button_enables()
    quick_refresh()

def quick_refresh():
    try:
        global _dt_x
        _dt_x = _app_width / 2
        display_email()
        display_date()
        display_dt()
        display_weather_text()
        display_weather_image()
    except:
        logging.warning('quick_refresh hit {}'.format(sys.exc_info()[0]))
        pass

def email_scheduler():
    global _email_initialized
    while 1:
        read_email()
        _email_initialized = 1
        time.sleep(_email_loop_delay/1000)

def date_scheduler():
    global _date_initialized
    while 1:
        read_date()
        _date_initialized = 1
        time.sleep(_date_loop_delay/1000)

def weather_text_scheduler():
    global _weather_text_initialized
    while 1:
        read_weather_text()
        _weather_text_initialized = 1
        time.sleep(_weather_text_loop_delay/1000)

def model():
    global _progress

    while read_email():
        pass

    _progress = '99%'
    time.sleep(1)
    _app.cancel(loading_progress_callback)

    x = threading.Thread(target=email_scheduler)
    x.start()
    y = threading.Thread(target=date_scheduler)
    y.start()
    z = threading.Thread(target=weather_text_scheduler)
    z.start()

    while ((_email_initialized and _date_initialized and\
            _weather_text_initialized) == 0):
        time.sleep(1)

    clear_loading_drawings()
    done_loading()

    quick_refresh()
    update_button_enables()

def done_loading():
    logging.info('done_loading')

    _prev_button.show()
    _next_button.show()
    _rand_button.show()
    _latest_button.show()
    _prev_button.tk.place(x=0, y=_app_height-100)
    _next_button.tk.place(x=270, y=_app_height-100)
    _rand_button.tk.place(x=90, y=_app_height-100)
    _latest_button.tk.place(x=180, y=_app_height-100)
    _app.repeat(_date_loop_delay, display_date)
    _app.repeat(_dt_loop_delay, display_dt)
    _app.repeat(_weather_text_loop_delay, display_weather_text)
    _app.repeat(_weather_image_loop_delay, display_weather_image)
    _app.repeat(_email_loop_delay, display_email)

def view():
    global _drawing_w
    global _prev_button
    global _next_button
    global _rand_button
    global _latest_button
    global _loading_window
    global _loading_window_text
    global _app

    _app = App(width=_app_width, height=_app_height, layout='auto')
    _app.set_full_screen()
    _app.tk.config(cursor="none")
    _drawing_w = Drawing(_app, width=_app_width, height=_app_height)
    _prev_button = PushButton(_app, command=prev_button_push, text='prev',
                             width=4, height=2, enabled=False)
    _next_button = PushButton(_app, command=next_button_push, text='next',
                             width=4, height=2, enabled=False)
    _rand_button = PushButton(_app, command=rand_button_push, text='rand',
                                width=4, height=2, enabled=False)
    _latest_button = PushButton(_app, command=latest_button_push, text='latest',
                                width=4, height=2, enabled=False)
    _prev_button.hide()
    _next_button.hide()
    _rand_button.hide()
    _latest_button.hide()

    _app.repeat(_loading_loop_delay, loading_progress_callback)
 
    logging.info('Displaying app')
    _app.display()

# Main
if __name__ == "__main__":
    setup()
    x = threading.Thread(target=model)
    x.start()
    view()
