require 'nokogiri'

module NewsScraper
  module Extractors
    class Article
      include ExtractorsHelpers

      def initialize(url:)
        @url = url
      end

      def extract
        http_request(@url).body
      end
    end
  end
end
