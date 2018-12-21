#!/usr/bin/python
import email
import configparser
import re
import datetime
import logging
from imapclient import IMAPClient

max_text_size = 32768

def setup():
    global dayofweek
    global config

    # Set up logging
    logging.basicConfig(filename='read_email.log',level=logging.INFO)
    logging.info('read_email.py started:')
    
    # Get date/time info
    now = datetime.datetime.now()
    dayofweek = now.strftime("%a")
    logging.info(now.strftime("%Y-%m-%d %H:%M"))

    # Read in list of approved email addresses:
    config = configparser.ConfigParser()
    configfile = '../etc/email_addr_config.ini' 
    config.sections()
    config.read(configfile)
    logging.info('read in configfile: %s', configfile)


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
    have_message = False
    have_photo = False
    
    # Check email, generate daily_message and daily_photo files
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
        most_recent_text_date = 0
        target_photo_uid = 0
        most_recent_photo_date = 0
        for uid, message_data in response.items():
            email_msg = email.message_from_string(message_data['BODY[HEADER]'])
            email_date = email_msg.get('Date')
            is_photo = (message_data['RFC822.SIZE'] > max_text_size)
            if is_photo:
                if (most_recent_photo_date < email_date):
                    most_recent_photo_date = email_date
                    target_photo_uid = uid
            else:
                if (most_recent_text_date < email_date):
                    most_recent_text_date = email_date
                    target_text_uid = uid

        logging.info('Found text email (uid %d) from %s',
                     target_text_uid, most_recent_text_date)
        logging.info('Found photo email (uid %d) from %s',
                     target_photo_uid, most_recent_photo_date)

        # Download target messages in full
        if (target_text_uid):
            logging.info('Downloading text email...')
            text_email = client.fetch(target_text_uid, 'RFC822')
        if (target_photo_uid):
            logging.info('Downloading photo email...')
            photo_email = client.fetch(target_photo_uid, 'RFC822')

        # Parse text email - should just have one item in text_email
        for uid, message_data in text_email.items():
            email_message = email.message_from_string(message_data['RFC822'])
            from_address = re.sub('[<>]', '',
                                  email_message.get('From').split(" ")[-1])
            logging.info('Parsing email from: %s', from_address)
            logging.info('Sent: %s', email_message.get('Date'))

            # Generate daily_message or daily_photo files for this email
            for part in email_message.walk():
                if part.get_content_type() == 'text/plain':
                    message_text = part.get_payload()
                    message_text_parsed = re.sub('[ \n]', '',
                                                 message_text)
                    if len(message_text_parsed) > 1:
                        logging.info(' ** Found message text!')
                        open('daily_message', 'wb').write(message_text)

        # Parse photo email - should just have one item in photo_email
        for uid, message_data in photo_email.items():
            email_message = email.message_from_string(message_data['RFC822'])
            from_address = re.sub('[<>]', '',
                                  email_message.get('From').split(" ")[-1])
            logging.info('Parsing email from: %s', from_address)
            logging.info('Sent: %s', email_message.get('Date'))

            # Generate daily_message or daily_photo files for this email
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
                            open('daily_message', 'wb').write(message_text)
                if part.get_content_type() == 'image/jpeg' or \
                   part.get_content_type() == 'image/png':
                    logging.info(' ** Found photo!')
                    open('daily_photo', 'wb').write(
                        part.get_payload(decode=True))
                    

def teardown():
    logging.info('Exiting at time: %s',
                 datetime.datetime.now().strftime("%Y-%m-%d %H:%M"))

# main
setup()
read_emails()
teardown()                        
