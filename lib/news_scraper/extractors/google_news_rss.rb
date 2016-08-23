require 'rss'
require 'nokogiri'

module NewsScraper
  module Extractors
    class GoogleNewsRss
      include ExtractorsHelpers

      BASE_URL = 'https://news.google.com/news?cf=all&hl=en&pz=1&ned=us&output=rss'.freeze
      TMP_DIR = 'tmp/google_news_rss'.freeze

      attr_accessor :query

      def initialize(query:)
        @query = query
      end

      def extract
        http_request "#{BASE_URL}&q=#{query}" do |response|
          google_links = links_from_resp(response.body)
          article_links = extract_article_links(google_links)
          write_to_tmp(article_links)
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

      def write_to_tmp(article_links)
        filename = "#{query.downcase.gsub(/\s/, '_')}_#{Time.now.to_i}.txt"
        puts "Writing article links to #{filename}"
        File.open(File.join(TMP_DIR, filename), 'w') do |file|
          article_links.each { |link| file.puts link }
        end
      end
    end
  end
end
