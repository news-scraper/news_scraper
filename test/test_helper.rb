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

    def stub_temp_file_with_path(file_path)
      original_content = File.read(file_path)
      # Use a tmp dir so as not to override the actual config/article_scrape_patterns.yml
      Dir.mktmpdir do |dir|
        temp_path = File.join(dir, file_path)
        FileUtils.mkpath(File.dirname(temp_path))

        Dir.chdir(dir) do
          File.write(temp_path, original_content)
          capture_subprocess_io do
            yield(temp_path)
          end
        end
      end
    end
  end
end
