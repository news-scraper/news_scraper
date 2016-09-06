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
      File.read("test/data/articles/#{domain.tr('.', '_')}_raw.html")
    end

    def transformation_fixture(domain)
      YAML.load_file("test/data/articles/#{domain.tr('.', '_')}_transformed.yml")
    end

    def temporary_scrape_patterns_test
      original_content = File.read(NewsScraper::Constants::SCRAPE_PATTERN_FILEPATH)
      # Use a tmp dir so as not to override the actual config/article_scrape_patterns.yml
      Dir.mktmpdir do |dir|
        config_path = File.join(dir, NewsScraper::Constants::SCRAPE_PATTERN_FILEPATH)
        FileUtils.mkpath(File.dirname(config_path))

        Dir.chdir(dir) do
          File.write(config_path, original_content)
          capture_subprocess_io do
            yield(config_path)
          end
        end
      end
    end
  end
end
