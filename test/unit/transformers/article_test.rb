require 'test_helper'
require 'yaml'

class ArticleTest < Minitest::Test
  def test_transform_returns_correct_json_transformation_for_supported_domains
    supported_domains = YAML.load_file('config/article_scrape_patterns.yml')['domains'].keys

    supported_domains.each do |domain|
      raw_data = File.read("test/data/articles/#{domain.gsub(/\./, '_')}_raw.html")
      transformer = NewsScraper::Transformers::Article.new(uri: "#{domain}/some_article", payload: raw_data)

      expected_transformation = YAML.load_file("test/data/articles/#{domain.gsub(/\./, '_')}_transformed.yml")

      assert_equal expected_transformation, transformer.transform
    end
  end

  def test_transform_raises_scrape_pattern_not_defined_for_unsupported_domain
    unsupported_domain = 'unsupported-domain.com'
    transformer = NewsScraper::Transformers::Article.new(uri: unsupported_domain, payload: '')

    err = assert_raises NewsScraper::Transformers::ScrapePatternNotDefined do
      transformer.transform
    end
    assert_equal unsupported_domain, err.root_domain
  end
end
