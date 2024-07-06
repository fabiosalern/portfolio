from time import sleep
from bs4 import BeautifulSoup as bs
import requests
import pandas as pd
from utils import (URL, logger,
                   string_to_date, string_to_date2)


urls = {
    'url': [],
    'date': []
}

# Fetch articles homepage to find articles urls
def fetch_and_save(date_string, source):
    logger.info('Starting to scrape...')
    last_date = string_to_date(date_string)
    stop_date = last_date

    i = 1

    while last_date >= stop_date: # time check
        url = URL + f"{i}/" # url of the articles homepage
        r = requests.get(url)
        soup = bs(r.text, "html.parser")

        page_urls = soup.find_all('a', {'class': 'card-title'}) # find all urls (a-tags) in the page
        page_urls = [url['href'] for url in page_urls]

        dates = soup.find_all('span', {'class': 'typography__StyledTypography-owin6q-0 fUOSEs'})[::2] # find all dates in the page
        dates = [date.text[:12].strip() for date in dates]
        for j, date in enumerate(dates): # re-formatting the dates to 
            if len(date) == 11:
                dates[j] = date[:4] + '0' + date[4:]

        dates = list(map(lambda x: string_to_date2(x), dates)) # converting date in datetime format
        
        # Updating final lists
        urls['url'] += page_urls 
        urls['date'] += dates

        last_date = min(dates) # updating last date

        i += 1
    logger.info(f'Scraping finished. Scraped until page {i-1}')

    pd.DataFrame(urls).to_csv(source) # export results