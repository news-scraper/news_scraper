require 'httparty'

require 'news_scraper/temp_dirs'
require 'news_scraper/active_support_lite/string'

require 'news_scraper/errors'
require 'news_scraper/version'

require 'news_scraper/extractors_helpers'

require 'news_scraper/extractors/google_news_rss'
require 'news_scraper/extractors/article'

require 'news_scraper/transformers/article'

module NewsScraper
end
