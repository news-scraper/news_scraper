require 'test_helper'
require 'yaml'

class ArticleScrapePatternsTest < Minitest::Test
  def setup
    @scrape_patterns = YAML.load_file('config/article_scrape_patterns.yml')
    @domains = @scrape_patterns['domains'].keys
  end

  def test_domains_should_specify_all_required_data_types
    required_data_types = @scrape_patterns['data_types']['required']

    @domains.each do |domain|
      assert required_data_types.all? { |dt| @scrape_patterns['domains'][domain].keys.include? dt }
    end
  end

  def test_domains_should_specify_method_and_pattern_for_all_data_types
    @domains.each do |domain|
      @scrape_patterns['domains'][domain].each_pair do |_data_type, spec|
        assert spec.include? 'method'
        assert spec.include? 'pattern'
      end
    end
  end

  def test_scrape_methods_must_be_css_or_xpath
    @domains.each do |domain|
      @scrape_patterns['domains'][domain].each_pair do |_data_type, spec|
        assert %w(css xpath).include? spec['method']
      end
    end
  end
end
