
module NewsScraper
  class ResponseError < StandardError; end

  module Transformers
    class ScrapePatternNotDefined < StandardError
      attr_reader :root_domain, :uri

      def initialize(opts = {})
        @root_domain = opts[:root_domain]
        @uri = opts[:uri]
        super
      end
    end

    class ScrapePatternsFilePathDoesntExist < StandardError
      def message
        'Scrape Patterns File Path was not set in configuration'
      end
    end
  end
end
