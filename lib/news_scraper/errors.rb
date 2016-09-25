
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
      attr_reader :root_domain, :url

      def initialize(opts = {})
        @root_domain = opts[:root_domain]
        @url = opts[:url]
        super
      end
    end
  end
end
