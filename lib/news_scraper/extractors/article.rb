require 'nokogiri'

module NewsScraper
  module Extractors
    class Article
      include ExtractorsHelpers

      def initialize(url:)
        @url = url
      end

      def extract
        http_request @url do |response|
          response.body
        end
      end
    end
  end
end
