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

      def test_extract_writes_to_file_of_extracted_article_urls
        capture_subprocess_io do
          Timecop.freeze do
            expected_filename = "#{@query}_#{Time.now.to_i}.txt"
            expected_path = File.join(NewsScraper::Extractors::GoogleNewsRss::ARTICLE_URLS_DIR, expected_filename)
            file_handle = mock
            file_handle.stubs(:puts)
            File.expects(:open).with(expected_path, 'w').yields(file_handle)

            NewsScraper::Extractors::GoogleNewsRss.new(query: @query, temp_write: true).extract
          end
        end
      end
    end
  end
end
