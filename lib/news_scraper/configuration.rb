module NewsScraper
  class Configuration
    DEFAULT_SCRAPE_PATTERNS_FILEPATH = File.expand_path('../../../config/article_scrape_patterns.yml', __FILE__)
    STOPWORDS_FILEPATH = File.expand_path('../../../config/stopwords.yml', __FILE__)
    attr_accessor :scrape_patterns_fetch_method, :stopwords_fetch_method, :scrape_patterns_filepath

    # <code>NewsScraper::Configuration.initialize</code> initializes the scrape_patterns_filepath
    # and the scrape_patterns_fetch_method to the <code>DEFAULT_SCRAPE_PATTERNS_FILEPATH</code>.
    # It also sets stopwords to be used during extraction to a default set contained in <code>STOPWORDS_FILEPATH</code>
    #
    # Set the <code>scrape_patterns_filepath</code> to <code>nil</code> to disable saving during training
    #
    def initialize
      self.scrape_patterns_filepath = DEFAULT_SCRAPE_PATTERNS_FILEPATH
      self.scrape_patterns_fetch_method = proc { default_scrape_patterns }
      self.stopwords_fetch_method = proc { YAML.load_file(STOPWORDS_FILEPATH) }
    end

    # <code>NewsScraper::Configuration.scrape_patterns</code> proxies scrape_patterns
    # requests to <code>scrape_patterns_fetch_method</code>:
    #
    # *Returns*
    # - The result of calling the <code>scrape_patterns_fetch_method</code> proc, expected to be a hash
    #
    def scrape_patterns
      scrape_patterns_fetch_method.call
    end

    # <code>NewsScraper::Configuration.stopwords</code> proxies stopwords
    # requests to <code>stopwords_fetch_method</code>:
    #
    # *Returns*
    # - The result of calling the <code>stopwords_fetch_method</code> proc, expected to be an array
    #
    def stopwords
      stopwords_fetch_method.call
    end

    private

    def default_scrape_patterns
      @default_scrape_patterns ||= {}
      @default_scrape_patterns[scrape_patterns_filepath] ||= YAML.load_file(scrape_patterns_filepath)
    end
  end
end
