require 'news_scraper/trainer/preset_selector'
require 'news_scraper/trainer/url_trainer'

module NewsScraper
  module Trainer
    extend self

    # Fetches articles from Extraction sources and trains on the results
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
