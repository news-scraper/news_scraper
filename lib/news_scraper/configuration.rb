module NewsScraper
  class Configuration
    DEFAULT_SCRAPE_PATTERNS_FILEPATH = File.expand_path('../../../config/article_scrape_patterns.yml', __FILE__)
    attr_accessor :scrape_patterns_filepath
    attr_reader :scrape_patterns

    def initialize(scrape_patterns_filepath: DEFAULT_SCRAPE_PATTERNS_FILEPATH)
      self.scrape_patterns_filepath = scrape_patterns_filepath
    end

    def scrape_patterns_filepath=(file_path)
      @scrape_patterns_filepath = file_path || DEFAULT_SCRAPE_PATTERNS_FILEPATH
      raise ScrapePatternsFilePathDoesNotExist.new(file_path) unless File.exist?(@scrape_patterns_filepath)
      @scrape_patterns = YAML.load_file(@scrape_patterns_filepath)
    end
  end
end
