require 'test_helper'

module NewScraper
  module Extractors
    class GoogleNewsRssTest < Minitest::Test
      include ExtractorsTestHelpers
      def setup
        super
        @raw_data = File.read('test/data/google_news_rss/shopify_raw.rss')
        @query = "shopify"
        @url = "https://news.google.com/news?cf=all&hl=en&pz=1&ned=us&output=rss&q=#{@query}"

        @extractor = NewsScraper::Extractors::GoogleNewsRss.new(query: @query)
        @expected_article_urls = YAML.load_file('test/data/google_news_rss/shopify_article_urls.yml').sort
      end

      def test_extract_returns_article_urls_from_google_rss_feed
        stub_http_request(url: @url, body: @raw_data)
        capture_subprocess_io do
          assert_equal @expected_article_urls, @extractor.extract.sort
        end
      end

      def test_extract_returns_article_urls_from_google_rss_feed_with_unauthorized
        stub_http_request_with_unauthorized(url: @url, body: @raw_data)
        err = assert_raises NewsScraper::ResponseError do
          capture_subprocess_io do
            assert_equal @expected_article_urls, @extractor.extract.sort
          end
        end
        assert_equal 403, err.error_code
        assert_equal 'This is not ok', err.message
        assert_equal @url, err.url
      end
    end
  end
end
