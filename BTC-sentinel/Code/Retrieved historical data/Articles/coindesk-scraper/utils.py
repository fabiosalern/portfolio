import os
from datetime import datetime
import requests
import logging

URL = 'https://www.coindesk.com/tag/bitcoin/'
NEWS_URL = 'https://www.coindesk.com/'
LOGFILE = 'coindesk.log'

# Create the logger
def get_logger():
    logger = logging.getLogger('ct_logger')
    logger.setLevel('DEBUG')

    console_handler = logging.StreamHandler()
    console_formatter = logging.Formatter('%(levelname)-8s: %(message)s')
    console_handler.setFormatter(console_formatter)

    file_handler = logging.FileHandler(LOGFILE, mode='a')
    file_formatter = logging.Formatter(
        '%(asctime)s %(name)s %(levelname)-8s: %(message)s',
        "%Y-%m-%d %H:%M:%S")
    file_handler.setFormatter(file_formatter)

    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    return logger

# UTILS FUNCTIONS
# ---------------

# String to date for input arguments 
def string_to_date(date_str):
    return datetime.strptime(date_str, '%Y-%m-%d').date()

# String to date for articles dates
def string_to_date2(date_str):
    return datetime.strptime(date_str, '%b %d, %Y').date()

# Date validation
def validate_date_arg(date_str):
    try:
        if date_str is None:
            logger.critical('No date found')
            return False
        date = string_to_date(date_str)
        if date > datetime.now().date():
            logger.critical(
                'Entered date must not be greater than today\'s date')
            return False
        return True
    except Exception:
        logger.critical('Invalid date')
        return False

logger = get_logger()
