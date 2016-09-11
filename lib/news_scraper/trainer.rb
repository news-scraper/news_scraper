require 'news_scraper/trainer/preset_selector'
require 'news_scraper/trainer/url_trainer'

module NewsScraper
  module Trainer
    extend self

    def train(query: '')
      article_urls = Extractors::GoogleNewsRss.new(query: query).extract
      article_urls.each do |url|
        Trainer::UrlTrainer.new(url).train
      end
    end
  end
end
