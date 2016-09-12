require 'nokogiri'
require 'sanitize'
require 'readability'
require 'htmlbeautifier'

module NewsScraper
  module Transformers
    class Article
      attr_reader :uri, :payload

      # Initialize a Article object
      #
      # *Params*
      # - <code>url</code>: keyword arg - the url on which scraping was done
      # - <code>payload</code>: keyword arg - the result of the scrape
      # - <code>scrape_details</code>: keyword arg - The pattern/methods for the domain to use in the transformation
      # - <code>scrape_patterns</code>: keyword arg - The patterns available to use in transformation
      #
      def initialize(url:, payload:, scrape_details: nil, scrape_patterns: Constants::SCRAPE_PATTERNS)
        uri_parser = URIParser.new(url)
        @uri = uri_parser.without_scheme
        @root_domain = uri_parser.host
        @payload = payload
        @scrape_patterns = scrape_patterns
        @scrape_details = scrape_details
      end

      # Transform the article
      #
      # *Raises*
      # - ScrapePatternNotDefined: will raise this error if the root domain is not in the article_scrape_patterns.yml
      #
      # *Returns*
      # - <code>transformed_response</code>: the response that has been parsed and transformed to a hash
      #
      def transform
        raise ScrapePatternNotDefined.new(root_domain: @root_domain) unless scrape_details

        transformed_response.merge(uri: @uri, root_domain: @root_domain)
      end

      private

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
        when :xpath
          noko_html = Nokogiri::HTML(payload)
          Sanitize.fragment(
            noko_html.send(scrape_method, "(#{scrape_details[data_type]['pattern']})[1]")
          ).squish
        when :css
          noko_html = Nokogiri::HTML(payload)
          Sanitize.fragment(
            noko_html.send(scrape_method, scrape_details[data_type]['pattern'])
          ).squish
        when :readability
          content = Readability::Document.new(
            @payload,
            remove_empty_nodes: true,
            tags: %w(div p img a table tr th tbody td h1 h2 h3 h4 h5 h6),
            attributes: %w(src href colspan rowspan)
          ).content
          # Remove any newlines in the text
          content = content.squeeze("\n").strip
          HtmlBeautifier.beautify(content)
        end
      end
    end
  end
end
