
module NewsScraper
  class ResponseError < StandardError
    attr_reader :error_code, :message, :url

    def initialize(opts = {})
      @error_code = opts[:error_code]
      @message = opts[:message]
      @url = opts[:url]
      super
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
