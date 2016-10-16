require 'nokogiri'
require 'sanitize'
require 'news_scraper/transformers/nokogiri/functions'

require 'readability'
require 'htmlbeautifier'
require 'metainspector'
require 'news_scraper/transformers/helpers/highscore_parser'

module NewsScraper
  module Transformers
    class Article
      # Initialize a Article object
      #
      # *Params*
      # - <code>url</code>: keyword arg - the url on which scraping was done
      # - <code>payload</code>: keyword arg - the result of the scrape
      #
      def initialize(url:, payload:)
        @url = url
        @root_domain = URIParser.new(url).host
        @payload = payload
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
        scrape_details = NewsScraper.configuration.scrape_patterns['domains'][@root_domain]
        raise ScrapePatternNotDefined.new(url: @url, root_domain: @root_domain) unless scrape_details
        transformed_response(scrape_details).merge(url: @url, root_domain: @root_domain)
      end

      private

      def transformed_response(scrape_details)
        NewsScraper.configuration.scrape_patterns['data_types'].each_with_object({}) do |data_type, response|
          response[data_type.to_sym] = nil
          next unless scrape_details[data_type]

          response[data_type.to_sym] = parsed_data(
            scrape_details[data_type]['method'].to_sym,
            scrape_details[data_type]['pattern']
          )
        end
      end

      def parsed_data(scrape_method, scrape_pattern)
        case scrape_method
        when :xpath
          noko_html = ::Nokogiri::HTML(@payload)
          Sanitize.fragment(
            noko_html.xpath("(#{scrape_pattern})[1]", Nokogiri::Functions.new)
          ).squish
        when :css
          noko_html = ::Nokogiri::HTML(@payload)
          Sanitize.fragment(
            noko_html.css(scrape_pattern)
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
        when :metainspector
          page = MetaInspector.new(@url, document: @payload)
          page.respond_to?(scrape_pattern.to_sym) ? page.send(scrape_pattern.to_sym) : nil
        when :highscore
          NewsScraper::Transformers::Helpers::HighScoreParser.keywords(url: @url, payload: @payload)
        end
      end
    end
  end
end
