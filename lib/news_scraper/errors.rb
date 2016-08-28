
module NewsScraper
  class ResponseError < StandardError; end

  module Transformers
    class ScrapePatternNotDefined < StandardError; end
  end
end
