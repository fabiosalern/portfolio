import pandas as pd
import csv
import os
from dataclasses import dataclass
from datetime import datetime
from bs4 import BeautifulSoup as bs
from utils import (NEWS_URL, get_content, logger, string_to_date, string_to_date2)

# Creation of a class to save articles
@dataclass
class Article:
    url: str
    title: str
    description: str
    content: str
    author: str
    date: str

# Creation of the Parser class
class ArticleParser:
    DOWNLOADS_DIR = 'downloads'
    OUTPUT_FILE = 'results.json'

    def __init__(self, urls):
        self.create_directory() # create directory in format 'DD-MM-YY-HH-MM'
        self.urls = urls

    # Get urls from csv and create a Parser object
    @classmethod
    def from_csv(cls, csv_filepath):
        logger.debug(
            'Collecting data from CSV file: [{}]'.format(csv_filepath))
        return cls(ArticleParser.get_urls_from_csv(csv_filepath))

    # Get url from csv
    @staticmethod
    def get_urls_from_csv(csv_filepath):
        logger.debug('Read CSV file')
        df = pd.read_csv(csv_filepath)
        article_urls = df['url'].values
        logger.debug('Extracted URLs')

        return article_urls

    # Function to get article information from url
    @staticmethod
    def get_article_obj_from_url(url):
        logger.debug('Fetching content from url: [{}]'.format(NEWS_URL + url))
        article_page_content = get_content(NEWS_URL + url) # parse article page
        logger.debug('Fetched article page')
        
        # Find the article tag which contain all the information
        article_div = bs(article_page_content, 'html.parser').body.find(
            'main')
        logger.debug('Parsed article tag')

        title = article_div.find('h1').string.strip() # get title
        logger.debug('Fetched title: [{}]'.format(title))

        description = article_div.find('div', {'class': 'at-subheadline'}).h2.text.strip() # get description

        # Get content
        content = ''
        content_div = article_div.find('div', {"data-submodule-name": "composer-content"})
        for par in content_div.find_all('p'): # content is divided into paragraphs
            if par:
                content += par.getText() + ' '
        logger.debug('Fetched text: [{}]'.format(content))

        author = article_div.find('div', {'class': 'at-authors'}).span.text[3:].strip() # get author
        logger.debug('Fetched author: [{}]'.format(author))

        # Get date
        date_tag = article_div.find('div', {'class': 'at-created label-with-icon'}).div.span
        date = date_tag.text[:12].strip()
        if len(date) == 11:
            date = date[:4] + '0' + date[4:] # reformat date
        date = string_to_date2(date)
        logger.debug('Fetched date: [{}]'.format(date))

        return Article(url, title, description, content, author, date)

    # Write articles in csv / json file
    @staticmethod
    def write_articles(filename, articles, format='csv'):
        headers_row = ['url', 'title', 'description', 'content', 'author', 'date']
        articles_df = pd.DataFrame(articles, columns=headers_row)
        if format == 'csv':
            articles_df.to_csv(filename)
        elif format == 'json':
            articles_df.to_json(filename)
        else:
            logger.warning("Unsupported format! Supported formats are csv and json")

    # Function to create download directory
    def create_directory(self):
        logger.debug('Creating directory')
        directory_name = 'resources_'+datetime.now().strftime('%d-%m-%Y-%H-%M')
        self.directory = os.path.join(self.DOWNLOADS_DIR, directory_name)
        os.makedirs(self.directory, exist_ok=True)
        logger.debug('Created directories successfully')

    # Function that parse the articles from the urls
    def fetch_artices(self, date_limit=None):
        if date_limit is None:
            date_limit = '1970-01-01'
        logger.debug('Fetching articles data')
        self.articles = []
        for counter, url in enumerate(self.urls):
            logger.info(
                'Fetching article {}/{}'.format(counter+1, len(self.urls)))
            
            fetched = True
            try:
                article = ArticleParser.get_article_obj_from_url(url) # get article class from url
            except Exception as e: 
                logger.warn(e)
                fetched = False
            
            if article.date >= string_to_date(date_limit): # time limit check
                if fetched:
                    self.articles.append(article) # add article to list
                    logger.debug('Article added')
            else:
                logger.info(
                    'Stopped fetching as articles too old')
                break
            print('..')
        self.csv_file.close()
        self.export_articles(format='json') # export articles

    # Export articles
    def export_articles(self, format='csv'):
        filename = os.path.join(self.directory, self.OUTPUT_FILE)
        ArticleParser.write_articles(filename, self.articles, format)