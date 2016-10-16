require 'test_helper'

module NewsScraper
  class ConfigurationTest < Minitest::Test
    def test_scrape_patterns_loaded_from_scrape_patterns_fetch_method
      NewsScraper.configuration.scrape_patterns_fetch_method = proc { { 'domains' => 'test' } }
      assert_equal({ 'domains' => 'test' }, NewsScraper.configuration.scrape_patterns)
    end

    def test_reset_configuration_sets_default_filepath
      NewsScraper.configuration.scrape_patterns_fetch_method = proc { { 'domains' => 'test' } }
      NewsScraper.reset_configuration

      assert_equal YAML.load_file(Configuration::DEFAULT_SCRAPE_PATTERNS_FILEPATH),
        NewsScraper.configuration.scrape_patterns
    end
  end
end
