#!/usr/bin/python3
import email
import configparser
import re
from datetime import datetime
from dateutil import parser
import logging
import subprocess
import os
import requests
from imapclient import IMAPClient
import json
import pytz
from subprocess import PIPE, run

# globals
_script_dir = os.path.dirname(os.path.realpath(__file__))
_log_path = '/tmp/get_sunset_time.log'
_config_path = '%s/../etc/email_addr_config.ini' % _script_dir

def setup():
    global config

    # Set up logging
    logging.basicConfig(filename=_log_path,level=logging.INFO)
    
    # Get date/time info
    logging.info('****************************************')
    logging.info('get_sunset_times.py started at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

    # Read in list of approved email addresses:
    config = configparser.ConfigParser()
    config.sections()
    config.read(_config_path)
    logging.info('read in configfile: %s', _config_path)


def get_coordinates():
    group_file = '%s/../../my_group' % _script_dir
    my_group = subprocess.check_output(['cat', group_file]).decode()
    my_group_parsed = re.sub('[ \n]', '', my_group)
    lat = config['latitude'][my_group_parsed]
    logging.info('lat for %s is %s', my_group_parsed, lat)
    lon = config['longitude'][my_group_parsed]
    logging.info('lon for %s is %s', my_group_parsed, lon)
    return (lat, lon)
            

def get_sunset_time(lat, lon):
    command = ['{}/get_timezone.py'.format(_script_dir)]
    result = run(command, stdout=PIPE, stderr=PIPE)
    group_timezone = result.stdout.decode().rstrip('\n')
    logging.info('group_timezone is %s', group_timezone)

    try:
        r = requests.get('https://api.sunrise-sunset.org/json?lat={}\&lng={}&date=today'.format(lat, lon))
        json_result = json.loads(r.content.decode())
    except:
        logging.error('Failed to read timezone!')
        sys.exit(1)

    sunset_utc = json_result['results']['sunset'] + ' +0000'
    logging.info('Sunset UTC: {}'.format(sunset_utc))
    sunset_utc_dt = datetime.strptime(sunset_utc, '%H:%M:%S %p %z')
    logging.info('Sunset UTC: {}'.format(sunset_utc_dt))
    sunset_local_dt = sunset_utc_dt.astimezone(pytz.timezone(group_timezone)).strftime('%H:%M')
    logging.info('Sunset local: {}'.format(sunset_local_dt))
    
    return sunset_local_dt

def teardown():
    logging.info('****************************************')
    logging.info('get_sunset_times.py exited at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

# main
setup()
(lat, lon) = get_coordinates()
sunset = get_sunset_time(lat, lon)
print(sunset)
teardown()
exit(0)
