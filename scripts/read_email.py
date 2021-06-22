#!/usr/bin/python3
import threading
import glob
import time
from os import listdir
from os.path import isfile, join
import email
import configparser
import re
from datetime import datetime
from dateutil import parser
import logging
import subprocess
import os
import sys
import math
from imapclient import IMAPClient
from email.header import decode_header
from PIL import Image, ImageOps

# globals
_max_text_size = 32768
_target_photo_height = 480
_script_dir = os.path.dirname(os.path.realpath(__file__))
_photo_dir = _script_dir + '/../run/photos'
_text_dir = _script_dir + '/../run/messages'
_sender_dir = _script_dir + '/../run/senders'
_date_dir = _script_dir + '/../run/dates'
_photo_path = _photo_dir + '/%s'
_text_path = _text_dir + '/%s'
_sender_path = _sender_dir + '/%s'
_date_path = _date_dir + '/%s'
_today_photo_dir = _script_dir + '/../run/symlinks_for_today/photos'
_today_text_dir = _script_dir + '/../run/symlinks_for_today/messages'
_today_sender_dir = _script_dir + '/../run/symlinks_for_today/senders'
_today_date_dir = _script_dir + '/../run/symlinks_for_today/dates'
_email_downloaded_path = _script_dir + '/../run/emails_downloaded.txt'
_today_photo_path = _today_photo_dir + '/%s'
_today_text_path = _today_text_dir + '/%s'
_today_sender_path = _today_sender_dir + '/%s'
_today_date_path = _today_date_dir + '/%s'
_photo_glob_orig = _photo_dir + '/*_orig'
_log_path = '/tmp/read_email.log'
_config_path = '%s/../etc/email_addr_config.ini' % _script_dir
_dl_email_info_path = '%s/../etc/downloaded_email.ini' % _script_dir
_progress_path = _script_dir + '/../run/read_email_progress.txt'
_symlinks_to_create = []
_default_photo = _script_dir + '/../images/umbrella.png'

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
    rc = 0
    # Check email, generate daily_text and daily_photo files
    with IMAPClient(host="smtp.gmail.com") as client:
        client.login('sendittopi', 'zpxmxexbyshzrysm')
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
        uid_list = []
        downloaded_list = []
        logging.info('Checking which email is already downloaded...')
        if isfile(_email_downloaded_path):
            with open(_email_downloaded_path) as f:
                downloaded_list = [line.rstrip() for line in f]
        
        logging.info('downloaded list: {}'.format(downloaded_list))
        for uid, message_data in response.items():
            uid5 = '%05d' % uid
            _symlinks_to_create.append(uid5)
            if str(uid) in downloaded_list:
                continue

            logging.info('Checking if {} is downloaded...'.format(uid))
            if not email_already_downloaded(uid5):
                uid_list.append(uid)
            else:
                # Update file
                try:
                    fh = open(_email_downloaded_path, 'a')
                    fh.write(str(uid) + '\n')
                finally:
                    fh.close()

        logging.info('Create symlinks: {}'.format(_symlinks_to_create))
        return batch_email_dl(client, uid_list)

def batch_email_dl(client, uid_list):
    num_emails_per_batch = 4
    uid_search_expr = ''

    cnt = 0
    num_batches = math.ceil(len(uid_list)/num_emails_per_batch)
    for i in range(0, len(uid_list)):
        uid = uid_list[i]
        uid_search_expr += str(uid) + ','  #trailing comma is not an issue
        cnt += 1

        if cnt == num_emails_per_batch or i == len(uid_list)-1:
            batch_num = math.floor(i/num_emails_per_batch)+1
            if email_dl(client, uid_search_expr, batch_num, num_batches):
                return 1
            uid_search_expr = ''
            cnt = 0
    return 0
        
def email_dl(client, uid_search_expr, batch_num, num_batches):
    logging.info('batch %d of %d', batch_num, num_batches)

    # Build up search expression
    search_expr = []
    search_expr.append('UID')
    search_expr.append(uid_search_expr)
    logging.info('Searching with expression: %s', search_expr)

    # Download email
    try:
        messages = client.search(search_expr)
        response = client.fetch(messages, ['RFC822'])
    except:
        logging.warning('Exception while searching email!')
        logging.warning(sys.exc_info()[0])
        return 1

    logging.info('Found %d messages', len(response.items()))

    threads = []
    for uid, message_data in response.items():
        logging.info('uid: {}'.format(uid))
        # extract_content_from_email(message_data, uid, True)
        try:
            x = threading.Thread(target=extract_content_from_email,
                                 args=(message_data, uid, True,))
            threads.append(x)
            x.start()
        except:
            logging.warning('Failed downloading text email! {}')
            logging.warning(sys.exc_info()[0])

    for x in threads:
        x.join()

    # Update file
    try:
        fh = open(_email_downloaded_path, 'a')
        for uid, message_data in response.items():
            fh.write(str(uid) + '\n')
    finally:
        fh.close()

    update_progress(batch_num, num_batches, 50, 0)
    return 0
                
def email_already_downloaded(uid5):
    files = [f for f in listdir(_sender_dir) if isfile(join(_sender_dir, f))]
    return str(uid5) in files

def extract_content_from_email(message_data, uid, use_text_if_found):
    uid5 = '%05d' % uid
    email_message = email.message_from_string(message_data[b'RFC822'].decode())
    from_address = re.sub('[<>]', '',
                          email_message.get('From').split(" ")[-1])
    display_name = config['email_display_names'][from_address]
    subject = email_message.get('Subject')
    email_date = email_message.get('Date')
    try:
        (value, charset) = decode_header(subject)[0]
        logging.info('charset: %s', charset)
        logging.info('value: %s', value)
    except:
        logging.warning('Could not determine charset')
        charset = 'utf-8'

    try:
        if charset == None:
            charset = 'utf-8'
        subject = value.decode(charset)
    except:
        logging.warning('Could not decode charset %s', charset)

    logging.info('Parsing email from: %s', from_address)
    logging.info('Displaying name: %s', display_name)
    logging.info('Sent: %s', email_date)
    logging.info('Subject: %s', subject)
        
    # Generate daily_photo file for this email
    for part in email_message.walk():
        if part.get_content_type() == 'image/jpeg' or \
          part.get_content_type() == 'image/png':
            write_daily_photo(part.get_payload(decode=True), uid5)

    # Generate daily_text file for this email
    try:
        if use_text_if_found and subject != '':
            write_daily_text(subject, display_name, email_date, uid5)
        else:
            write_daily_text('no message', display_name, email_date, uid5)
    except:
        path = _sender_path % uid5
        fh = open(path, 'w')
        fh.write('failed')
        fh.close()

def update_progress(complete, total, section_percentage, offset):
    percent_complete = int((complete/total)*section_percentage + offset)
    fh = open(_progress_path, 'w')
    logging.info('{}/{} of {}% + {}% => {}%'.format(complete, total,
                                             section_percentage, offset,
                                             percent_complete))
    fh.write('{}%'.format(percent_complete))
    fh.close()

def write_daily_photo(message_payload, uid5):
    logging.info(' ** Found photo!')
    try:
        path = _photo_path % uid5 + '_orig'
        logging.info(' ** Writing {}'.format(path))
        fh = open(path, 'wb')
        fh.write(message_payload)
        fh.close()
    except:
        logging.warning('Failed to write %s', path)

def write_daily_text(message_text, display_name, email_date, uid5):
    message_text_parsed = re.sub('[ \n]', '', message_text)
    message_text_nl_out = re.sub('[\n\r]', ' ', message_text)
    if len(message_text_parsed) > 1:
        logging.info(' ** Found message text!')
        logging.info(message_text_nl_out)
        try:
            path = _sender_path % uid5
            fh = open(path, 'w')
            fh.write('%s' % display_name)
            fh.close()
        except:
            logging.warning('Failed to write %s', path)
        try:
            path = _text_path % uid5
            fh = open(path, 'w')
            if message_text_nl_out == 'no message':
                fh.write('')
            else:
                fh.write('%s' % message_text_nl_out)
            fh.close()
        except:
            logging.warning('Failed to write %s', path)

        try:
            path = _date_path % uid5
            fh = open(path, 'w')
            fh.write('%s' % email_date)
            fh.close()
        except:
            logging.warning('Failed to write %s', path)

def remove_symlinks():
    files = glob.glob(_today_photo_dir + '/*')
    for f in files:
        os.remove(f)

    files = glob.glob(_today_text_dir + '/*')
    for f in files:
        os.remove(f)

    files = glob.glob(_today_date_dir + '/*')
    for f in files:
        os.remove(f)

    files = glob.glob(_today_sender_dir + '/*')
    for f in files:
        os.remove(f)

def create_symlinks():
    i = 0
    for uid5 in _symlinks_to_create:
        create_symlink(uid5, i)
        i += 1
    
def create_symlink(uid5, i):
    logging.info('Creating symlink for {}'.format(uid5))
    src_path = _photo_path % uid5
    dst_path = _today_photo_path % uid5
    if os.path.isfile(src_path):
        try:
            os.symlink(src_path, dst_path)
            logging.info('Linked {} to {}'.format(src_path, dst_path))
        except:
            pass
    else:
        alt_idx = i-1
        logging.info('search idx is {}, uid: {}'.format(alt_idx, _symlinks_to_create[alt_idx]))
        if alt_idx < 0:
            logging.error('No image for {}'.format(uid5))
            os.symlink(_default_photo, dst_path)
            alt_idx = len(_symlinks_to_create) # to skip while loop
        while alt_idx < len(_symlinks_to_create):
            alt_uid5 = _symlinks_to_create[alt_idx]
            alt_src_path = _photo_path % alt_uid5
            if os.path.isfile(alt_src_path): 
                try:
                    os.symlink(alt_src_path, dst_path)
                    logging.info('Linked {} to {}'.format(alt_src_path,
                                                          dst_path))
                except:
                    logging.error('Failed to link {} to {}'.format(alt_uid5,
                                                                   uid5))
                    pass
                break
            alt_idx -= 1
            logging.info('search idx is {}, uid: {}'.format(alt_idx, _symlinks_to_create[alt_idx]))

    src_path = _text_path % uid5
    dst_path = _today_text_path % uid5
    try:
        os.symlink(src_path, dst_path)
    except:
        pass

    src_path = _date_path % uid5
    dst_path = _today_date_path % uid5
    try:
        os.symlink(src_path, dst_path)
    except:
        pass

    src_path = _sender_path % uid5
    dst_path = _today_sender_path % uid5
    try:
        os.symlink(src_path, dst_path)
    except:
        pass

def resize_photos():
    threads = []
    files = glob.glob(_photo_glob_orig)
    max_threads = 4
    running_threads = 0
    i = 0

    for photo_path in files:
        try:
            x = threading.Thread(target=resize_photo,
                                 args=(join(_photo_dir, photo_path),))
            threads.append(x)
            x.start()
        except:
            logging.error('Failed to start resize photo thread for {}'.format(photo_path))
            pass

        running_threads += 1
        if running_threads >= max_threads:
            for x in threads:
                x.join()
                i += 1
                update_progress(i, len(files), 49, 50)
            threads.clear()
            running_threads = 0

    # Join any remaining threads
    for x in threads:
        x.join()
        i += 1
        update_progress(i, len(files), 49, 50)

# Read in photo height and scale it down, in place, to target height
def resize_photo(photo_path):
    logging.info('Resizing photo: {}'.format(photo_path))

    im1 = Image.open(photo_path)
    ImageOps.exif_transpose(im1).convert('RGB').save(photo_path, 'jpeg')
    
    photo_height = int(subprocess.check_output(['convert', photo_path,
                                                '-print', '%h', '/dev/null']).decode())
    logging.info('Original photo height: %d', photo_height)
    scale_percentage = '%d%%' % (_target_photo_height * 100 / photo_height)
    if (scale_percentage != "100%"):
        logging.info('Scaling photo to %s of its original size',
                     scale_percentage)
        subprocess.call(['mogrify',
                         '-resize', scale_percentage,
                         photo_path])
    else:
        logging.info('Photo does not need scaling')

    try:
        new_path = photo_path.replace('_orig', '')
        os.rename(photo_path, new_path)
    except:
        pass

def teardown():
    logging.info('****************************************')
    logging.info('read_email.py exited at %s',
                 datetime.now().strftime("%Y-%m-%d %H:%M"))
    logging.info('****************************************')

# main
setup()
update_progress(0, 1, 0, 0) # to 0%
remove_symlinks()
rc = read_emails()
resize_photos()
create_symlinks()
if rc == 0:
    update_progress(1, 1, 99, 0) # to 99%
teardown()
sys.exit(rc)
