require 'nokogiri'
require 'sanitize'

module NewsScraper
  module Transformers
    class Article
      SCRAPE_PATTERNS = YAML.load_file('config/article_scrape_patterns.yml').freeze
      RESPONSE_DATA_TYPES = SCRAPE_PATTERNS['data_types']['required'].map(&:to_sym).freeze
      attr_reader :uri, :payload

      def initialize(uri:, payload:)
        @uri = uri
        @payload = payload
      end

      def transform
        raise ScrapePatternNotFound unless scrape_pattern?

        transformed_response.merge(root_domain: root_domain)
      end

      private

      def scrape_pattern?
        SCRAPE_PATTERNS['domains'].key?(root_domain)
      end

      def scrape_details
        @scrape_details ||= SCRAPE_PATTERNS['domains'][root_domain]
      end

      def root_domain
        @root_domain ||= uri.downcase.match(/^(?:[\w\d-]+\.)?([\w\d-]+\.\w{2,})/)[1]
      end

      def transformed_response
        RESPONSE_DATA_TYPES.each_with_object({}) do |data_type, response|
          response[data_type] = parsed_data(data_type)
        end
      end

      def parsed_data(data_type)
        data_type = data_type.to_s
        scrape_pattern = scrape_details[data_type]['pattern']
        scrape_method = scrape_details[data_type]['method'].to_sym

        noko_html = Nokogiri::HTML(payload)

        raise ScrapeMethodNotSupported unless noko_html.respond_to?(scrape_method)

        Sanitize.fragment(
          noko_html.send(scrape_method, scrape_pattern)
        ).squish
      end
    end
  end
end
