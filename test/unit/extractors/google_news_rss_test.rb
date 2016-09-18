require 'test_helper'

module NewScraper
  module Extractors
    class GoogleNewsRssTest < Minitest::Test
      include ExtractorsTestHelpers
      def setup
        raw_data = File.read('test/data/google_news_rss/shopify_raw.rss')
        @query = "shopify"
        url = "https://news.google.com/news?cf=all&hl=en&pz=1&ned=us&output=rss&q=#{@query}"
        stub_http_request(url: url, body: raw_data)

        @extractor = NewsScraper::Extractors::GoogleNewsRss.new(query: @query)
        @expected_article_urls = YAML.load_file('test/data/google_news_rss/shopify_article_urls.yml').sort
      end

      def test_extract_returns_article_urls_from_google_rss_feed
        capture_subprocess_io do
          assert_equal @expected_article_urls, @extractor.extract.sort
        end
      end
    end
  end
end
