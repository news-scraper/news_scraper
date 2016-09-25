require 'simplecov'

if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

threshold = 100
SimpleCov.at_exit do
  SimpleCov.result.format!
  if SimpleCov.result.covered_percent < threshold
    puts "The coverage dipped below the acceptable threshold of #{threshold}. Failed."
    exit(1)
  end
end

SimpleCov.start do
  add_group "Extractors",     "lib/news_scraper/extractors"
  add_group "Trainer",        "lib/news_scraper/trainer"
  add_group "Transformers",   "lib/news_scraper/transformers"
  add_group "Root",           ["lib/news_scraper/.*.rb", "lib/news_scraper.rb"]

  filters.clear
  add_filter { |src| !(src.filename =~ %r{^#{SimpleCov.root}/lib/}) }
  add_filter '/test/'
end

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

    def trainer_transformation_fixture(domain)
      YAML.load_file("test/data/articles/trainer_#{domain.tr('.', '_')}_transformed.yml")
    end

    def transformation_fixture(domain)
      YAML.load_file("test/data/articles/#{domain.tr('.', '_')}_transformed.yml")
    end
  end
end
