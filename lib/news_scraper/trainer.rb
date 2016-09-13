require 'news_scraper/trainer/preset_selector'
require 'news_scraper/trainer/url_trainer'

module NewsScraper
  module Trainer
    extend self

    # Fetches articles from Extraction sources and trains on the results
    #
    # *Training* is a process where we take an untrained url (root domain
    # is not in <code>article_scrape_patterns.yml</code>) and determine patterns and methods
    # to match the data_types listed in <code>article_scrape_patterns.yml</code>, then record
    # them to the <code>article_scrape_patterns.yml</code> file
    #
    # *Params*
    # - <code>query</code>: a keyword arugment specifying the query to train on
    #
    def train(query: '')
      article_urls = Extractors::GoogleNewsRss.new(query: query).extract
      article_urls.each do |url|
        Trainer::UrlTrainer.new(url).train
      end
    end
  end
end
