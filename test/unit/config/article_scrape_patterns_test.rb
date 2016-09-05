require 'test_helper'

class ArticleScrapePatternsTest < Minitest::Test
  def setup
    @scrape_patterns = YAML.load_file('config/article_scrape_patterns.yml')
    @domains = @scrape_patterns['domains'].keys
  end

  def test_domains_should_specify_all_data_types
    data_types = @scrape_patterns['data_types']

    @domains.each do |domain|
      assert data_types.all? { |dt| @scrape_patterns['domains'][domain].keys.include? dt }
    end
  end

  def test_domains_should_specify_method_and_pattern_for_all_data_types
    @domains.each do |domain|
      @scrape_patterns['domains'][domain].each_pair do |data_type, spec|
        refute_nil spec, "Spec was nil for #{data_type} for domain #{domain}"
        assert spec.include?('method'),
          "Spec did not include method for #{data_type} for domain #{domain}, was #{spec}"
        assert spec.include?('pattern'),
          "Spec did not include pattern for #{data_type}  for domain #{domain}, was #{spec}"
      end
    end
  end

  def test_scrape_methods_must_be_a_valid_method
    @domains.each do |domain|
      @scrape_patterns['domains'][domain].each_pair do |data_type, spec|
        assert %w(css xpath readability).include?(spec['method']),
          "#{spec['method']} is not a supported scrape method for #{data_type} in #{domain}"\
          " Must be one of #{VALID_METHODS}"
      end
    end
  end
end
