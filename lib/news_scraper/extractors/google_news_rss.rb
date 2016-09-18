require 'rss'
require 'nokogiri'

module NewsScraper
  module Extractors
    class GoogleNewsRss
      include ExtractorsHelpers
      BASE_URL = 'https://news.google.com/news?cf=all&hl=en&pz=1&ned=us&output=rss'.freeze

      def initialize(query:)
        @query = query
      end

      def extract
        http_request "#{BASE_URL}&q=#{@query}" do |response|
          google_urls = google_urls_from_resp(response.body)
          extract_article_urls(google_urls)
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

      def extract_article_urls(google_urls)
        google_urls.map do |google_url|
          regex = google_url.match(%r{&url=(?<url>https?://.*)})
          regex.nil? ? nil : regex['url']
        end.compact.uniq
      end
    end
  end
end
