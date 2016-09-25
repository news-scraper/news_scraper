require 'test_helper'

module NewsScraper
  module Transformers
    class ArticleTest < Minitest::Test
      def test_transform_returns_correct_json_transformation_for_supported_domains
        supported_domains = NewsScraper.configuration.scrape_patterns['domains'].keys

        supported_domains.each do |domain|
          raw_data = raw_data_fixture(domain)
          transformer = Article.new(url: "#{domain}/some_article", payload: raw_data)

          expected_transformation = transformation_fixture(domain)
          # Yaml has a hard time with new lines on a multi-line string
          expected_transformation.map { |_, v| v.strip! }

          assert_equal expected_transformation, transformer.transform
        end
      end

      def test_transform_raises_scrape_pattern_not_defined_for_unsupported_domain
        unsupported_url = 'unsupported-domain.com/article'
        unsupported_domain = 'unsupported-domain.com'
        transformer = Article.new(url: unsupported_url, payload: '')

        err = assert_raises ScrapePatternNotDefined do
          transformer.transform
        end
        assert_equal unsupported_url, err.url
        assert_equal unsupported_domain, err.root_domain
      end
    end
  end
end
