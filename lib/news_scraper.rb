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
require 'news_scraper/transformers/trainer_article'

require 'news_scraper/scraper'

require 'news_scraper/cli'
require 'news_scraper/trainer'

module NewsScraper
  extend self

  # <code>NewsScraper::train</code> is an interactive command-line prompt that:
  #
  # 1. Collates all articles for the given :query
  # 2. Grep for <code>:data_types</code> using <code>:presets</code> in <code>config/article_scrape_patterns.yml</code>
  # 3. Displays the results of each <code>:preset</code> grep for a given <code>:data_type</code>
  # 4. Prompts the user to select a listed <code>:presets</code> or define a pattern to use for that domain's <code>:data_type</code>
  # N.B: User may ignore all presets and manually configure it in the YAML file
  # 5. Saves the selected <code>:preset</code> to <code>config/article_scrape_patterns.yml</code>
  #
  # *Params*
  # - <code>query</code>: a keyword arugment specifying the query to train on
  #
  def train(query:)
    Trainer.train(query: query)
  end
end
