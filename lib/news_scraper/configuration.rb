module NewsScraper
  class Configuration
    DEFAULT_SCRAPE_PATTERNS_FILEPATH = File.expand_path('../../../config/article_scrape_patterns.yml', __FILE__)
    attr_accessor :scrape_patterns, :scrape_patterns_filepath

    def initialize(scrape_patterns_filepath: nil)
      @scrape_patterns_filepath = scrape_patterns_filepath || DEFAULT_SCRAPE_PATTERNS_FILEPATH
      raise ScrapePatternsFilePathDoesntExist unless File.exist?(@scrape_patterns_filepath)
      @scrape_patterns = YAML.load_file(@scrape_patterns_filepath)
    end
  end
end
