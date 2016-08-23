require 'nokogiri'
require 'yaml'

module NewsScraper
  module Extractors
    class Article
      include ExtractorsHelpers

      attr_accessor :uri

      SCRAPE_PATTERNS = YAML.load_file('config/article_scrape_patterns.yml').freeze

      def initialize(uri:)
        @uri = uri.gsub(/^https?:\/\//, '')
      end

      def extract
        http_request "http://#{uri}" do |response|
          response.body
        end
      end

      private

      def root_domain
        @root_domain ||= uri.downcase.match(/^(?:[\w\d-]+\.)?([\w\d-]+\.\w{2,})/)[1]
      end
    end
  end
end
