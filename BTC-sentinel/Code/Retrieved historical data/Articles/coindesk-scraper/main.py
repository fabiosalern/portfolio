from argparse import ArgumentParser
from parser import ArticleParser
from scraper import fetch_and_save
from utils import logger, validate_date_arg

SOURCE_FILE = 'source.csv'

# STEP 1
# Web page is fetched and articles urls are saved in a csv file
def step1(date_str):
    fetch_and_save(date_str, SOURCE_FILE)

# STEP 2
# Each article is scraped and the content is saved in a json file
def step2(date_str):
    parser = ArticleParser.from_csv(SOURCE_FILE)
    parser.fetch_artices()


if __name__ == '__main__':
    logger.info('####### STARTING COINTELEGRAPH SCRAPER #######')

    # Set parameters
    choices = {'step1': step1, 'step2': step2}
    parser = ArgumentParser(description='Parse data from cointelegraph.com')
    parser.add_argument('step', choices=choices, help='which step to run')
    parser.add_argument('--date', metavar='DATE', type=str, help='DATE limit')
    parser.add_argument(
        '--filepath', metavar='FILEPATH', type=str, help='CSV file')
    args = parser.parse_args()

    # Run functions
    function = choices[args.step]
    date, csv_filepath = args.date, args.filepath

    try:
        if function in [step1, step2] and validate_date_arg(date):
            function(date)
    except Exception:
        logger.critical('Failed unexpectedly. Check logs.')
        logger.exception('Exception occured')
