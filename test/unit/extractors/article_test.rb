require 'test_helper'

module NewsScraper
  module Extractors
    class ArticleTest < Minitest::Test
      include ExtractorsTestHelpers

      def test_correctly_extracts_body_from_given_url
        site = 'http://somesite.com'
        expected_body = 'somesite body response'
        stub_http_request(url: site, body: expected_body)
        capture_subprocess_io do
          extractor = Article.new(url: site)
          assert_equal expected_body, extractor.extract
        end
      end

      def test_raises_error_properly
        site = 'http://somesite.com'
        expected_body = 'somesite body response'
        stub_http_request_with_unauthorized(url: site, body: expected_body)

        err = assert_raises NewsScraper::ResponseError do
          capture_subprocess_io do
            Article.new(url: site).extract
          end
        end
        assert_equal 403, err.error_code
        assert_equal 'This is not ok', err.message
        assert_equal site, err.url
      end
    end
  end
end
