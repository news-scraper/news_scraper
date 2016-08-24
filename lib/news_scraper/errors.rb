
module NewsScraper
  class ResponseError < StandardError; end

  module Transformers
    class ScrapePatternNotFound < StandardError; end

    class ScrapeMethodNotSupported < StandardError; end
  end
end
