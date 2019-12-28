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
from email.header import decode_header
# globals
_max_text_size = 32768
_target_photo_height = 450
_script_dir = os.path.dirname(os.path.realpath(__file__))
_sender_path = '%s/daily_text_sender' % _script_dir
_log_path = '/tmp/download_email.log'
_config_path = '%s/../etc/email_addr_config.ini' % _script_dir
_dl_email_info_path = '%s/../etc/downloaded_email.ini' % _script_dir

def setup():
    global dayofweek
    global config

    # Set up logging
    logging.basicConfig(filename=_log_path,level=logging.INFO)
    
    # Get date/time info
    dayofweek = datetime.now().strftime("%a")
    logging.info('****************************************')
    logging.info('download_email.py started at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

    # Read in list of approved email addresses:
    config = configparser.ConfigParser()
    config.sections()
    config.read(_config_path)
    logging.info('read in configfile: %s', _config_path)

def get_todays_group_emails():
    todays_group = 'free_for_all'
    group_email_addrs = []
    logging.info('Today is a %s day', todays_group)
    for email_addr in config['allowable_emails']:
        this_group = config['allowable_emails'][email_addr]
        if todays_group == 'free_for_all' or this_group == todays_group:
            group_email_addrs.append(email_addr)

    logging.info('Search for emails from: %s', group_email_addrs)
    return group_email_addrs
    
def download_emails():
    rc = 0
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
        most_recent_text_date = parser.parse('Mon, 1 Jan 2018 00:00:00 -0600')
        most_recent_photo_date = parser.parse('Mon, 1 Jan 2018 00:00:00 -0600')
        email_idx = 0
        for uid, message_data in response.items():
            email_msg = email.message_from_string(message_data['BODY[HEADER]'])
            email_date = parser.parse(email_msg.get('Date'))
            logging.info('Email (uid %d, idx %04d) sent %s',
                         uid, email_idx, email_date)
            try:
                extract_content_from_email(
                    client.fetch(uid, 'RFC822'), True, email_idx)
            except:
                logging.warn('Failed downloading email!')
                return
            email_idx = email_idx + 1
                
def extract_content_from_email(target_emails, use_text_if_found, email_idx):
    # Parse photo email - should just have one item in photo_email
    for uid, message_data in target_emails.items():
        email_message = email.message_from_string(message_data['RFC822'])
        from_address = re.sub('[<>]', '',
                              email_message.get('From').split(" ")[-1])
        display_name = config['email_display_names'][from_address]
        subject = email_message.get('Subject')
        try:
            (value, charset) = decode_header(subject)[0]
            logging.info('charset: %s', charset)
            logging.info('value: %s', value)
        except:
            logging.warn('Could not determine charset')

        try:
            if charset == None:
                charset = 'utf-8'
            subject = value.decode(charset).encode('utf-8')
        except:
            logging.warn('Could not decode charset %s', charset)

        logging.info('Parsing email from: %s', from_address)
        logging.info('Displaying name: %s', display_name)
        logging.info('Sent: %s', email_message.get('Date'))
        logging.info('Subject: %s', subject)
        
        # Generate daily_photo file for this email
        for part in email_message.walk():
            if part.get_content_type() == 'image/jpeg' or \
               part.get_content_type() == 'image/png':
                extension = 'unknown'
                if part.get_content_type() == 'image/jpeg':
                    extension = 'jpg'
                elif part.get_content_type() == 'image/png':
                    extension = 'png'
                write_daily_photo(part.get_payload(decode=True), display_name,
                                  extension, email_idx)

        # Generate daily_text file for this email
        if use_text_if_found and subject != '':
            write_daily_text(subject, display_name, email_idx)

    return 0


def write_daily_photo(message_payload, display_name, extension, email_idx):
    logging.info(' ** Found photo (idx: %04d)!' % (email_idx))
    buf = '%s/%04d_%s.%s' % (_script_dir, email_idx, display_name, extension)
    try:
        fh = open(buf, 'wb')
        fh.write(message_payload)
        fh.close();
    except:
        logging.warning('Failed to write %s', buf)

def write_daily_text(message_text, display_name, email_idx):
    message_text_parsed = re.sub('[ \n]', '', message_text)
    message_text_nl_out = re.sub('[\n\r]', ' ', message_text)
    if len(message_text_parsed) > 1:
        logging.info(' ** Found message text!')
        logging.info(message_text_nl_out)
        buf = '%s/%04d_%s.txt' % (_script_dir, email_idx, display_name)
        try:
            fh = open(buf, 'wb')
            fh.write('%s' % message_text_nl_out)
            fh.close();
        except:
            logging.warning('Failed to write %s', buf)
          
def teardown():
    logging.info('****************************************')
    logging.info('download_email.py exited at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

# main
setup()
download_emails()
teardown()
