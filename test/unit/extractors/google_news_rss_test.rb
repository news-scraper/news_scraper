require 'test_helper'
require 'yaml'
require 'pry'

class GoogleNewsRssTest < Minitest::Test
  include ExtractorsTestHelpers

  def test_extract_returns_article_uris_from_google_rss_feed
    raw_data = File.read('test/data/google_news_rss/shopify_raw.rss')
    url = 'https://news.google.com/news?cf=all&hl=en&pz=1&ned=us&output=rss&q=shopify'
    expected_article_uris = YAML.load_file('test/data/google_news_rss/shopify_article_uris.yml').sort
    stub_http_request(url: url, body: raw_data)

    capture_subprocess_io do
      extractor = NewsScraper::Extractors::GoogleNewsRss.new(query: 'shopify')
      assert_equal expected_article_uris, extractor.extract.sort
    end
  end
end
