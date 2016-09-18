module NewsScraper
  module Constants
    SCRAPE_PATTERN_FILEPATH = File.expand_path('../../../config/article_scrape_patterns.yml', __FILE__)
    SCRAPE_PATTERNS = YAML.load_file(SCRAPE_PATTERN_FILEPATH)
  end
end
