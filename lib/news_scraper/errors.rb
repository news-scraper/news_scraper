
module NewsScraper
  class ResponseError < StandardError; end

  module Transformers
    class ScrapePatternNotDefined < StandardError
      attr_reader :root_domain

      def initialize(opts = {})
        @root_domain = opts[:root_domain]
        super
      end
    end
  end
end
