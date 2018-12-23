#!/usr/bin/python
import email
import configparser
import re
from datetime import datetime
from dateutil import parser
import logging
import subprocess
import os
from imapclient import IMAPClient

# globals
_script_dir = os.path.dirname(os.path.realpath(__file__))
_log_path = '/tmp/get_timezone.log'
_config_path = '%s/../etc/email_addr_config.ini' % _script_dir

def setup():
    global config

    # Set up logging
    logging.basicConfig(filename=_log_path,level=logging.INFO)
    
    # Get date/time info
    logging.info('****************************************')
    logging.info('get_timezone.py started at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

    # Read in list of approved email addresses:
    config = configparser.ConfigParser()
    config.sections()
    config.read(_config_path)
    logging.info('read in configfile: %s', _config_path)


def get_timezone():
    group_file = '%s/../../my_group' % _script_dir
    my_group = subprocess.check_output(['cat', group_file])
    my_group_parsed = re.sub('[ \n]', '', my_group)
    tz = config['timezones'][my_group_parsed]
    logging.info('tz for %s is %s', my_group_parsed, tz)
    return tz
            
def teardown():
    logging.info('****************************************')
    logging.info('get_timezone.py exited at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

# main
setup()
print(get_timezone())
teardown()
exit(0)
