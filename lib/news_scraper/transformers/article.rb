require 'nokogiri'
require 'sanitize'

module NewsScraper
  module Transformers
    class Article
      SCRAPE_PATTERNS = YAML.load_file('config/article_scrape_patterns.yml').with_indifferent_access.freeze
      RESPONSE_DATA_TYPES = SCRAPE_PATTERNS[:data_types][:required].map(&:to_sym).freeze

      def initialize(uri:, payload:)
        @uri = uri
        @payload = payload
      end

      def transform
        raise ScrapePatternNotFound unless scrape_pattern?


      end

      private

      def scrape_pattern?
        SCRAPE_PATTERNS[:domains].key?(root_domain)
      end

      def scrape_details
        @scrape_details ||= SCRAPE_PATTERNS[:domains][root_domain]
      end

      def root_domain
        @root_domain ||= uri.downcase.match(/^(?:[\w\d-]+\.)?([\w\d-]+\.\w{2,})/)[1]
      end

      def build_transformed_response
        RESPONSE_DATA_TYPES.each_with_object({}) do |data_type, response|
          response[data_type] = parsed_data(data_type)
        end
      end

      def parsed_data(data_type)
        pattern = scrape_details[data_type][:pattern]
        scrape_method = scrape_details[data_type][:method].to_sym

        raise ScrapeMethodNotSupported unless Nokogiri::HTML.respond_to?(scrape_method)
        Sanitize.fragment(
          Nokogiri::HTML.send(scrape_method, scrape_pattern)
        )
      end
    end
  end
end
