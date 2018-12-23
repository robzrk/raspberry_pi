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
_max_text_size = 32768
_target_photo_height = 450
_script_dir = os.path.dirname(os.path.realpath(__file__))
_photo_path = '%s/daily_photo' % _script_dir
_text_path = '%s/daily_text' % _script_dir
_log_path = '/tmp/check_email.log'
_config_path = '%s/../etc/email_addr_config.ini' % _script_dir
_dl_email_info_path = '%s/../etc/downloaded_email.ini' % _script_dir

# TODO remove dup
def setup():
    global dayofweek
    global config

    # Set up logging
    logging.basicConfig(filename=_log_path,level=logging.INFO)
    
    # Get date/time info
    dayofweek = datetime.now().strftime("%a")
    logging.info('****************************************')
    logging.info('check_email.py started at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

    # Read in list of approved email addresses:
    config = configparser.ConfigParser()
    config.sections()
    config.read(_config_path)
    logging.info('read in configfile: %s', _config_path)


# TODO remove dup
def get_todays_group_emails():
    todays_group = config['day_assignments'][dayofweek]
    group_email_addrs = []
    logging.info('Today is a %s day', todays_group)
    for email_addr in config['allowable_emails']:
        this_group = config['allowable_emails'][email_addr]
        if todays_group == 'free_for_all' or this_group == todays_group:
            group_email_addrs.append(email_addr)

    logging.info('Search for emails from: %s', group_email_addrs)
    return group_email_addrs
    
def check_email():
    # Check email, generate daily_text and daily_photo files
    with IMAPClient(host="smtp.gmail.com") as client:
        client.login('sendittopi', 'IwI9YB!S2P&^')
        client.select_folder('INBOX')

        # Which emails to search
        featured_email_addrs = get_todays_group_emails()

        # Build up search expression
        search_expr = []
        for i in range(len(featured_email_addrs)-1):
            search_expr.append('OR')
        for email_addr in featured_email_addrs:
            search_expr.append('FROM')
            search_expr.append(email_addr)
        logging.info('Searching with expression: %s', search_expr)

        # Download some basic info for any message sent by today's group
        messages = client.search(search_expr)
        response = client.fetch(messages, ['RFC822.SIZE'])
        logging.info('Found %d messages', len(response.items()))

        return(update_email_count(len(response.items())))

def update_email_count(updated_group_count):
    todays_group = config['day_assignments'][dayofweek]

    dl_email_info = configparser.ConfigParser()
    dl_email_info.sections()
    dl_email_info.read(_dl_email_info_path)
    logging.info('read in dl_email_info: %s', _dl_email_info_path)
    todays_group_count = int(dl_email_info['group_counts'][todays_group])
    logging.info('cgc: %d ugc: %d', todays_group_count, updated_group_count)

    if (todays_group_count != updated_group_count):
        # Update config with new uid
        dl_email_info.set('group_counts', todays_group,
                          '%d' % updated_group_count)
        try:
            fh = open(_dl_email_info_path, "w+")
            dl_email_info.write(fh)
            fh.close()
        except:
            logging.warning('Failed to write %s', _dl_email_info_path)
            return(-1)

        return(0)
    
    return(-1)
            
            
def teardown():
    logging.info('****************************************')
    logging.info('check_email.py exited at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

# main
setup()
rc = check_email()
if (rc):
    logging.info('Returning %d: No new email found!', rc)
else:
    logging.info('Returning %d: New email found!', rc)
teardown()
exit(rc)
