require 'news_scraper'
require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/mini_test'
require 'timecop'
require 'pry'

require_relative 'helpers/extractors_test_helpers'

module MiniTest
  class Test
    def raw_data_fixture(domain)
      File.read("test/data/articles/#{domain.tr('.', '_')}_raw")
    end

    def transformation_fixture(domain)
      YAML.load_file("test/data/articles/#{domain.tr('.', '_')}_transformed.yml")
    end

    def default_configuration
      @configuration ||= begin
        tmp_file = Tempfile.new
        tmp_file.write(File.read(NewsScraper::Configuration::DEFAULT_SCRAPE_PATTERNS_FILEPATH))
        tmp_file.rewind
        NewsScraper::Configuration.new(scrape_patterns_filepath: tmp_file.path)
      end
    end
  end
end
