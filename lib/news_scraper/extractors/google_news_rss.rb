require 'rss'
require 'nokogiri'

module NewsScraper
  module Extractors
    class GoogleNewsRss
      include ExtractorsHelpers

      BASE_URL = 'https://news.google.com/news?cf=all&hl=en&pz=1&ned=us&output=rss'.freeze
      ARTICLE_URIS_DIR = Constants::TEMP_DIRS['extractors']['google_news_rss']['article_uris'].freeze

      attr_reader :query, :temp_write

      def initialize(query:, temp_write: false)
        @query = query
        @temp_write = temp_write
      end

      def extract
        http_request "#{BASE_URL}&q=#{query}" do |response|
          google_urls = google_urls_from_resp(response.body)
          article_uris = extract_article_uris(google_urls)

          write_to_temp(article_uris) if temp_write

          article_uris
        end
      end

      private

      def google_urls_from_resp(body)
        rss = RSS::Parser.parse(body)

        rss.items.flat_map do |rss_item|
          Nokogiri::HTML(rss_item.description).xpath('//a').map do |anchor|
            anchor['href']
          end
        end
      end

      def extract_article_uris(google_urls)
        google_urls.map do |google_url|
          regex = google_url.match(/&url=https?:\/\/(.*)/)
          regex.nil? ? nil : regex[1]
        end.compact.uniq
      end

      def write_to_temp(article_uris)
        filename = "#{query.downcase.gsub(/\s/, '_')}_#{Time.now.to_i}.txt"
        puts "Writing article uris to #{filename}"
        File.open(File.join(TMP_DIR, filename), 'w') do |file|
          article_uris.each { |uri| file.puts uri }
        end
      end
    end
  end
end
