require 'rss'
require 'nokogiri'

module NewsScraper
  module Extractors
    class GoogleNewsRss
      include ExtractorsHelpers

      BASE_URL = 'https://news.google.com/news?cf=all&hl=en&pz=1&ned=us&output=rss'.freeze

      attr_accessor :query

      def initialize(query:)
        @query = query
      end

      def extract
        http_request "#{BASE_URL}&q=#{query}" do |response|
          google_links = links_from_resp(response.body)
          article_links = extract_article_links(google_links)
          article_links.map do |link|
            Extractors::Article.new(uri: link).extract
          end
        end
      end

      private

      def links_from_resp(body)
        rss = RSS::Parser.parse(body)

        rss.items.flat_map do |rss_item|
          Nokogiri::HTML(rss_item.description).xpath('//a').map do |link|
            link['href']
          end
        end
      end

      def extract_article_links(google_links)
        google_links.map do |google_link|
          regex = google_link.match(/&url=https?:\/\/(.*)/)
          regex.nil? ? nil : regex[1]
        end.compact.uniq
      end
    end
  end
end
