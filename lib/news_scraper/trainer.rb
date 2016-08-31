require 'news_scraper/trainer/data_type'
require 'news_scraper/trainer/uri_trainer'

module NewsScraper
  module Trainer
    extend self

    def train(query: '')
      article_uris = Extractors::GoogleNewsRss.new(query: query).extract
      article_uris.each do |uri|
        NewsScraper::Trainer::UriTrainer.train(uri)
      end
    end
  end
end
