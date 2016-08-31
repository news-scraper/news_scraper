module NewsScraper
  module Constants
    TEMP_DIRS = YAML.load_file('config/temp_dirs.yml')
    SCRAPE_PATTERN_CONFIG_FILE = 'config/article_scrape_patterns.yml'
    SCRAPE_PATTERNS = YAML.load_file(SCRAPE_PATTERN_CONFIG_FILE)
  end
end
