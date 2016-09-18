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

      path = "/tmp/#{location.tr('#', '_')}"
      FileUtils.touch(path)
      File.write(path, File.read(NewsScraper::Configuration::DEFAULT_SCRAPE_PATTERNS_FILEPATH))

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
