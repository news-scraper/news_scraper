
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
  end
end
