require 'test_helper'

module NewsScraper
  class ConfigurationTest < Minitest::Test
    def setup
      super
      @tmp_file = Tempfile.new('test_scrape_patterns_loaded_from_filepath')
      @tmp_file.write("domains:\n  test")
      @tmp_file.rewind

      NewsScraper.configure do |config|
        config.scrape_patterns_filepath = @tmp_file.path
      end
    end

    def test_raises_when_file_doesnt_exist
      assert_raises do
        NewsScraper.configure do |config|
          config.scrape_patterns_filepath = "nope"
        end
      end
    end

    def test_setting_scrape_patterns_directly
      NewsScraper.configure do |config|
        config.scrape_patterns = { "banana" => "kiwi" }
      end
      assert_equal({ "banana" => "kiwi" }, NewsScraper.configuration.scrape_patterns)
    end

    def test_scrape_patterns_domains_are_set
      NewsScraper.configure do |config|
        config.scrape_patterns['domains'] = { 'domains' => 'test' }
      end
      assert_equal({ 'domains' => 'test' }, NewsScraper.configuration.scrape_patterns['domains'])
    end

    def test_scrape_patterns_loaded_from_filepath
      assert_equal(@tmp_file.path, NewsScraper.configuration.scrape_patterns_filepath)
      assert_equal({ 'domains' => 'test' }, NewsScraper.configuration.scrape_patterns)
    end

    def test_reset_configuration_sets_default_filepath
      NewsScraper.reset_configuration
      assert_equal NewsScraper::Configuration::DEFAULT_SCRAPE_PATTERNS_FILEPATH,
        NewsScraper.configuration.scrape_patterns_filepath
    end
  end
end
