require 'test_helper'

module NewsScraper
  class URIParserTest < Minitest::Test
    def setup
      @http_uri = URIParser.new("http://www.yolo.com/is?cool=1")
      @https_uri = URIParser.new("https://www.yolo.com/is?cool=1")
      @schemeless_uri = URIParser.new("www.yolo.com/is?cool=1")
    end

    def test_without_scheme_removes_http_or_https_scheme
      expected_uri = "www.yolo.com/is?cool=1"
      assert_equal expected_uri, @http_uri.without_scheme
      assert_equal expected_uri, @https_uri.without_scheme
    end

    def test_without_scheme_does_not_mutate_schemeless_uri
      expected_uri = "www.yolo.com/is?cool=1"
      assert_equal expected_uri, @schemeless_uri.without_scheme
    end

    def test_with_scheme_adds_http_by_default_to_schemeless_uri
      expected_uri = "http://www.yolo.com/is?cool=1"
      assert_equal expected_uri, @schemeless_uri.with_scheme
    end

    def test_with_scheme_does_not_mutate_https_uri
      expected_uri = "https://www.yolo.com/is?cool=1"
      assert_equal expected_uri, @https_uri.with_scheme
    end

    def test_host_returns_the_root_domain_of_www_uri
      expected_host = "yolo.com"
      assert_equal expected_host, @http_uri.host
    end

    def test_host_returns_the_root_domain_of_apex_uri
      apex_uri = URIParser.new("yolo.com/is?cool=1")

      expected_host = "yolo.com"
      assert_equal expected_host, apex_uri.host
    end
  end
end
