module NewsScraper
  module Constants
    TEMP_DIRS = YAML.load_file('config/temp_dirs.yml')
    SCRAPE_PATTERN_FILEPATH = 'config/article_scrape_patterns.yml'.freeze
    SCRAPE_PATTERNS = YAML.load_file(SCRAPE_PATTERN_FILEPATH)
  end
end
