
module NewsScraper
  class ResponseError < StandardError; end

  class ScrapePatternsFilePathDoesNotExist < StandardError
    def new(file_path)
      @file_path = file_path
      super
    end

    def message
      "Scrape Patterns File Path (#{@file_path}) did not exist"
    end
  end

  module Transformers
    class ScrapePatternNotDefined < StandardError
      attr_reader :root_domain, :uri

      def initialize(opts = {})
        @root_domain = opts[:root_domain]
        @uri = opts[:uri]
        super
      end
    end
  end
end
