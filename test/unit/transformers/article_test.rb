require 'test_helper'
require 'yaml'

class ArticleTest < Minitest::Test
  def test_correctly_transforms_responses_from_supported_sites
    supported_sites = %w(investors.com)
    required_data_types = YAML.load_file('config/article_scrape_patterns.yml')['data_types']['required'].map(&:to_sym)

    supported_sites.each do |domain|
      raw_response = File.read("test/data/articles/#{domain.gsub(/\./, '_')}.html")

      expected_data = required_data_types.each_with_object({}) do |data_type, hash|
        hash[data_type] = "#{domain} #{data_type}"
      end
      expected_data.update(uri: domain)

      assert_equal expected_data, NewsScraper::Transformers::Article.new(uri: domain, payload: raw_response).transform
    end
  end
end
