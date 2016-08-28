require 'test_helper'
require 'yaml'

class ArticleTest < Minitest::Test
  def test_correctly_transforms_responses_from_supported_sites
    supported_sites = YAML.load_file('config/article_scrape_patterns.yml')['domains'].keys

    supported_sites.each do |domain|
      raw_data = File.read("test/data/articles/#{domain.gsub(/\./, '_')}_raw.html")
      expected_transformation = YAML.load_file("test/data/articles/#{domain.gsub(/\./, '_')}_transformed.yml")

      assert_equal expected_transformation, NewsScraper::Transformers::Article.new(uri: "#{domain}/some_article", payload: raw_data).transform
    end
  end
end
