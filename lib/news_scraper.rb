require 'httparty'
require 'yaml'

require 'news_scraper/constants'
require 'news_scraper/uri_parser'
require 'news_scraper/active_support_lite/string'

require 'news_scraper/errors'
require 'news_scraper/version'

require 'news_scraper/extractors_helpers'

require 'news_scraper/extractors/google_news_rss'
require 'news_scraper/extractors/article'

require 'news_scraper/transformers/article'

require 'news_scraper/cli'
require 'news_scraper/trainer'

module NewsScraper
  extend self

  # NewsScraper.train is an interactive command-line prompt that:
  #
  # 1. Collates all articles for the given :query
  # 2. Grep for :data_types using :presets in config/article_scrape_patterns.yml
  # 3. Displays the results of each :preset grep for a given :data_type
  # 4. Prompts the user to select one of the :presets to use as the default for a domain's :data_type
  #   N.B: User may ignore all presets and manually configure it in the YAML file
  # 5. Saves the selected :preset to config/article_scrape_patterns.yml

  def train(query:)
    Trainer.train(query: query)
  end
end
