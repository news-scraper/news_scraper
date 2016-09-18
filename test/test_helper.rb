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

      path = "/tmp/#{location.tr('#', '_')}"
      FileUtils.touch(path)
      File.write(path, NewsScraper.configuration.scrape_patterns.to_yaml)

      NewsScraper.configure do |config|
        config.scrape_patterns_filepath = path
      end
    end

    def raw_data_fixture(domain)
      File.read("test/data/articles/#{domain.tr('.', '_')}_raw")
    end

    def transformation_fixture(domain)
      YAML.load_file("test/data/articles/#{domain.tr('.', '_')}_transformed.yml")
    end
  end
end
