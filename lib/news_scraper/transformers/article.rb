require 'nokogiri'
require 'sanitize'
require 'readability'
require 'htmlbeautifier'

module NewsScraper
  module Transformers
    class Article
      attr_reader :uri, :payload

      def initialize(uri:, payload:, scrape_details: nil, scrape_patterns: Constants::SCRAPE_PATTERNS)
        uri_parser = URIParser.new(uri)
        @uri = uri_parser.without_scheme
        @root_domain = uri_parser.host
        @payload = payload
        @scrape_patterns = scrape_patterns
        @scrape_details = scrape_details
      end

      def transform
        raise ScrapePatternNotDefined.new(root_domain: @root_domain) unless scrape_pattern?

        transformed_response.merge(root_domain: @root_domain)
      end

      private

      def scrape_pattern?
        !!(scrape_details)
      end

      def scrape_details
        @scrape_details ||= @scrape_patterns['domains'][@root_domain]
      end

      def transformed_response
        @scrape_patterns['data_types'].each_with_object({}) do |data_type, response|
          response[data_type.to_sym] = parsed_data(data_type)
        end
      end

      def parsed_data(data_type)
        return nil unless scrape_details[data_type]

        scrape_method = scrape_details[data_type]['method'].to_sym
        case scrape_method
        when :xpath, :css
          scrape_pattern = scrape_details[data_type]['pattern']
          noko_html = Nokogiri::HTML(payload)
          Sanitize.fragment(
            noko_html.send(scrape_method, scrape_pattern)
          ).squish
        when :readability
          content = Readability::Document.new(
            @payload,
            remove_empty_nodes: true,
            tags: %w(div p img a table tr th tbody td h1 h2 h3 h4 h5 h6),
            attributes: %w(src href colspan rowspan)
          ).content
          # Remove any newlines in the text
          content = content.gsub(/\n+|\r+/, "\n").squeeze("\n").strip
          HtmlBeautifier.beautify(content)
        end
      end
    end
  end
end
