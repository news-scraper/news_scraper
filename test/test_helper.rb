require 'news_scraper'
require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/mini_test'
require 'timecop'
require 'pry'

require_relative 'helpers/extractors_test_helpers'

module MiniTest
  class Test
    def setup
      super

      NewsScraper.reset_configuration
      FileUtils.touch(scrape_patterns_path)
      File.write(scrape_patterns_path, NewsScraper.configuration.scrape_patterns.to_yaml)

      NewsScraper.configure do |config|
        config.scrape_patterns_filepath = scrape_patterns_path
      end
    end

    def teardown
      FileUtils.rm_rf(scrape_patterns_path)
      super
    end

    def scrape_patterns_path
      "/tmp/#{location.tr('#', '_')}"
    end

    def raw_data_fixture(domain)
      File.read("test/data/articles/#{domain.tr('.', '_')}_raw")
    end

    def transformation_fixture(domain)
      YAML.load_file("test/data/articles/#{domain.tr('.', '_')}_transformed.yml")
    end
  end
end
