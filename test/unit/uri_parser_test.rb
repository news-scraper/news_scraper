require 'test_helper'

module NewsScraper
  class URIParserTest < Minitest::Test
    def setup
      url = "https://www.yolo.com/this/is?cool=1"
      @uri_parser = URIParser.new(url)
    end

    def test_without_scheme_removes_http_or_https_scheme
      assert_equal "www.yolo.com/this/is?cool=1", @uri_parser.without_scheme
    end

    def test_host_returns_the_root_domain
      assert_equal "yolo.com", @uri_parser.host
    end
  end
end
