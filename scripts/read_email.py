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
_log_path = '%s/read_email.log' % _script_dir
_config_path = '%s/../etc/email_addr_config.ini' % _script_dir

def setup():
    global dayofweek
    global config

    # Set up logging
    logging.basicConfig(filename=_log_path,level=logging.INFO)
    
    # Get date/time info
    dayofweek = datetime.now().strftime("%a")
    logging.info('****************************************')
    logging.info('read_email.py started at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

    # Read in list of approved email addresses:
    config = configparser.ConfigParser()
    config.sections()
    config.read(_config_path)
    logging.info('read in configfile: %s', _config_path)


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
    
def read_emails():
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
        response = client.fetch(messages, ['RFC822.SIZE', 'BODY.PEEK[HEADER]'])
        logging.info('Found %d messages', len(response.items()))

        # Figure out which messages from today's group to download
        target_text_uid = 0
        most_recent_text_date = parser.parse('Mon, 1 Jan 2018 00:00:00 -0600')
        target_photo_uid = 0
        most_recent_photo_date = parser.parse('Mon, 1 Jan 2018 00:00:00 -0600')
        for uid, message_data in response.items():
            email_msg = email.message_from_string(message_data['BODY[HEADER]'])
            email_date = parser.parse(email_msg.get('Date'))
            is_photo = (message_data['RFC822.SIZE'] > _max_text_size)
            if is_photo:
                logging.info('Photo email (uid %d) sent %s', uid, email_date)
                if (most_recent_photo_date < email_date):
                    logging.info('Most recent photo email now uid %d', uid)
                    most_recent_photo_date = email_date
                    target_photo_uid = uid
            else:
                logging.info('Text email (uid %d) sent %s', uid, email_date)
                if (most_recent_text_date < email_date):
                    logging.info('Most recent text email now uid %d', uid)
                    most_recent_text_date = email_date
                    target_text_uid = uid

        logging.info('Selected text email (uid %d) sent %s',
                     target_text_uid, most_recent_text_date)
        logging.info('Selected photo email (uid %d) sent %s',
                     target_photo_uid, most_recent_photo_date)

        # Download target messages in full
        if (target_text_uid):
            logging.info('Downloading text email...')
            text_email = client.fetch(target_text_uid, 'RFC822')
        if (target_photo_uid):
            logging.info('Downloading photo email...')
            try:
                photo_email = client.fetch(target_photo_uid, 'RFC822')
            except:
                logging.warn('Failed downloading photo email!')

        # Parse text email - should just have one item in text_email
        for uid, message_data in text_email.items():
            email_message = email.message_from_string(message_data['RFC822'])
            from_address = re.sub('[<>]', '',
                                  email_message.get('From').split(" ")[-1])
            logging.info('Parsing email from: %s', from_address)
            logging.info('Sent: %s', email_message.get('Date'))

            # Generate daily_text or daily_photo files for this email
            for part in email_message.walk():
                if part.get_content_type() == 'text/plain':
                    message_text = part.get_payload()
                    message_text_parsed = re.sub('[ \n]', '',
                                                 message_text)
                    if len(message_text_parsed) > 1:
                        logging.info(' ** Found message text!')
                        open(_text_path, 'wb').write(message_text)

        # Parse photo email - should just have one item in photo_email
        for uid, message_data in photo_email.items():
            email_message = email.message_from_string(message_data['RFC822'])
            from_address = re.sub('[<>]', '',
                                  email_message.get('From').split(" ")[-1])
            logging.info('Parsing email from: %s', from_address)
            logging.info('Sent: %s', email_message.get('Date'))

            # Generate daily_text or daily_photo files for this email
            for part in email_message.walk():
                # If the photo email has text as well, use it, unless the
                #  text email was more recent
                if part.get_content_type() == 'text/plain':
                    message_text = part.get_payload()
                    message_text_parsed = re.sub('[ \n]', '',
                                                 message_text)
                    if len(message_text_parsed) > 1:
                        if (most_recent_photo_date > most_recent_text_date):
                            logging.info(' ** Found photo message text!')
                            open(_text_path, 'wb').write(message_text)
                if part.get_content_type() == 'image/jpeg' or \
                   part.get_content_type() == 'image/png':
                    logging.info(' ** Found photo!')
                    open(_photo_path, 'wb').write(
                        part.get_payload(decode=True))

# Read in photo height and scale it down, in place, to target height
def resize_photo():
    logging.info('Resizing photo...')
    photo_height = int(subprocess.check_output(['convert', _photo_path,
                                            '-print', '%h', '/dev/null']))
    logging.info('Original photo height: %d', photo_height)
    scale_percentage = '%d%%' % (_target_photo_height * 100 / photo_height)
    if (scale_percentage != "100%"):
        logging.info('Scaling photo to %s of its original size',
                     scale_percentage)
        photo_size = subprocess.check_output(['mogrify', '-resize',
                                              scale_percentage, _photo_path])
    else:
        logging.info('Photo does not need scaling')

def teardown():
    logging.info('****************************************')
    logging.info('read_email.py exited at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

# main
setup()
#read_emails()
resize_photo()
teardown()
