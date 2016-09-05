require 'news_scraper/trainer/preset_selector'
require 'news_scraper/trainer/uri_trainer'

module NewsScraper
  module Trainer
    extend self

    def train(query: '', automated: false)
      article_uris = Extractors::GoogleNewsRss.new(query: query).extract
      article_uris.each do |uri|
        Trainer::UriTrainer.new(uri).train(automated: automated)
      end
    end
  end
end
