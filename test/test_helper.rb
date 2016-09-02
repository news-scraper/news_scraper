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
  end
end
