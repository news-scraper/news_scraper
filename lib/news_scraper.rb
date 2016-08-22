require_relative 'news_scraper/extractors/google_news_rss'


module NewsScraper
  links = Extractors::GoogleNewsRss.new(query: 'Shopify').extract
  binding.pry
end
